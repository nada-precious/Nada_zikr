import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../app_localizations.dart';
import '../widgets/app_theme.dart';
import 'prayer_repository.dart';
import 'storage_service.dart';

/// Service for keeping Android & iOS Home Screen / Lock Screen widgets in sync
/// with real-time prayer schedules and countdowns.
class PrayerWidgetService {
  static const String appGroupId = 'group.com.nada.nadaZikrakanm';
  static const String androidWidgetProvider = 'PrayerTimesWidgetProvider';
  static const String iOSWidgetName = 'PrayerTimesWidget';

  static String resolveSharedPrayerValue(
    Map<String, dynamic> values, {
    required List<String> keys,
    required String fallback,
  }) {
    for (final key in keys) {
      final value = values[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  /// Initializes App Group settings for iOS WidgetKit.
  /// Called every time before writing data to guarantee the group is always set.
  static Future<void> _ensureInit() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
    } catch (e) {
      debugPrint('PrayerWidgetService _ensureInit error: $e');
    }
  }

  /// Helper: save a string value.
  static Future<void> _save(String key, String value) async {
    try {
      await HomeWidget.saveWidgetData<String>(key, value, appGroupId: appGroupId);
    } catch (e) {
      debugPrint('PrayerWidgetService save($key) error: $e');
    }
  }

  /// Helper: save a double value (both as double and string for universal native compatibility).
  static Future<void> _saveDouble(String key, double value) async {
    try {
      await HomeWidget.saveWidgetData<double>(key, value, appGroupId: appGroupId);
      await HomeWidget.saveWidgetData<String>('${key}_str', value.toString(), appGroupId: appGroupId);
    } catch (e) {
      debugPrint('PrayerWidgetService saveDouble($key) error: $e');
    }
  }

  /// Formats time cleanly as 2-digit 12-hour: '04:12', '12:15', '03:45'
  static String _cleanTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// Formats time with period: '03:45 PM'
  static String _fullTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hourStr:$minuteStr $period';
  }

