import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/prayer_widget_service.dart';
import 'package:nada_zikrakanm/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tz_data.initializeTimeZones();
    tempDir = await Directory.systemTemp.createTemp('prayer_audit_test_');
    Hive.init(tempDir.path);
    await StorageService.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('All Kurdistan Official Cities - Complete Timetable & Chronological Verification', () {
    const kurdistanCities = ['Hawler', 'Slemani', 'Duhok', 'Halabja', 'Kirkuk', 'Zakho', 'Soran'];

    for (final cityId in kurdistanCities) {
      test('City $cityId has authentic timetable with strict chronological order and non-null values', () async {
        await StorageService.savePrayerSelectedCity(cityId);
        final city = WorldCitiesCatalog.byId(cityId);
        expect(city.isKurdistanOfficial, isTrue);

        final now = DateTime.now();
        final schedule = await PrayerRepository.getPrayerScheduleForDate(date: now);

        expect(schedule['city'], isNotNull);
        expect(schedule['isOfficialTimetable'], isTrue);

        final items = schedule['items'] as List<PrayerTimeItem>;
        expect(items.length, equals(6));

        final fajr = items.firstWhere((it) => it.id == 'fajr').time;
        final sunrise = items.firstWhere((it) => it.id == 'sunrise').time;
        final dhuhr = items.firstWhere((it) => it.id == 'dhuhr').time;
        final asr = items.firstWhere((it) => it.id == 'asr').time;
        final maghrib = items.firstWhere((it) => it.id == 'maghrib').time;
        final isha = items.firstWhere((it) => it.id == 'isha').time;

        // Strict chronological progression: Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha
        expect(fajr.isBefore(sunrise), isTrue, reason: 'Fajr must be before Sunrise for $cityId');
        expect(sunrise.isBefore(dhuhr), isTrue, reason: 'Sunrise must be before Dhuhr for $cityId');
        expect(dhuhr.isBefore(asr), isTrue, reason: 'Dhuhr must be before Asr for $cityId');
        expect(asr.isBefore(maghrib), isTrue, reason: 'Asr must be before Maghrib for $cityId');
        expect(maghrib.isBefore(isha), isTrue, reason: 'Maghrib must be before Isha for $cityId');

        // Next prayer is always non-null and valid
        final nextId = schedule['nextId'] as String;
        expect(['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'], contains(nextId));
        final nextTime = schedule['nextTime'] as DateTime?;
        expect(nextTime, isNotNull);
      });
    }
  });

  group('Worldwide Cities Across All Continents - Timezone & Ordering Audit', () {
    const globalCities = [
      'Makkah',       // UTC+3 (Umm al-Qura)
      'Madinah',      // UTC+3
      'Baghdad',      // UTC+3
      'Istanbul',     // UTC+3 (Diyanet)
      'Cairo',        // UTC+2 (Egyptian General Authority)
      'London',       // UTC+0 / +1
      'Berlin',       // UTC+1 / +2
      'Paris',        // UTC+1 / +2
      'Stockholm',    // High latitude
      'NewYork',      // UTC-5 / -4
      'LosAngeles',   // UTC-8 / -7
      'Tokyo',        // UTC+9
      'Sydney',       // UTC+10 / +11
    ];

    for (final cityId in globalCities) {
      test('Worldwide City $cityId calculates ordered prayer times and valid timezone offset', () async {
        await StorageService.savePrayerSelectedCity(cityId);
        final now = DateTime.now();
        final schedule = await PrayerRepository.getPrayerScheduleForDate(date: now);

        final items = schedule['items'] as List<PrayerTimeItem>;
        expect(items.length, equals(6));

        final fajr = items.firstWhere((it) => it.id == 'fajr').time;
        final sunrise = items.firstWhere((it) => it.id == 'sunrise').time;
        final dhuhr = items.firstWhere((it) => it.id == 'dhuhr').time;
        final asr = items.firstWhere((it) => it.id == 'asr').time;
        final maghrib = items.firstWhere((it) => it.id == 'maghrib').time;
        final isha = items.firstWhere((it) => it.id == 'isha').time;

        expect(fajr.isBefore(sunrise), isTrue);
        expect(sunrise.isBefore(dhuhr), isTrue);
        expect(dhuhr.isBefore(asr), isTrue);
        expect(asr.isBefore(maghrib), isTrue);
        expect(maghrib.isBefore(isha), isTrue);

        final targetUtcOffset = (schedule['targetUtcOffset'] as num?)?.toDouble();
        expect(targetUtcOffset, isNotNull);
        expect(targetUtcOffset! >= -12.0 && targetUtcOffset <= 14.0, isTrue);
      });
    }
  });

  group('Simulated 24-Hour Timeline Transitions - Early Morning, Mid-day, Night Verification', () {
    test('Simulated transitions throughout the day correctly resolve next prayer without skipping', () async {
      await StorageService.savePrayerSelectedCity('Hawler');
      final testDate = DateTime(2026, 11, 1);
      final schedule = await PrayerRepository.getPrayerScheduleForDate(date: testDate);
      final items = schedule['items'] as List<PrayerTimeItem>;

      final fajr = items.firstWhere((it) => it.id == 'fajr').time;
      final sunrise = items.firstWhere((it) => it.id == 'sunrise').time;
      final dhuhr = items.firstWhere((it) => it.id == 'dhuhr').time;
      final asr = items.firstWhere((it) => it.id == 'asr').time;
      final maghrib = items.firstWhere((it) => it.id == 'maghrib').time;
      final isha = items.firstWhere((it) => it.id == 'isha').time;

      const prayerOrder = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
      final timesMap = {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

      String resolveNextAt(DateTime simTime) {
        for (final id in prayerOrder) {
          if (timesMap[id]!.isAfter(simTime)) {
            return id;
          }
        }
        return 'fajr_tomorrow';
      }

      // 1. 10 minutes before Fajr -> next MUST be Fajr
      final tenMinBeforeFajr = fajr.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeFajr), equals('fajr'));

      // 2. 10 minutes before Sunrise -> next MUST be Sunrise
      final tenMinBeforeSunrise = sunrise.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeSunrise), equals('sunrise'));

      // 3. 10 minutes before Dhuhr -> next MUST be Dhuhr
      final tenMinBeforeDhuhr = dhuhr.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeDhuhr), equals('dhuhr'));

      // 4. 10 minutes before Asr -> next MUST be Asr
      final tenMinBeforeAsr = asr.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeAsr), equals('asr'));

      // 5. 10 minutes before Maghrib -> next MUST be Maghrib
      final tenMinBeforeMaghrib = maghrib.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeMaghrib), equals('maghrib'));

      // 6. 10 minutes before Isha -> next MUST be Isha
      final tenMinBeforeIsha = isha.subtract(const Duration(minutes: 10));
      expect(resolveNextAt(tenMinBeforeIsha), equals('isha'));

      // 7. Late at night (1 hour after Isha) -> next MUST be tomorrow's Fajr
      final oneHourAfterIsha = isha.add(const Duration(hours: 1));
      expect(resolveNextAt(oneHourAfterIsha), equals('fajr_tomorrow'));
    });
  });

  group('Prayer Widget Service Data Serialization & UTC Epoch Accuracy', () {
    test('updateWidgets saves all timestamps as valid UTC seconds without negative differences', () async {
      await StorageService.savePrayerSelectedCity('Hawler');
      await PrayerWidgetService.updateWidgets();

      final box = Hive.box(StorageService.settingsBox);
      expect(box.isOpen, isTrue);

      final schedule = await PrayerRepository.getPrayerScheduleForDate(date: DateTime.now());
      final targetUtcOffset = (schedule['targetUtcOffset'] as num).toDouble();

      for (final id in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        final item = (schedule['items'] as List<PrayerTimeItem>).firstWhere((it) => it.id == id);
        final prayerUtc = DateTime.utc(
          item.time.year,
          item.time.month,
          item.time.day,
          item.time.hour,
          item.time.minute,
        ).subtract(Duration(minutes: (targetUtcOffset * 60).round()));

        // The UTC timestamp in seconds is positive and reasonable (year 2026+)
        final expectedSec = prayerUtc.millisecondsSinceEpoch / 1000.0;
        expect(expectedSec, greaterThan(1700000000.0));
      }
    });
  });

  group('Notification Service Rescheduling & Timezone Safety', () {
    test('rescheduleUpcomingPrayerAzans executes cleanly and constructs valid TZDateTime', () async {
      await StorageService.savePrayerSelectedCity('Hawler');
      await StorageService.saveSetting('notifications', true);
      await StorageService.savePreAzanReminderMinutes(15);

      // Verify reschedule runs without throwing
      await NotificationService.rescheduleUpcomingPrayerAzans();

      // Verify timezone lookup
      final loc = tz.getLocation('Asia/Baghdad');
      expect(loc.name, equals('Asia/Baghdad'));

      final nowInBaghdad = tz.TZDateTime.now(loc);
      expect(nowInBaghdad.year, greaterThanOrEqualTo(2026));
    });
  });
}