  /// Calculates a 0.0–1.0 progress fraction representing how far into the
  /// current prayer period we are (used by the iOS progress ring).
  static double _calcPrayerProgress(
    PrayerTimeItem? current,
    PrayerTimeItem? next, [
    DateTime? cityNow,
  ]) {
    if (current == null || next == null) return 0.0;
    final now = cityNow ?? DateTime.now();
    final periodStart = current.time;
    final periodEnd = next.time;
    final totalMs = periodEnd.difference(periodStart).inMilliseconds;
    if (totalMs <= 0) return 0.0;
    final elapsedMs = now.difference(periodStart).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  /// Immediately saves active theme key and refreshes native Android & iOS widgets.
  static Future<void> updateTheme([String? themeKey]) async {
    try {
      await _ensureInit();
      String key = themeKey ?? AppThemeController.instance.palette.key;
      if (key.isEmpty) {
        final stored = await StorageService.readSetting('appTheme', defaultValue: 'nuri');
        key = stored?.toString() ?? 'nuri';
      }
      final currentPalette = AppPalettes.byKey(key);
      await _save('theme_key', currentPalette.key);
      await _save('theme_is_dark', currentPalette.isDark ? '1' : '0');

      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        qualifiedAndroidName: 'com.nada.zikrakanm.PrayerTimesWidgetProvider',
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('PrayerWidgetService updateTheme error: $e');
    }
  }

  /// Pushes the latest calculated prayer times to native Android and iOS widgets.
  static Future<void> updateWidgets({String? specificCityId}) async {
    try {
      // Always ensure the App Group is registered before writing anything
      await _ensureInit();

      // Ensure theme key is saved upfront so widget theme is never stale
      try {
        final activePalette = AppThemeController.instance.palette;
        String themeKey = activePalette.key;
        if (themeKey.isEmpty) {
          final stored = await StorageService.readSetting('appTheme', defaultValue: 'nuri');
          themeKey = stored?.toString() ?? 'nuri';
        }
        final currentPalette = AppPalettes.byKey(themeKey);
        await _save('theme_key', currentPalette.key);
        await _save('theme_is_dark', currentPalette.isDark ? '1' : '0');
      } catch (e) {
        debugPrint('PrayerWidgetService upfront theme saving error: $e');
      }

      final schedule = await PrayerRepository.getPrayerScheduleForDate(
        date: DateTime.now(),
      );

      final lang = AppLocalizations.languageCode;
      final isKurmanji = lang == 'kmr';
      final isKurdish = lang == 'ku' || isKurmanji;
      final isArabic = lang == 'ar';

      final items = schedule['items'] as List<PrayerTimeItem>? ?? [];
      final cityName = isKurdish
          ? (schedule['locationNameKu'] as String? ??
              schedule['locationName'] as String? ??
              'کوردستان')
          : (isArabic
              ? (schedule['locationNameAr'] as String? ?? 'كردستان')
              : (schedule['locationNameEn'] as String? ??
                  schedule['locationName'] as String? ??
                  'Kurdistan'));
      final hijriInfo = schedule['hijriDate'] as HijriDateInfo?;

      final scheduleNextId = schedule['nextId'] as String? ?? 'fajr';
      final scheduleNextTime = schedule['nextTime'] as DateTime?;

      // Find the next upcoming prayer (and the one before it, for progress)
      PrayerTimeItem? nextItem;
      PrayerTimeItem? currentItem; // prayer currently in progress (just before next)
      for (int i = 0; i < items.length; i++) {
        if (items[i].isNext) {
          nextItem = items[i];
          currentItem = i > 0 ? items[i - 1] : null;
          break;
        }
      }

      // If all prayers today passed (e.g. after Isha), next prayer is tomorrow's Fajr
      final effectiveNextTime = nextItem?.time ?? scheduleNextTime;
      final effectiveNextId = nextItem?.id ?? scheduleNextId;
      currentItem ??= items.isNotEmpty ? items.last : null;

      // Extract individual prayer times (Clean 2-digit formatted: '04:12')
      String fajr = '--:--';
      String sunrise = '--:--';
      String dhuhr = '--:--';
      String asr = '--:--';
      String maghrib = '--:--';
      String isha = '--:--';

      for (final item in items) {
        final cTime = _cleanTime(item.time);
        switch (item.id) {
          case 'fajr':
            fajr = cTime;
            break;
          case 'sunrise':
            sunrise = cTime;
            break;
          case 'dhuhr':
            dhuhr = cTime;
            break;
          case 'asr':
            asr = cTime;
            break;
          case 'maghrib':
            maghrib = cTime;
            break;
          case 'isha':
            isha = cTime;
            break;
        }
      }

      final nextPrayerName = nextItem?.localizedName(lang) ??
          (effectiveNextId == 'fajr'
              ? (isKurdish ? 'بەیانی' : (isArabic ? 'الفجر' : 'Fajr'))
              : (isKurdish ? 'بانگ' : 'Prayer'));
      final nextPrayerTime = effectiveNextTime != null ? _fullTime(effectiveNextTime) : '--:--';
      final nextPrayerId = effectiveNextId;

      final targetUtcOffset = (schedule['targetUtcOffset'] as num?)?.toDouble() ?? 3.0;
      final targetCityUtc = DateTime.now().toUtc().add(Duration(minutes: (targetUtcOffset * 60).round()));
      final targetCityNow = DateTime(
        targetCityUtc.year,
        targetCityUtc.month,
        targetCityUtc.day,
        targetCityUtc.hour,
        targetCityUtc.minute,
        targetCityUtc.second,
      );

      // Calculate time difference relative to the target city's current local time
      String remainingText = '';
      if (effectiveNextTime != null) {
        final diff = effectiveNextTime.difference(targetCityNow);
        if (diff.isNegative) {
          remainingText = isKurmanji
              ? 'دەما بانگیە'
              : (isKurdish
                  ? 'کاتی بانگە'
                  : (isArabic ? 'حان وقت الأذان' : 'Prayer Time'));
        } else {
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          if (hours > 0) {
            remainingText = isKurmanji
                ? '$hours دەمژمێر و $minutes خولەک ماینە'
                : (isKurdish
                    ? '$hours کاتژمێر و $minutes خولەک ماوە'
                    : (isArabic
                        ? 'باقي $hours ساعة و $minutes دقيقة'
                        : 'in $hours hrs $minutes mins'));
          } else {
            remainingText = isKurmanji
                ? '$minutes خولەک ماینە'
                : (isKurdish
                    ? '$minutes خولەک ماوە'
                    : (isArabic ? 'باقي $minutes دقيقة' : 'in $minutes mins'));
          }
        }
      }

      final hijriDateFormatted = hijriInfo != null
          ? '${hijriInfo.day} ${isKurdish ? hijriInfo.monthNameKu : (isArabic ? hijriInfo.monthNameAr : hijriInfo.monthNameEn)} ${hijriInfo.year}'
          : '';

      // Progress fraction for iOS ring (0.0 = just started, 1.0 = prayer arrived)
      final prayerProgress = _calcPrayerProgress(currentItem, nextItem, targetCityNow);

      // ── Save all data (App Group set above for iOS) ──
      final lat = (schedule['latitude'] as num?)?.toDouble() ?? 36.1911;
      final lng = (schedule['longitude'] as num?)?.toDouble() ?? 44.0092;
      await _saveDouble('city_lat', lat);
      await _saveDouble('city_lng', lng);

      final currentCity = schedule['city'] as WorldCity?;
      if (currentCity != null) {
        await _save('city_id', currentCity.id);
        await _save('city_name_en', currentCity.nameEn);
        await _save('city_name_ku', currentCity.nameKu);
        await _save('city_name_ar', currentCity.nameAr);
        await _save('widget_selected_city_id', currentCity.id);
        await _saveDouble('city_update_timestamp', DateTime.now().millisecondsSinceEpoch.toDouble());
        if (currentCity.datasetKey != null) {
          await _save('city_dataset_key', currentCity.datasetKey!);
        }
      }

      await _saveDouble('prayer_progress', prayerProgress);
      await _save('city_name', cityName);
      await _save('hijri_date', hijriDateFormatted);
      await _save('next_prayer_name', nextPrayerName);
      await _save('selected_prayer_name', nextPrayerName);
      await _save('current_prayer_name', nextPrayerName);
      await _save('next_prayer_time', nextPrayerTime);
      await _save('selected_prayer_time', nextPrayerTime);
      await _save('current_prayer_time', nextPrayerTime);
      await _save('next_prayer_remaining', remainingText);
      await _save('selected_prayer_remaining', remainingText);
      await _save('current_prayer_remaining', remainingText);
      await _save('next_prayer_id', nextPrayerId);
      await _save('selected_prayer_id', nextPrayerId);
      await _save('current_prayer_id', nextPrayerId);

      await _saveDouble('city_utc_offset', targetUtcOffset);
      await _save('city_timezone_id', schedule['timezoneId'] as String? ?? 'Asia/Baghdad');

      // Save exact Unix seconds timestamp in UTC for every prayer so iOS WidgetKit can
      // schedule precision timeline switches throughout the day without string guessing.
      for (final item in items) {
        final prayerUtc = DateTime.utc(
          item.time.year,
          item.time.month,
          item.time.day,
          item.time.hour,
          item.time.minute,
        ).subtract(Duration(minutes: (targetUtcOffset * 60).round()));
        final sec = prayerUtc.millisecondsSinceEpoch / 1000.0;
        await _saveDouble('${item.id}_timestamp', sec);
        await _save('${item.id}_full_time', _fullTime(item.time));
      }

      if (effectiveNextTime != null) {
        final nextUtc = DateTime.utc(
          effectiveNextTime.year,
          effectiveNextTime.month,
          effectiveNextTime.day,
          effectiveNextTime.hour,
          effectiveNextTime.minute,
        ).subtract(Duration(minutes: (targetUtcOffset * 60).round()));
        await _saveDouble(
          'next_prayer_timestamp',
          nextUtc.millisecondsSinceEpoch / 1000.0,
        );
      }

      await _save('fajr_time',    fajr);
      await _save('sunrise_time', sunrise);
      await _save('dhuhr_time',   dhuhr);
      await _save('asr_time',     asr);
      await _save('maghrib_time', maghrib);
      await _save('isha_time',    isha);

      // Boolean flags per prayer — lets Android/iOS trivially identify active cell
      for (final id in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        await _save('is_next_$id', (id == nextPrayerId) ? '1' : '0');
      }

      await _save('app_title', isKurdish ? 'نەدا' : 'Nada');
      await _save('lang', lang);

      // Save Theme Key so Android & iOS widgets match active in-app theme
      try {
        final activePalette = AppThemeController.instance.palette;
        String themeKey = activePalette.key;
        if (themeKey.isEmpty) {
          final stored = await StorageService.readSetting('appTheme', defaultValue: 'nuri');
          themeKey = stored?.toString() ?? 'nuri';
        }
        final currentPalette = AppPalettes.byKey(themeKey);
        await _save('theme_key', currentPalette.key);
        await _save('theme_is_dark', currentPalette.isDark ? '1' : '0');
      } catch (e) {
        debugPrint('PrayerWidgetService theme saving error: $e');
      }

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        qualifiedAndroidName: 'com.nada.zikrakanm.PrayerTimesWidgetProvider',
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating widgets in PrayerWidgetService: $e');
    }
  }
}
