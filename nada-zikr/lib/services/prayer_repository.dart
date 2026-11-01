import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'location_service.dart';
import 'offline_prayer_calculator.dart';
import 'prayer_times_service.dart';
import 'storage_service.dart';

/// Country or Region Grouping Model
class CountryGroup {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final String flag;
  final List<WorldCity> cities;

  const CountryGroup({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.flag,
    required this.cities,
  });

  String get nameKmr => nameKu;

  String displayName(String locale) {
    if (locale == 'ku' || locale == 'kmr') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }
}

/// Pre-defined world cities catalog with coordinates, real IANA timezones and calculation hints.
class WorldCity {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final String countryEn;
  final String countryAr;
  final String countryKu;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final double utcOffsetStandard;
  final String recommendedMethodId;
  final String? datasetKey;

  String get nameKmr => nameKu;
  String get countryKmr => countryKu;

  const WorldCity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.countryEn,
    required this.countryAr,
    required this.countryKu,
    required this.latitude,
    required this.longitude,
    this.timezoneId = 'Asia/Baghdad',
    this.utcOffsetStandard = 3.0,
    this.recommendedMethodId = 'kurdistan_endowments',
    this.datasetKey,
  });

  bool get isKurdistanOfficial => countryEn.toLowerCase() == 'kurdistan' && datasetKey != null;

  String displayName(String locale) {
    if (locale == 'ku' || locale == 'kmr') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }

  String displayCountry(String locale) {
    if (locale == 'ku' || locale == 'kmr') return countryKu;
    if (locale == 'ar') return countryAr;
    return countryEn;
  }

  static bool _tzInitialized = false;
  static void _ensureTzInit() {
    if (!_tzInitialized) {
      try {
        tz_data.initializeTimeZones();
        _tzInitialized = true;
      } catch (_) {}
    }
  }

  /// Resolves the actual UTC offset in hours for this city on a given date (accounting for DST).
  double resolveUtcOffset([DateTime? date]) {
    final effectiveDate = date ?? DateTime.now();
    _ensureTzInit();
    try {
      final loc = tz.getLocation(timezoneId);
      final tzDate = tz.TZDateTime.from(effectiveDate, loc);
      return tzDate.timeZoneOffset.inMinutes / 60.0;
    } catch (_) {
      return utcOffsetStandard;
    }
  }

  /// Friendly timezone abbreviation (e.g., AST, GMT, BST, EDT, JST)
  String timezoneAbbreviation([DateTime? date]) {
    final effectiveDate = date ?? DateTime.now();
    _ensureTzInit();
    try {
      final loc = tz.getLocation(timezoneId);
      final tzDate = tz.TZDateTime.from(effectiveDate, loc);
      return tzDate.timeZoneName;
    } catch (_) {
      final sign = utcOffsetStandard >= 0 ? '+' : '-';
      final h = utcOffsetStandard.abs().toInt();
      return 'UTC$sign$h';
    }
  }
}

/// Global Preset Cities List organized cleanly by Country/Region.
class WorldCitiesCatalog {
  static const List<CountryGroup> countryGroups = [
    // 1. Kurdistan
    CountryGroup(
      id: 'kurdistan',
      nameEn: 'Kurdistan',
      nameAr: 'كردستان',
      nameKu: 'کوردستان',
      flag: '☀️',
      cities: [
        WorldCity(id: 'Hawler', nameEn: 'Hewlêr / Erbil', nameAr: 'أربيل', nameKu: 'هەولێر', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.1911, longitude: 44.0092, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawler'),
        WorldCity(id: 'Slemani', nameEn: 'Sulaymaniyah', nameAr: 'السليمانية', nameKu: 'سلێمانی', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.5570, longitude: 45.4351, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Slemani'),
        WorldCity(id: 'Duhok', nameEn: 'Duhok', nameAr: 'دهوك', nameKu: 'دهۆک', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.8617, longitude: 42.9992, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Duhok'),
        WorldCity(id: 'Halabja', nameEn: 'Halabja', nameAr: 'حلبجة', nameKu: 'هەڵەبجە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.1778, longitude: 45.9861, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Halabja'),
        WorldCity(id: 'Kirkuk', nameEn: 'Kirkuk', nameAr: 'كركوك', nameKu: 'کەرکووک', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.4681, longitude: 44.3922, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kirkuk'),
        WorldCity(id: 'Zakho', nameEn: 'Zakho', nameAr: 'زاخو', nameKu: 'زاخۆ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 37.1445, longitude: 42.6872, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Zakho'),
        WorldCity(id: 'Soran', nameEn: 'Soran / Diyana', nameAr: 'سوران', nameKu: 'سۆران', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6500, longitude: 44.5386, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Akre', nameEn: 'Akre', nameAr: 'عقرة', nameKu: 'ئاکرێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.7411, longitude: 43.8933, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Akre'),
        WorldCity(id: 'Kalar', nameEn: 'Kalar', nameAr: 'كلار', nameKu: 'کەلار', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.6294, longitude: 45.3169, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kalar'),
        WorldCity(id: 'Rania', nameEn: 'Rania', nameAr: 'رانية', nameKu: 'ڕانیە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.2547, longitude: 44.8825, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Ranya(Kon)'),
        WorldCity(id: 'Chamchamal', nameEn: 'Chamchamal', nameAr: 'جمجمال', nameKu: 'چەمچەماڵ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.5317, longitude: 44.8344, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Chamchamal'),
        WorldCity(id: 'Koya', nameEn: 'Koya', nameAr: 'كويسنجق', nameKu: 'کۆیە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.0828, longitude: 44.6289, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Koya'),
        WorldCity(id: 'Shaqlawa', nameEn: 'Shaqlawa', nameAr: 'شقلاوة', nameKu: 'شەقڵاوە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.4042, longitude: 44.3267, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawler'),
        WorldCity(id: 'Derbendikhan', nameEn: 'Derbendikhan', nameAr: 'دربندخان', nameKu: 'دەربەندیخان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.1114, longitude: 45.6961, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Darbandikhan'),
        WorldCity(id: 'Penjwen', nameEn: 'Penjwen', nameAr: 'بنجوين', nameKu: 'پێنچوێن', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.6167, longitude: 45.9500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Halabja'),
        WorldCity(id: 'Amadiya', nameEn: 'Amadiya', nameAr: 'العمادية', nameKu: 'ئامێدی', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 37.0917, longitude: 43.4878, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Duhok'),
        WorldCity(id: 'SaidSadiq', nameEn: 'Said Sadiq', nameAr: 'سيد صادق', nameKu: 'سەید سادق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.3558, longitude: 45.8642, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'SaidSadq'),
        WorldCity(id: 'Khurmal', nameEn: 'Khurmal', nameAr: 'خورمال', nameKu: 'خورماڵ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.2917, longitude: 46.0333, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Khurmal'),
        WorldCity(id: 'Dukan', nameEn: 'Dukan', nameAr: 'دوكان', nameKu: 'دووکان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.9528, longitude: 44.9575, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dukan'),
        WorldCity(id: 'Kifri', nameEn: 'Kifri', nameAr: 'كفري', nameKu: 'کفری', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.6897, longitude: 44.9625, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kifri'),
        WorldCity(id: 'Rawanduz', nameEn: 'Rawanduz', nameAr: 'رواندوز', nameKu: 'ڕواندز', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6117, longitude: 44.5244, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Choman', nameEn: 'Choman', nameAr: 'جومان', nameKu: 'چۆمان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6358, longitude: 44.8864, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Qasre', nameEn: 'Qasre', nameAr: 'قصري', nameKu: 'قەسرێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.5714, longitude: 44.7512, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Qasre'),
        WorldCity(id: 'Taqtaq', nameEn: 'Taqtaq', nameAr: 'طقطق', nameKu: 'تەقتەق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.8881, longitude: 44.5828, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Taqtaq'),
        WorldCity(id: 'Qaladiza', nameEn: 'Qaladiza', nameAr: 'قلعة دزة', nameKu: 'قەڵادزێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.1808, longitude: 45.1228, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Qaladze'),
        WorldCity(id: 'Bardarash', nameEn: 'Bardarash', nameAr: 'بردرش', nameKu: 'بەردەڕەش', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.4833, longitude: 43.5833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Bardarash'),
        WorldCity(id: 'Shekhan', nameEn: 'Shekhan', nameAr: 'شيخان', nameKu: 'شێخان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.7208, longitude: 43.3375, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Shekhan'),
        WorldCity(id: 'Bawanur', nameEn: 'Bawanur', nameAr: 'باوانور', nameKu: 'باوەنور', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.8217, longitude: 45.2411, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Bawanur'),
        WorldCity(id: 'Sarqala', nameEn: 'Sarqala', nameAr: 'سرقلاع', nameKu: 'سەرقەڵا', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.7214, longitude: 45.0312, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Sarqala'),
        WorldCity(id: 'Dwz', nameEn: 'Tuz Khurmatu / Dwz', nameAr: 'طوز خورماتو', nameKu: 'دوزخورماتوو', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.8872, longitude: 44.6319, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dwz'),
        WorldCity(id: 'Daquq', nameEn: 'Daquq', nameAr: 'دقوق', nameKu: 'داقووق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.0747, longitude: 44.4283, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Daquq'),
        WorldCity(id: 'Hawija', nameEn: 'Hawija', nameAr: 'الحويجة', nameKu: 'حەویجە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.3253, longitude: 43.7739, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawija'),
        WorldCity(id: 'Dibis', nameEn: 'Dibis', nameAr: 'دبس', nameKu: 'دبس', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.6881, longitude: 44.0628, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dibis'),
        WorldCity(id: 'Makhmur', nameEn: 'Makhmur', nameAr: 'مخمور', nameKu: 'مەخموور', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.7761, longitude: 43.5786, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Makhmur'),
        WorldCity(id: 'Semel', nameEn: 'Semel', nameAr: 'سميل', nameKu: 'سێمێل', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.8583, longitude: 42.8500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Duhok'),
      ],
    ),

    // 2. Iraq (Governorates & Districts)
    CountryGroup(
      id: 'iraq',
      nameEn: 'Iraq',
      nameAr: 'العراق',
      nameKu: 'عێراق',
      flag: '🇮🇶',
      cities: [
        WorldCity(id: 'Baghdad', nameEn: 'Baghdad', nameAr: 'بغداد', nameKu: 'بەغدا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.3152, longitude: 44.3661, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Baghdad'),
        WorldCity(id: 'Mosul', nameEn: 'Mosul', nameAr: 'الموصل', nameKu: 'موسڵ', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3350, longitude: 43.1189, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Mosul'),
        WorldCity(id: 'Basrah', nameEn: 'Basra', nameAr: 'البصرة', nameKu: 'بەسرە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 30.5085, longitude: 47.7804, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Basrah'),
        WorldCity(id: 'Najaf', nameEn: 'Najaf', nameAr: 'النجف', nameKu: 'نەجەف', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.0003, longitude: 44.3354, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Najaf'),
        WorldCity(id: 'Karbala', nameEn: 'Karbala', nameAr: 'كربلاء', nameKu: 'کەربەلا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.6160, longitude: 44.0249, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Karbala'),
        WorldCity(id: 'Samarra', nameEn: 'Samarra', nameAr: 'سامراء', nameKu: 'سامەڕا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.1983, longitude: 43.8742, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Samarra\''),
        WorldCity(id: 'Hillah', nameEn: 'Hillah (Babil)', nameAr: 'الحلة (بابل)', nameKu: 'حللە (بابیل)', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.4833, longitude: 44.4333, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hillah'),
        WorldCity(id: 'Nasiriyah', nameEn: 'Nasiriyah (Dhi Qar)', nameAr: 'الناصرية (ذي قار)', nameKu: 'ناسیریە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.0500, longitude: 46.2500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Nasiriyah'),
        WorldCity(id: 'Amarah', nameEn: 'Amarah (Maysan)', nameAr: 'العمارة (ميسان)', nameKu: 'عەمارە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.8333, longitude: 47.1500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Amarah'),
        WorldCity(id: 'Ramadi', nameEn: 'Ramadi (Anbar)', nameAr: 'الرمادي (الأنبار)', nameKu: 'ڕەمادی', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.4256, longitude: 43.2992, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Ramadi'),
        WorldCity(id: 'Fallujah', nameEn: 'Fallujah', nameAr: 'الفلوجة', nameKu: 'فەللووجە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.3500, longitude: 43.7833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Al Fallujah'),
        WorldCity(id: 'Tikrit', nameEn: 'Tikrit (Saladin)', nameAr: 'تكريت (صلاح الدين)', nameKu: 'تکریت', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.5970, longitude: 43.6769, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Tikrit'),
        WorldCity(id: 'Baqubah', nameEn: 'Baqubah (Diyala)', nameAr: 'بعقوبة (ديالى)', nameKu: 'بەعقووبە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.7500, longitude: 44.6500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Baqubah'),
        WorldCity(id: 'Khanaqin', nameEn: 'Khanaqin', nameAr: 'خانقين', nameKu: 'خانەقین', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.3500, longitude: 45.3833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Khanaqin'),
        WorldCity(id: 'Kut', nameEn: 'Kut (Wasit)', nameAr: 'الكوت (واسط)', nameKu: 'کوت', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.5000, longitude: 45.8167, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kut'),
        WorldCity(id: 'Diwaniyah', nameEn: 'Diwaniyah (Qadisiyyah)', nameAr: 'الديوانية (القادسية)', nameKu: 'دیوانیە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.9833, longitude: 44.9167, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Diwaniyah'),
        WorldCity(id: 'Samawah', nameEn: 'Samawah (Muthanna)', nameAr: 'السماوة (المثنى)', nameKu: 'سەماوە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.3167, longitude: 45.2833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Samawah'),
        WorldCity(id: 'Sinjar', nameEn: 'Sinjar / Shingal', nameAr: 'سنجار', nameKu: 'شەنگال', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3208, longitude: 41.8761, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Sinjar'),
        WorldCity(id: 'TalAfar', nameEn: 'Tal Afar', nameAr: 'تلعفر', nameKu: 'تەلئەعفەر', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3758, longitude: 42.4542, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Tal `Afar'),
        WorldCity(id: 'Balad', nameEn: 'Balad', nameAr: 'بلد', nameKu: 'بەلەد', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.0147, longitude: 44.1444, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Balad'),
        WorldCity(id: 'AlQaim', nameEn: 'Al-Qaim', nameAr: 'القائم', nameKu: 'قائیم', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.3592, longitude: 41.0967, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Al Qa\'im'),
        WorldCity(id: 'Hit', nameEn: 'Hit', nameAr: 'هيت', nameKu: 'هیت', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.6417, longitude: 42.8250, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hit'),
        WorldCity(id: 'Haditha', nameEn: 'Haditha', nameAr: 'حديثة', nameKu: 'حەدیسە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.1389, longitude: 42.3789, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'alhaditha'),
      ],
    ),

    // 3. Turkey (North Kurdistan / Bakur & Turkey)
    CountryGroup(
      id: 'turkey',
      nameEn: 'Turkey',
      nameAr: 'تركيا',
      nameKu: 'تورکیا',
      flag: '🇹🇷',
      cities: [
        WorldCity(id: 'Istanbul', nameEn: 'Istanbul', nameAr: 'إسطنبول', nameKu: 'ئەستەنبوڵ', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 41.0082, longitude: 28.9784, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Ankara', nameEn: 'Ankara', nameAr: 'أنقرة', nameKu: 'ئەنقەرە', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.9334, longitude: 32.8597, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Izmir', nameEn: 'Izmir', nameAr: 'إزمير', nameKu: 'ئیزمیر', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.4237, longitude: 27.1428, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Diyarbakir', nameEn: 'Diyarbakır / Amed', nameAr: 'ديار بكر (أمد)', nameKu: 'ئامەد (دیاربەکر)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.9144, longitude: 40.2306, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Urfa', nameEn: 'Şanlıurfa / Riha', nameAr: 'أورفا', nameKu: 'ڕحا (ئورفا)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.1674, longitude: 38.7954, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Batman', nameEn: 'Batman / Êlih', nameAr: 'باتمان', nameKu: 'ئێلح (باتمان)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.8812, longitude: 41.1351, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Mardin', nameEn: 'Mardin / Mêrdîn', nameAr: 'ماردين', nameKu: 'مێردین', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.3129, longitude: 40.7350, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Van', nameEn: 'Van / Wan', nameAr: 'فان', nameKu: 'وان', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.4942, longitude: 43.3800, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Gaziantep', nameEn: 'Gaziantep / Dîlok', nameAr: 'غازي عنتاب', nameKu: 'دیلۆک (عەنتاب)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.0662, longitude: 37.3833, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Sirnak', nameEn: 'Şırnak / Şirnex', nameAr: 'شرناق', nameKu: 'شرنەخ', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.5186, longitude: 42.4594, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Cizre', nameEn: 'Cizre / Cizîr', nameAr: 'جزيرة ابن عمر', nameKu: 'جزیرا بۆتان', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.3278, longitude: 42.1894, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Silopi', nameEn: 'Silopi / Silopî', nameAr: 'سيلوبي', nameKu: 'سلۆپی', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.2483, longitude: 42.4697, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Hakkari', nameEn: 'Hakkâri / Colemêrg', nameAr: 'هكاري', nameKu: 'جۆلەمێرگ (هەکاری)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.5744, longitude: 43.7408, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Yuksekova', nameEn: 'Yüksekova / Gever', nameAr: 'يوكسكوفا', nameKu: 'گەڤەر', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.5736, longitude: 44.2872, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Agri', nameEn: 'Ağrı / Agirî', nameAr: 'أغري', nameKu: 'ئاگری', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.7191, longitude: 43.0503, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Dogubayazit', nameEn: 'Doğubayazıt / Bazîd', nameAr: 'دوغوبايزيد', nameKu: 'بازید', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.5461, longitude: 44.0839, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Siirt', nameEn: 'Siirt / Sêrt', nameAr: 'سعرد', nameKu: 'سێرت', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.9272, longitude: 41.9420, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Mus', nameEn: 'Muş / Mûş', nameAr: 'موش', nameKu: 'مووش', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.7432, longitude: 41.5064, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Bingol', nameEn: 'Bingöl / Çewlîk', nameAr: 'بينغول', nameKu: 'چەولیک (بینگۆل)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.8847, longitude: 40.4939, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Bitlis', nameEn: 'Bitlis / Bedlîs', nameAr: 'بدليس', nameKu: 'بەدلیس', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.3986, longitude: 42.1095, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Tatvan', nameEn: 'Tatvan / Tetwan', nameAr: 'تطوان', nameKu: 'تەتوان', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.5008, longitude: 42.2817, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Dersim', nameEn: 'Dersim / Tunceli', nameAr: 'درسيم (تونجلي)', nameKu: 'دەرسیم', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.1083, longitude: 39.5472, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Igdir', nameEn: 'Iğdır / Îdir', nameAr: 'إغدير', nameKu: 'ئیدر', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.9237, longitude: 44.0450, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Kars', nameEn: 'Kars / Qers', nameAr: 'قارص', nameKu: 'قەرس', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 40.6013, longitude: 43.0975, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Malatya', nameEn: 'Malatya / Meletî', nameAr: 'ملاطية', nameKu: 'مەلەتی', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.3552, longitude: 38.3095, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Adiyaman', nameEn: 'Adıyaman / Semsûr', nameAr: 'أديامان', nameKu: 'سەمسوور', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.7644, longitude: 38.2763, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Elazig', nameEn: 'Elazığ / Xarpêt', nameAr: 'معمورة العزيز', nameKu: 'خارپێت (ئەلازیغ)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.6744, longitude: 39.2225, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Kahramanmaras', nameEn: 'Kahramanmaraş / Gurgum', nameAr: 'مرعش', nameKu: 'گورگوم (مەرعەش)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.5858, longitude: 36.9371, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Bursa', nameEn: 'Bursa', nameAr: 'بورصة', nameKu: 'بوورسا', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 40.1885, longitude: 29.0610, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Antalya', nameEn: 'Antalya', nameAr: 'أنطاليا', nameKu: 'ئانتالیا', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 36.8969, longitude: 30.7133, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Adana', nameEn: 'Adana', nameAr: 'أضنة', nameKu: 'ئەدەنا', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.0000, longitude: 35.3213, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Konya', nameEn: 'Konya', nameAr: 'قونية', nameKu: 'قۆنیا', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.8746, longitude: 32.4932, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Mersin', nameEn: 'Mersin', nameAr: 'مرسين', nameKu: 'مێرسین', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 36.8121, longitude: 34.6415, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Kayseri', nameEn: 'Kayseri', nameAr: 'قيصرية', nameKu: 'قەیسەری', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.7312, longitude: 35.4787, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Trabzon', nameEn: 'Trabzon', nameAr: 'طرابزون', nameKu: 'ترابزۆن', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 41.0027, longitude: 39.7168, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Samsun', nameEn: 'Samsun', nameAr: 'سامسون', nameKu: 'سامسوون', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 41.2867, longitude: 36.3300, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
      ],
    ),

    // 4. Iran (East Kurdistan / Rojhilat & Iran)
    CountryGroup(
      id: 'iran',
      nameEn: 'Iran',
      nameAr: 'إيران',
      nameKu: 'ئێران',
      flag: '🇮🇷',
      cities: [
        WorldCity(id: 'Tehran', nameEn: 'Tehran', nameAr: 'طهران', nameKu: 'تاران', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.6892, longitude: 51.3890, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Urmia', nameEn: 'Urmia / Wrmê', nameAr: 'أورومية', nameKu: 'ورمێ', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 37.5527, longitude: 45.0761, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Urmia'),
        WorldCity(id: 'Sanandaj', nameEn: 'Sanandaj / Sine', nameAr: 'سنندج', nameKu: 'سنە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.3144, longitude: 46.9923, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Sanandaj'),
        WorldCity(id: 'Kermanshah', nameEn: 'Kermanshah / Kirmaşan', nameAr: 'كرمانشاه', nameKu: 'کرماشان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.3142, longitude: 47.0650, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mahabad', nameEn: 'Mahabad / Mehabad', nameAr: 'مهاباد', nameKu: 'مەهاباد', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.7631, longitude: 45.7222, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Piranshahr', nameEn: 'Piranshahr / Pîranşar', nameAr: 'بيرانشهر', nameKu: 'پیرانشار', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.7010, longitude: 45.1413, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Piranshahr'),
        WorldCity(id: 'Saqqez', nameEn: 'Saqqez / Seqiz', nameAr: 'سقز', nameKu: 'سەقز', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.2497, longitude: 46.2735, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Saqqez'),
        WorldCity(id: 'Baneh', nameEn: 'Baneh / Bane', nameAr: 'بانه', nameKu: 'بانە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.9975, longitude: 45.8853, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Baneh'),
        WorldCity(id: 'Marivan', nameEn: 'Marivan / Merîwan', nameAr: 'مريوان', nameKu: 'مەریوان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.5269, longitude: 46.1761, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl', datasetKey: 'Marivan'),
        WorldCity(id: 'Bukan', nameEn: 'Bukan / Bokan', nameAr: 'بوكان', nameKu: 'بۆکان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.5211, longitude: 46.2089, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sardasht', nameEn: 'Sardasht / Serdeşt', nameAr: 'سردشت', nameKu: 'سەردەشت', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.1553, longitude: 45.4789, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ilam', nameEn: 'Ilam / Îlam', nameAr: 'إيلام', nameKu: 'ئیلام', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 33.6374, longitude: 46.4227, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oshnavieh', nameEn: 'Oshnavieh / Şino', nameAr: 'أشنوية', nameKu: 'شنۆ', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 37.0400, longitude: 45.0983, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Naghadeh', nameEn: 'Naghadeh / Nexede', nameAr: 'نقده', nameKu: 'نەغەدە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.9553, longitude: 45.3881, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kamyaran', nameEn: 'Kamyaran', nameAr: 'كامياران', nameKu: 'کامیاران', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.7958, longitude: 46.9356, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Divandarreh', nameEn: 'Divandarreh', nameAr: 'ديواندره', nameKu: 'دیواندەرە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.9139, longitude: 47.0236, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Qorveh', nameEn: 'Qorveh', nameAr: 'قروة', nameKu: 'قوروە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.1664, longitude: 47.8044, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bijar', nameEn: 'Bijar', nameAr: 'بيجار', nameKu: 'بیجاڕ', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.8736, longitude: 47.6050, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ravansar', nameEn: 'Ravansar', nameAr: 'روانسر', nameKu: 'ڕوانسەر', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.7172, longitude: 46.6533, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Javanrud', nameEn: 'Javanrud', nameAr: 'جوانرود', nameKu: 'جوانڕۆ', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.7961, longitude: 46.4947, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Paveh', nameEn: 'Paveh', nameAr: 'باوه', nameKu: 'پاوە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.0433, longitude: 46.3564, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'SarpolZahab', nameEn: 'Sarpol-e Zahab', nameAr: 'سربل ذهاب', nameKu: 'سەرپێڵی زەهاو', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.4611, longitude: 45.8628, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tabriz', nameEn: 'Tabriz', nameAr: 'تبريز', nameKu: 'تەورێز', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 38.0800, longitude: 46.2919, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Isfahan', nameEn: 'Isfahan', nameAr: 'أصفهان', nameKu: 'ئەسفەهان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 32.6546, longitude: 51.6680, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Shiraz', nameEn: 'Shiraz', nameAr: 'شيراز', nameKu: 'شیراز', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 29.5918, longitude: 52.5837, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Mashhad', nameEn: 'Mashhad', nameAr: 'مشهد', nameKu: 'مەشھەد', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.2972, longitude: 59.6067, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Ahvaz', nameEn: 'Ahvaz', nameAr: 'الأهواز', nameKu: 'ئەهواز', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 31.3183, longitude: 48.6706, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Qom', nameEn: 'Qom', nameAr: 'قم', nameKu: 'قوم', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.6401, longitude: 50.8764, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Karaj', nameEn: 'Karaj', nameAr: 'كرج', nameKu: 'کەرەج', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.8327, longitude: 50.9915, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Rasht', nameEn: 'Rasht', nameAr: 'رشت', nameKu: 'ڕەشت', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 37.2808, longitude: 49.5832, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Hamedan', nameEn: 'Hamedan', nameAr: 'همدان', nameKu: 'هەمەدان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.7989, longitude: 48.5150, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
      ],
    ),

    // Middle East Group: Syria
    CountryGroup(
      id: 'syria',
      nameEn: 'Syria',
      nameAr: 'سوريا',
      nameKu: 'سووریا (ڕۆژئاڤا)',
      flag: '🇸🇾',
      cities: [
        WorldCity(id: 'Damascus', nameEn: 'Damascus', nameAr: 'دمشق', nameKu: 'دیمەشق', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 33.5138, longitude: 36.2765, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aleppo', nameEn: 'Aleppo', nameAr: 'حلب', nameKu: 'حەلەب', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.2021, longitude: 37.1343, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Homs', nameEn: 'Homs', nameAr: 'حمص', nameKu: 'حمس', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 34.7324, longitude: 36.7137, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Latakia', nameEn: 'Latakia', nameAr: 'اللاذقية', nameKu: 'لازقیە', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 35.5317, longitude: 35.7900, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hama', nameEn: 'Hama', nameAr: 'حماة', nameKu: 'حەما', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 35.1318, longitude: 36.7578, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Qamishli', nameEn: 'Qamishli / Qamişlo', nameAr: 'القامشلي', nameKu: 'قامیشلۆ', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 37.0522, longitude: 41.2222, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hasakah', nameEn: 'Hasakah / Heseke', nameAr: 'الحسكة', nameKu: 'حەسەکە', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.5024, longitude: 40.7477, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kobani', nameEn: 'Kobani / Kobanê', nameAr: 'عين العرب (كوباني)', nameKu: 'کۆبانێ', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.8911, longitude: 38.3533, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Afrin', nameEn: 'Afrin / Efrîn', nameAr: 'عفرين', nameKu: 'عەفرین', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.5117, longitude: 36.8686, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Amuda', nameEn: 'Amuda / Amûdê', nameAr: 'عامودا', nameKu: 'ئاموودێ', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 37.1067, longitude: 40.9167, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Derik', nameEn: 'Derik / Dêrik (Al-Malikiyah)', nameAr: 'المالكية (ديريك)', nameKu: 'دێرک (مالیکیە)', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 37.1783, longitude: 42.1389, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'RasAlAyn', nameEn: 'Ras al-Ayn / Serê Kaniyê', nameAr: 'رأس العين', nameKu: 'سەرێ کانیێ', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.8500, longitude: 40.0700, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Manbij', nameEn: 'Manbij / Menbic', nameAr: 'منبج', nameKu: 'مەنبج', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 36.5281, longitude: 37.9547, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Raqqa', nameEn: 'Raqqa / Reqa', nameAr: 'الرقة', nameKu: 'ڕەققە', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 35.9500, longitude: 39.0167, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'DeirEzZor', nameEn: 'Deir ez-Zor', nameAr: 'دير الزور', nameKu: 'دێرەزوور', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 35.3333, longitude: 40.1500, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tartus', nameEn: 'Tartus', nameAr: 'طرطوس', nameKu: 'تەرتووس', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 34.8890, longitude: 35.8866, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Idlib', nameEn: 'Idlib', nameAr: 'إدلب', nameKu: 'ئیدلب', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 35.9306, longitude: 36.6339, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Daraa', nameEn: 'Daraa', nameAr: 'درعا', nameKu: 'دەرعا', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 32.6189, longitude: 36.1022, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Palmyra', nameEn: 'Palmyra / Tadmur', nameAr: 'تدمر', nameKu: 'تەدمور', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا (ڕۆژئاڤا)', latitude: 34.5600, longitude: 38.2800, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Middle East Group: Lebanon
    CountryGroup(
      id: 'lebanon',
      nameEn: 'Lebanon',
      nameAr: 'لبنان',
      nameKu: 'لوبنان',
      flag: '🇱🇧',
      cities: [
        WorldCity(id: 'Beirut', nameEn: 'Beirut', nameAr: 'بيروت', nameKu: 'بەیرووت', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.8938, longitude: 35.5018, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'TripoliLB', nameEn: 'Tripoli', nameAr: 'طرابلس', nameKu: 'تەرابلوس', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 34.4367, longitude: 35.8497, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sidon', nameEn: 'Sidon (Saida)', nameAr: 'صيدا', nameKu: 'سەیدا', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.5631, longitude: 35.3689, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tyre', nameEn: 'Tyre (Sour)', nameAr: 'صور', nameKu: 'سوور', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.2708, longitude: 35.2039, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Baalbek', nameEn: 'Baalbek', nameAr: 'بعلبك', nameKu: 'بەعلبەگ', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 34.0058, longitude: 36.2181, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Zahle', nameEn: 'Zahle', nameAr: 'زحلة', nameKu: 'زەحلە', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.8463, longitude: 35.9020, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nabatieh', nameEn: 'Nabatieh', nameAr: 'النبطية', nameKu: 'نەباتیە', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.3789, longitude: 35.4839, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Byblos', nameEn: 'Byblos (Jbeil)', nameAr: 'جبيل', nameKu: 'جبەیل', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 34.1230, longitude: 35.6519, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Middle East Group: Jordan
    CountryGroup(
      id: 'jordan',
      nameEn: 'Jordan',
      nameAr: 'الأردن',
      nameKu: 'ئوردن',
      flag: '🇯🇴',
      cities: [
        WorldCity(id: 'Amman', nameEn: 'Amman', nameAr: 'عمان', nameKu: 'عەممان', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 31.9454, longitude: 35.9284, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Zarqa', nameEn: 'Zarqa', nameAr: 'الزرقاء', nameKu: 'زەرقا', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.0728, longitude: 36.0880, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Irbid', nameEn: 'Irbid', nameAr: 'إربد', nameKu: 'ئیربید', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.5568, longitude: 35.8469, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Russeifa', nameEn: 'Russeifa', nameAr: 'الرصيفة', nameKu: 'ڕوسەیفە', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.0178, longitude: 36.0464, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Aqaba', nameEn: 'Aqaba', nameAr: 'العقبة', nameKu: 'عەقەبە', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 29.5321, longitude: 35.0063, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'AsSalt', nameEn: 'As-Salt', nameAr: 'السلط', nameKu: 'سەلت', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.0392, longitude: 35.7272, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Madaba', nameEn: 'Madaba', nameAr: 'مأدبا', nameKu: 'مادەبا', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 31.7167, longitude: 35.7933, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Mafraq', nameEn: 'Mafraq', nameAr: 'المفرق', nameKu: 'مەفڕەق', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.3442, longitude: 36.2081, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Jerash', nameEn: 'Jerash', nameAr: 'جرش', nameKu: 'جەرەش', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 32.2747, longitude: 35.8961, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Karak', nameEn: 'Karak', nameAr: 'الكرك', nameKu: 'کەرەک', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 31.1853, longitude: 35.7048, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
      ],
    ),

    // Middle East Group: Palestine
    CountryGroup(
      id: 'palestine',
      nameEn: 'Palestine',
      nameAr: 'فلسطين',
      nameKu: 'فەلەستین',
      flag: '🇵🇸',
      cities: [
        WorldCity(id: 'Jerusalem', nameEn: 'Al-Quds / Jerusalem', nameAr: 'القدس الشريف', nameKu: 'قودسی پیرۆز', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.7683, longitude: 35.2137, timezoneId: 'Asia/Jerusalem', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gaza', nameEn: 'Gaza', nameAr: 'غزة', nameKu: 'غەززە', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.5017, longitude: 34.4668, timezoneId: 'Asia/Gaza', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ramallah', nameEn: 'Ramallah', nameAr: 'رام الله', nameKu: 'ڕامەڵڵا', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.9038, longitude: 35.2034, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hebron', nameEn: 'Hebron / Al-Khalil', nameAr: 'الخليل', nameKu: 'خەلیل', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.5293, longitude: 35.0938, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nablus', nameEn: 'Nablus', nameAr: 'نابلس', nameKu: 'نابلوس', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 32.2211, longitude: 35.2544, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bethlehem', nameEn: 'Bethlehem', nameAr: 'بيت لحم', nameKu: 'بەیتلەحم', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.7054, longitude: 35.2024, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jenin', nameEn: 'Jenin', nameAr: 'جنين', nameKu: 'جەنین', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 32.4646, longitude: 35.2939, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tulkarm', nameEn: 'Tulkarm', nameAr: 'طولكرم', nameKu: 'توولکەرم', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 32.3117, longitude: 35.0278, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jericho', nameEn: 'Jericho', nameAr: 'أريحا', nameKu: 'ئەریحا', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.8611, longitude: 35.4608, timezoneId: 'Asia/Hebron', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'KhanYunis', nameEn: 'Khan Yunis', nameAr: 'خان يونس', nameKu: 'خان یونس', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.3462, longitude: 34.3063, timezoneId: 'Asia/Gaza', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rafah', nameEn: 'Rafah', nameAr: 'رفح', nameKu: 'ڕەفەح', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.2969, longitude: 34.2435, timezoneId: 'Asia/Gaza', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Middle East Group: Saudi Arabia
    CountryGroup(
      id: 'saudi',
      nameEn: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
      nameKu: 'عەرەبستانی سعودی',
      flag: '🇸🇦',
      cities: [
        WorldCity(id: 'Makkah', nameEn: 'Makkah Al-Mukarramah', nameAr: 'مكة المكرمة', nameKu: 'مەککەی پیرۆز', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 21.4225, longitude: 39.8262, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Madinah', nameEn: 'Madinah Al-Munawwarah', nameAr: 'المدينة المنورة', nameKu: 'مەدینەی پیرۆز', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 24.4672, longitude: 39.6112, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Riyadh', nameEn: 'Riyadh', nameAr: 'الرياض', nameKu: 'ڕیاز', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 24.7136, longitude: 46.6753, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Jeddah', nameEn: 'Jeddah', nameAr: 'جدة', nameKu: 'جەددە', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 21.5433, longitude: 39.1728, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Dammam', nameEn: 'Dammam', nameAr: 'الدمام', nameKu: 'دەمام', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 26.4207, longitude: 50.0888, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Khobar', nameEn: 'Khobar', nameAr: 'الخبر', nameKu: 'خوبەر', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 26.2172, longitude: 50.1971, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Taif', nameEn: 'Taif', nameAr: 'الطائف', nameKu: 'تائیف', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 21.2854, longitude: 40.4222, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Tabuk', nameEn: 'Tabuk', nameAr: 'تبوك', nameKu: 'تەبووک', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 28.3835, longitude: 36.5662, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Buraidah', nameEn: 'Buraidah / Qassim', nameAr: 'بريدة (القصيم)', nameKu: 'بورەیدە (قەسیم)', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 26.3260, longitude: 43.9750, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Abha', nameEn: 'Abha / Asir', nameAr: 'أبها (عسير)', nameKu: 'ئەبها', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 18.2164, longitude: 42.5053, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'KhamisMushait', nameEn: 'Khamis Mushait', nameAr: 'خميس مشيط', nameKu: 'خەمیس موشەیت', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 18.3000, longitude: 42.7333, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Jubail', nameEn: 'Jubail', nameAr: 'الجبيل', nameKu: 'جوبەیل', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 27.0046, longitude: 49.6597, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'AlAhsa', nameEn: 'Al-Ahsa / Hofuf', nameAr: 'الأحساء (الهفوف)', nameKu: 'ئەحسا', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 25.3835, longitude: 49.5862, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Najran', nameEn: 'Najran', nameAr: 'نجران', nameKu: 'نەجران', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 17.4924, longitude: 44.1277, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Jizan', nameEn: 'Jizan', nameAr: 'جازان', nameKu: 'جیزان', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 16.8892, longitude: 42.5511, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Hail', nameEn: 'Hail', nameAr: 'حائل', nameKu: 'حائیل', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 27.5219, longitude: 41.6907, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Yanbu', nameEn: 'Yanbu', nameAr: 'ينبع', nameKu: 'یەنبوع', countryEn: 'Saudi Arabia', countryAr: 'المملكة العربية السعودية', countryKu: 'عەرەبستانی سعودی', latitude: 24.0891, longitude: 38.0637, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
      ],
    ),

    // Middle East Group: United Arab Emirates
    CountryGroup(
      id: 'uae',
      nameEn: 'United Arab Emirates',
      nameAr: 'الإمارات العربية المتحدة',
      nameKu: 'ئیمارات',
      flag: '🇦🇪',
      cities: [
        WorldCity(id: 'Dubai', nameEn: 'Dubai', nameAr: 'دبي', nameKu: 'دوبەی', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.2048, longitude: 55.2708, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'AbuDhabi', nameEn: 'Abu Dhabi', nameAr: 'أبو ظبي', nameKu: 'ئەبو زەبی', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 24.4539, longitude: 54.3773, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'Sharjah', nameEn: 'Sharjah', nameAr: 'الشارقة', nameKu: 'شارقە', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.3463, longitude: 55.4209, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'Ajman', nameEn: 'Ajman', nameAr: 'عجمان', nameKu: 'عەجمان', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.4052, longitude: 55.5136, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'RasAlKhaimah', nameEn: 'Ras Al Khaimah', nameAr: 'رأس الخيمة', nameKu: 'ڕەئس ئەلخەیمە', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.7895, longitude: 55.9432, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'Fujairah', nameEn: 'Fujairah', nameAr: 'الفجيرة', nameKu: 'فوجەیرە', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.1288, longitude: 56.3265, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'AlAin', nameEn: 'Al Ain', nameAr: 'العين', nameKu: 'ئەل عەین', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 24.2075, longitude: 55.7447, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'UmmAlQuwain', nameEn: 'Umm Al Quwain', nameAr: 'أم القيوين', nameKu: 'ئوم ئەلقەیوەین', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.5647, longitude: 55.5552, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
        WorldCity(id: 'KhorFakkan', nameEn: 'Khor Fakkan', nameAr: 'خورفكان', nameKu: 'خۆرفەکان', countryEn: 'United Arab Emirates', countryAr: 'الإمارات العربية المتحدة', countryKu: 'ئیمارات', latitude: 25.3313, longitude: 56.3420, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai'),
      ],
    ),

    // Middle East Group: Qatar
    CountryGroup(
      id: 'qatar',
      nameEn: 'Qatar',
      nameAr: 'قطر',
      nameKu: 'قەتەر',
      flag: '🇶🇦',
      cities: [
        WorldCity(id: 'Doha', nameEn: 'Doha', nameAr: 'الدوحة', nameKu: 'دەوحە', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.2854, longitude: 51.5310, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'AlRayyan', nameEn: 'Al Rayyan', nameAr: 'الريان', nameKu: 'ڕەییان', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.2919, longitude: 51.4244, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'AlWakrah', nameEn: 'Al Wakrah', nameAr: 'الوكرة', nameKu: 'وەکرە', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.1768, longitude: 51.6048, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'AlKhor', nameEn: 'Al Khor', nameAr: 'الخور', nameKu: 'خوڕ', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.6839, longitude: 51.4969, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'UmmSalal', nameEn: 'Umm Salal', nameAr: 'أم صلال', nameKu: 'ئوم سەلال', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.4167, longitude: 51.4000, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Mesaieed', nameEn: 'Mesaieed', nameAr: 'مسيعيد', nameKu: 'مەسەیعید', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 24.9917, longitude: 51.5486, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
      ],
    ),

    // Middle East Group: Kuwait
    CountryGroup(
      id: 'kuwait',
      nameEn: 'Kuwait',
      nameAr: 'الكويت',
      nameKu: 'کوێت',
      flag: '🇰🇼',
      cities: [
        WorldCity(id: 'KuwaitCity', nameEn: 'Kuwait City', nameAr: 'مدينة الكويت', nameKu: 'کوێت سیتی', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.3759, longitude: 47.9774, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Hawalli', nameEn: 'Hawalli', nameAr: 'حولي', nameKu: 'حەولی', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.3328, longitude: 48.0289, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Salmiya', nameEn: 'Salmiya', nameAr: 'السالمية', nameKu: 'سالمەیە', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.3344, longitude: 48.0769, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Farwaniya', nameEn: 'Farwaniya', nameAr: 'الفروانية', nameKu: 'فەروانیە', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.2781, longitude: 47.9572, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Ahmadi', nameEn: 'Al Ahmadi', nameAr: 'الأحمدي', nameKu: 'ئەحمەدی', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.0769, longitude: 48.0839, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Jahra', nameEn: 'Al Jahra', nameAr: 'الجهراء', nameKu: 'جەهرا', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.3375, longitude: 47.6581, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
        WorldCity(id: 'Fahaheel', nameEn: 'Fahaheel', nameAr: 'الفحيحيل', nameKu: 'فەحاحیل', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.0833, longitude: 48.1333, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'kuwait'),
      ],
    ),

    // Middle East Group: Bahrain
    CountryGroup(
      id: 'bahrain',
      nameEn: 'Bahrain',
      nameAr: 'البحرين',
      nameKu: 'بەحرەین',
      flag: '🇧🇭',
      cities: [
        WorldCity(id: 'Manama', nameEn: 'Manama', nameAr: 'المنامة', nameKu: 'مەنامە', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.2285, longitude: 50.5860, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Riffa', nameEn: 'Riffa', nameAr: 'الرفاع', nameKu: 'ڕیفاع', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.1300, longitude: 50.5550, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Muharraq', nameEn: 'Muharraq', nameAr: 'المحرق', nameKu: 'موهەڕەق', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.2572, longitude: 50.6119, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'HamadTown', nameEn: 'Hamad Town', nameAr: 'مدينة حمد', nameKu: 'شاری حەمەد', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.1153, longitude: 50.5069, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'IsaTown', nameEn: 'Isa Town', nameAr: 'مدينة عيسى', nameKu: 'شاری عیسا', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.1736, longitude: 50.5478, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
      ],
    ),

    // Middle East Group: Oman
    CountryGroup(
      id: 'oman',
      nameEn: 'Oman',
      nameAr: 'سلطنة عُمان',
      nameKu: 'عومان',
      flag: '🇴🇲',
      cities: [
        WorldCity(id: 'Muscat', nameEn: 'Muscat', nameAr: 'مسقط', nameKu: 'مەسقەت', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 23.5859, longitude: 58.4059, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Salalah', nameEn: 'Salalah', nameAr: 'صلالة', nameKu: 'سەلالە', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 17.0151, longitude: 54.0924, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Sohar', nameEn: 'Sohar', nameAr: 'صحار', nameKu: 'سوحار', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 24.3642, longitude: 56.7469, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Nizwa', nameEn: 'Nizwa', nameAr: 'نزوى', nameKu: 'نیزوا', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 22.9333, longitude: 57.5333, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Sur', nameEn: 'Sur', nameAr: 'صور', nameKu: 'سوور (عومان)', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 22.5667, longitude: 59.5289, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'AlBuraimi', nameEn: 'Al Buraimi', nameAr: 'البريمي', nameKu: 'بورەیمی', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 24.2509, longitude: 55.7931, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Khasab', nameEn: 'Khasab (Musandam)', nameAr: 'خصب', nameKu: 'خەسەب', countryEn: 'Oman', countryAr: 'سلطنة عُمان', countryKu: 'عومان', latitude: 26.1799, longitude: 56.2483, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
      ],
    ),

    // Middle East Group: Yemen
    CountryGroup(
      id: 'yemen',
      nameEn: 'Yemen',
      nameAr: 'اليمن',
      nameKu: 'یەمەن',
      flag: '🇾🇪',
      cities: [
        WorldCity(id: 'Sanaa', nameEn: 'Sana\'a', nameAr: 'صنعاء', nameKu: 'سەنعا', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 15.3694, longitude: 44.1910, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Aden', nameEn: 'Aden', nameAr: 'عدن', nameKu: 'عەدەن', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 12.7855, longitude: 45.0187, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Taiz', nameEn: 'Taiz', nameAr: 'تعز', nameKu: 'تەعیز', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 13.5795, longitude: 44.0209, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'AlHudaydah', nameEn: 'Al Hudaydah', nameAr: 'الحديدة', nameKu: 'حودەیدە', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 14.7978, longitude: 42.9545, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'AlMukalla', nameEn: 'Al Mukalla (Hadhramaut)', nameAr: 'المكلا (حضرموت)', nameKu: 'مەکەلا (حەزرەمەوت)', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 14.5425, longitude: 49.1242, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Ibb', nameEn: 'Ibb', nameAr: 'إب', nameKu: 'ئیب', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 13.9667, longitude: 44.1833, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Marib', nameEn: 'Marib', nameAr: 'مأرب', nameKu: 'مەئریب', countryEn: 'Yemen', countryAr: 'اليمن', countryKu: 'یەمەن', latitude: 15.4628, longitude: 45.3253, timezoneId: 'Asia/Aden', utcOffsetStandard: 3.0, recommendedMethodId: 'egypt'),
      ],
    ),

    // European Group: Germany
    CountryGroup(
      id: 'germany',
      nameEn: 'Germany',
      nameAr: 'ألمانيا',
      nameKu: 'ئەڵمانیا',
      flag: '🇩🇪',
      cities: [
        WorldCity(id: 'Berlin', nameEn: 'Berlin', nameAr: 'برلين', nameKu: 'بەرلین', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.5200, longitude: 13.4050, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Frankfurt', nameEn: 'Frankfurt am Main', nameAr: 'فرانكفورت', nameKu: 'فرانکفۆرت', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.1109, longitude: 8.6821, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Munich', nameEn: 'Munich / München', nameAr: 'ميونخ', nameKu: 'میونشن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 48.1351, longitude: 11.5820, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hamburg', nameEn: 'Hamburg', nameAr: 'هامبورغ', nameKu: 'هامبۆرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 53.5511, longitude: 9.9937, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cologne', nameEn: 'Cologne / Köln', nameAr: 'كولونيا', nameKu: 'کۆڵن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.9375, longitude: 6.9603, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Stuttgart', nameEn: 'Stuttgart', nameAr: 'شتوتغارت', nameKu: 'شتوتگارت', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 48.7758, longitude: 9.1829, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dusseldorf', nameEn: 'Düsseldorf', nameAr: 'دوسلدورف', nameKu: 'دوسڵدۆرف', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.2277, longitude: 6.7735, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dortmund', nameEn: 'Dortmund', nameAr: 'دورتموند', nameKu: 'دۆتمووند', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.5136, longitude: 7.4653, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Essen', nameEn: 'Essen', nameAr: 'إيسن', nameKu: 'ئێسن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.4556, longitude: 7.0116, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hanover', nameEn: 'Hanover / Hannover', nameAr: 'هانوفر', nameKu: 'هانۆڤەر', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.3759, longitude: 9.7320, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bremen', nameEn: 'Bremen', nameAr: 'بريمن', nameKu: 'برێمەن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 53.0793, longitude: 8.8017, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nuremberg', nameEn: 'Nuremberg / Nürnberg', nameAr: 'نورنبرغ', nameKu: 'نوورنبێرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.4521, longitude: 11.0767, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Duisburg', nameEn: 'Duisburg', nameAr: 'دويسبورغ', nameKu: 'دویسبورگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.4344, longitude: 6.7623, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bochum', nameEn: 'Bochum', nameAr: 'بوخوم', nameKu: 'بۆخوم', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.4818, longitude: 7.2162, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Wuppertal', nameEn: 'Wuppertal', nameAr: 'فوبرتال', nameKu: 'ڤوپەرتال', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.2562, longitude: 7.1508, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bielefeld', nameEn: 'Bielefeld', nameAr: 'بيليفيلد', nameKu: 'بیلەفێڵد', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.0302, longitude: 8.5325, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bonn', nameEn: 'Bonn', nameAr: 'بون', nameKu: 'بۆن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.7374, longitude: 7.0982, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Munster', nameEn: 'Münster', nameAr: 'مونستر', nameKu: 'مۆنستەر', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.9607, longitude: 7.6261, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mannheim', nameEn: 'Mannheim', nameAr: 'مانهايم', nameKu: 'مانهایم', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.4875, longitude: 8.4660, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aachen', nameEn: 'Aachen', nameAr: 'آخن', nameKu: 'ئاخن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.7753, longitude: 6.0839, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Karlsruhe', nameEn: 'Karlsruhe', nameAr: 'كارلسروه', nameKu: 'کارلسڕووه', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.0069, longitude: 8.4037, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Augsburg', nameEn: 'Augsburg', nameAr: 'أوغسبورغ', nameKu: 'ئاوگسبۆرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 48.3705, longitude: 10.8978, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Wiesbaden', nameEn: 'Wiesbaden', nameAr: 'فيسبادن', nameKu: 'ڤیسبادن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.0826, longitude: 8.2400, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gelsenkirchen', nameEn: 'Gelsenkirchen', nameAr: 'غيلسنكيرشن', nameKu: 'گێڵزنکیرشن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.5177, longitude: 7.0857, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Monchengladbach', nameEn: 'Mönchengladbach', nameAr: 'مونشنغلادباخ', nameKu: 'مۆنشنگلادباخ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.1805, longitude: 6.4428, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Braunschweig', nameEn: 'Braunschweig', nameAr: 'براونشفايغ', nameKu: 'براونشوایگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.2689, longitude: 10.5268, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kiel', nameEn: 'Kiel', nameAr: 'كيل', nameKu: 'کیل', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 54.3233, longitude: 10.1228, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Chemnitz', nameEn: 'Chemnitz', nameAr: 'كيمنتس', nameKu: 'کێمنیتس', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.8278, longitude: 12.9214, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Halle', nameEn: 'Halle (Saale)', nameAr: 'هاله', nameKu: 'هالە', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.4828, longitude: 11.9697, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Magdeburg', nameEn: 'Magdeburg', nameAr: 'ماغديبورغ', nameKu: 'ماگدێبۆرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.1205, longitude: 11.6276, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Freiburg', nameEn: 'Freiburg im Breisgau', nameAr: 'فرايبورغ', nameKu: 'فرایبۆرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 47.9990, longitude: 7.8421, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Krefeld', nameEn: 'Krefeld', nameAr: 'كريفلد', nameKu: 'کرێفێڵد', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.3388, longitude: 6.5853, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mainz', nameEn: 'Mainz', nameAr: 'ماينتس', nameKu: 'ماینتس', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.9929, longitude: 8.2473, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lubeck', nameEn: 'Lübeck', nameAr: 'لوبيك', nameKu: 'لوبێک', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 53.8655, longitude: 10.6866, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Erfurt', nameEn: 'Erfurt', nameAr: 'إرفورت', nameKu: 'ئێرفۆرت', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.9848, longitude: 11.0299, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oberhausen', nameEn: 'Oberhausen', nameAr: 'أوبرهاوزن', nameKu: 'ئۆبەرهاوزن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.4963, longitude: 6.8638, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rostock', nameEn: 'Rostock', nameAr: 'روستوك', nameKu: 'ڕۆستۆک', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 54.0924, longitude: 12.0991, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kassel', nameEn: 'Kassel', nameAr: 'كاسل', nameKu: 'کاسڵ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 51.3127, longitude: 9.4797, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Saarbrucken', nameEn: 'Saarbrücken', nameAr: 'ساربروكن', nameKu: 'ساربرۆکن', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.2402, longitude: 6.9969, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Potsdam', nameEn: 'Potsdam', nameAr: 'بوتسدام', nameKu: 'پۆتسدام', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.3906, longitude: 13.0645, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Heidelberg', nameEn: 'Heidelberg', nameAr: 'هايدلبرغ', nameKu: 'هایدلبێرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.3988, longitude: 8.6724, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Darmstadt', nameEn: 'Darmstadt', nameAr: 'دارمشتات', nameKu: 'دارمشتات', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.8728, longitude: 8.6512, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Regensburg', nameEn: 'Regensburg', nameAr: 'ريغنسبورغ', nameKu: 'ڕێگێنسبۆرگ', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 49.0134, longitude: 12.1016, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: United Kingdom
    CountryGroup(
      id: 'uk',
      nameEn: 'United Kingdom',
      nameAr: 'المملكة المتحدة',
      nameKu: 'بەریتانیا',
      flag: '🇬🇧',
      cities: [
        WorldCity(id: 'London', nameEn: 'London', nameAr: 'لندن', nameKu: 'لەندن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.5074, longitude: -0.1278, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Birmingham', nameEn: 'Birmingham', nameAr: 'برمنغهام', nameKu: 'بێرمینگهام', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.4862, longitude: -1.8904, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Manchester', nameEn: 'Manchester', nameAr: 'مانشستر', nameKu: 'مانچستەر', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.4808, longitude: -2.2426, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Glasgow', nameEn: 'Glasgow', nameAr: 'غلاسكو', nameKu: 'گلاسگۆ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 55.8642, longitude: -4.2518, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Liverpool', nameEn: 'Liverpool', nameAr: 'ليفربول', nameKu: 'لیڤەرپوول', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.4084, longitude: -2.9916, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Leeds', nameEn: 'Leeds', nameAr: 'ليدز', nameKu: 'لیدز', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.8008, longitude: -1.5491, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Sheffield', nameEn: 'Sheffield', nameAr: 'شفيلد', nameKu: 'شێفیڵد', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.3811, longitude: -1.4701, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Edinburgh', nameEn: 'Edinburgh', nameAr: 'إدنبرة', nameKu: 'ئێدنبێرگ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 55.9533, longitude: -3.1883, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Bristol', nameEn: 'Bristol', nameAr: 'بريستول', nameKu: 'بریستۆڵ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.4545, longitude: -2.5879, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Cardiff', nameEn: 'Cardiff', nameAr: 'كارديف', nameKu: 'کاردف', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.4816, longitude: -3.1791, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Leicester', nameEn: 'Leicester', nameAr: 'ليستر', nameKu: 'لێستەر', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.6369, longitude: -1.1398, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Coventry', nameEn: 'Coventry', nameAr: 'كوفنتري', nameKu: 'کۆڤێنتری', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.4068, longitude: -1.5197, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Bradford', nameEn: 'Bradford', nameAr: 'برادفورد', nameKu: 'برادفۆرد', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.7960, longitude: -1.7594, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Belfast', nameEn: 'Belfast', nameAr: 'بلفاست', nameKu: 'بێلفاست', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 54.5973, longitude: -5.9301, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Nottingham', nameEn: 'Nottingham', nameAr: 'نوتنغهام', nameKu: 'نۆتینگهام', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.9548, longitude: -1.1581, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Newcastle', nameEn: 'Newcastle upon Tyne', nameAr: 'نيوكاسل', nameKu: 'نیوکاسڵ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 54.9783, longitude: -1.6178, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Hull', nameEn: 'Hull / Kingston upon Hull', nameAr: 'هال', nameKu: 'هەڵ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.7676, longitude: -0.3274, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Plymouth', nameEn: 'Plymouth', nameAr: 'بليموث', nameKu: 'پلیمۆس', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 50.3755, longitude: -4.1427, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Stoke', nameEn: 'Stoke-on-Trent', nameAr: 'ستوك أون ترينت', nameKu: 'ستۆک ئۆن ترێنت', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.0027, longitude: -2.1794, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Wolverhampton', nameEn: 'Wolverhampton', nameAr: 'ولفرهامبتون', nameKu: 'وۆڵڤەرهامپتن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.5862, longitude: -2.1288, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Derby', nameEn: 'Derby', nameAr: 'ديربي', nameKu: 'دێربی', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.9225, longitude: -1.4746, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Swansea', nameEn: 'Swansea', nameAr: 'سوانزي', nameKu: 'سوانزی', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.6214, longitude: -3.9436, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Southampton', nameEn: 'Southampton', nameAr: 'ساوثهامبتون', nameKu: 'ساوسهامپتن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 50.9097, longitude: -1.4044, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Luton', nameEn: 'Luton', nameAr: 'لوتون', nameKu: 'لووتن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.8787, longitude: -0.4200, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'MiltonKeynes', nameEn: 'Milton Keynes', nameAr: 'ميلتون كينز', nameKu: 'میڵتن کینز', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.0406, longitude: -0.7594, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Brighton', nameEn: 'Brighton & Hove', nameAr: 'برايتون', nameKu: 'برایتن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 50.8225, longitude: -0.1372, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Aberdeen', nameEn: 'Aberdeen', nameAr: 'أبردين', nameKu: 'ئابەردین', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 57.1497, longitude: -2.0943, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Dundee', nameEn: 'Dundee', nameAr: 'دندي', nameKu: 'دەندی', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 56.4620, longitude: -2.9707, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Cambridge', nameEn: 'Cambridge', nameAr: 'كامبريدج', nameKu: 'کەمبریج', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.2053, longitude: 0.1218, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Oxford', nameEn: 'Oxford', nameAr: 'أكسفورد', nameKu: 'ئۆکسفۆرد', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.7520, longitude: -1.2577, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Reading', nameEn: 'Reading', nameAr: 'ريدنغ', nameKu: 'ڕێدینگ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.4543, longitude: -0.9781, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Portsmouth', nameEn: 'Portsmouth', nameAr: 'بورتسموث', nameKu: 'پۆرتسمۆس', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 50.8198, longitude: -1.0880, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Preston', nameEn: 'Preston', nameAr: 'بريستون', nameKu: 'پرێستن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.7632, longitude: -2.7031, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Blackburn', nameEn: 'Blackburn', nameAr: 'بلاكبرن', nameKu: 'بلاکبێرن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.7488, longitude: -2.4818, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Bolton', nameEn: 'Bolton', nameAr: 'بولتون', nameKu: 'بۆڵتن', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.5769, longitude: -2.4282, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Oldham', nameEn: 'Oldham', nameAr: 'أولدهام', nameKu: 'ئۆڵدهام', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.5409, longitude: -2.1114, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Rochdale', nameEn: 'Rochdale', nameAr: 'روتشديل', nameKu: 'ڕۆچدەیڵ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.6178, longitude: -2.1557, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Huddersfield', nameEn: 'Huddersfield', nameAr: 'هدرسفيلد', nameKu: 'هەدەرسفیڵد', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 53.6458, longitude: -1.7850, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Slough', nameEn: 'Slough', nameAr: 'سلاو', nameKu: 'سلاو', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.5105, longitude: -0.5950, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Peterborough', nameEn: 'Peterborough', nameAr: 'بيتربورو', nameKu: 'پیتەربۆرۆ', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 52.5739, longitude: -0.2440, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Newport', nameEn: 'Newport', nameAr: 'نيوبورت', nameKu: 'نیوپۆرت', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.5842, longitude: -2.9977, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Middlesbrough', nameEn: 'Middlesbrough', nameAr: 'ميدلزبرة', nameKu: 'میدڵزبرە', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 54.5742, longitude: -1.2350, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Sunderland', nameEn: 'Sunderland', nameAr: 'سندرلاند', nameKu: 'ساندەرلاند', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 54.9069, longitude: -1.3838, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Bournemouth', nameEn: 'Bournemouth', nameAr: 'بورنموث', nameKu: 'بۆرنمۆس', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 50.7192, longitude: -1.8808, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
        WorldCity(id: 'Derry', nameEn: 'Derry / Londonderry', nameAr: 'ديري', nameKu: 'دێری', countryEn: 'United Kingdom', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 54.9966, longitude: -7.3086, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'london_unified'),
      ],
    ),

    // European Group: Sweden
    CountryGroup(
      id: 'sweden',
      nameEn: 'Sweden',
      nameAr: 'السويد',
      nameKu: 'سوید',
      flag: '🇸🇪',
      cities: [
        WorldCity(id: 'Stockholm', nameEn: 'Stockholm', nameAr: 'ستوكهولم', nameKu: 'ستۆکهۆڵم', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.3293, longitude: 18.0686, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gothenburg', nameEn: 'Gothenburg / Göteborg', nameAr: 'غوتنبرغ', nameKu: 'یۆتۆبۆری', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 57.7089, longitude: 11.9746, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Malmo', nameEn: 'Malmö', nameAr: 'مالمو', nameKu: 'ماڵمۆ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 55.6050, longitude: 13.0038, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Uppsala', nameEn: 'Uppsala', nameAr: 'أوبسالا', nameKu: 'ئۆپسالا', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.8586, longitude: 17.6389, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Orebro', nameEn: 'Örebro', nameAr: 'أوربرو', nameKu: 'ئۆریبرۆ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.2753, longitude: 15.2134, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vasteras', nameEn: 'Västerås', nameAr: 'فاستيروس', nameKu: 'ڤێستەرۆس', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.6099, longitude: 16.5448, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Linkoping', nameEn: 'Linköping', nameAr: 'لينكوبينغ', nameKu: 'لینشۆپینگ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 58.4108, longitude: 15.6214, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Helsingborg', nameEn: 'Helsingborg', nameAr: 'هلسينغبورغ', nameKu: 'هێلسینگبۆری', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 56.0465, longitude: 12.6945, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jonkoping', nameEn: 'Jönköping', nameAr: 'يونشوبينغ', nameKu: 'یۆنشۆپینگ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 57.7826, longitude: 14.1618, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Norrkoping', nameEn: 'Norrköping', nameAr: 'نورشوبينغ', nameKu: 'نۆرشۆپینگ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 58.5877, longitude: 16.1924, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sodertalje', nameEn: 'Södertälje', nameAr: 'سودرتاليا', nameKu: 'سۆدێرتێلیە', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.1955, longitude: 17.6252, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Boras', nameEn: 'Borås', nameAr: 'بوروس', nameKu: 'بۆڕۆس', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 57.7210, longitude: 12.9401, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gavle', nameEn: 'Gävle', nameAr: 'يافله', nameKu: 'یەڤلە', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 60.6749, longitude: 17.1417, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Umea', nameEn: 'Umeå', nameAr: 'أوميو', nameKu: 'ئومیۆ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 63.8258, longitude: 20.2630, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lund', nameEn: 'Lund', nameAr: 'لوند', nameKu: 'لووند', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 55.7047, longitude: 13.1910, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Eskilstuna', nameEn: 'Eskilstuna', nameAr: 'إسكيلستونا', nameKu: 'ئێسکیڵستوونا', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.3713, longitude: 16.5077, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Halmstad', nameEn: 'Halmstad', nameAr: 'هالمستاد', nameKu: 'هالمستاد', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 56.6743, longitude: 12.8578, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vaxjo', nameEn: 'Växjö', nameAr: 'فاكخو', nameKu: 'ڤێکخۆ', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 56.8777, longitude: 14.8091, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Karlstad', nameEn: 'Karlstad', nameAr: 'كارلستاد', nameKu: 'کارڵستاد', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.3793, longitude: 13.5036, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Trollhattan', nameEn: 'Trollhättan', nameAr: 'ترولهتان', nameKu: 'تڕۆڵهێتان', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 58.2837, longitude: 12.2886, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Norway
    CountryGroup(
      id: 'norway',
      nameEn: 'Norway',
      nameAr: 'النرويج',
      nameKu: 'نەرویژ',
      flag: '🇳🇴',
      cities: [
        WorldCity(id: 'Oslo', nameEn: 'Oslo', nameAr: 'أوسلو', nameKu: 'ئۆسلۆ', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.9139, longitude: 10.7522, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bergen', nameEn: 'Bergen', nameAr: 'بيرغن', nameKu: 'بێرگن', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 60.3913, longitude: 5.3221, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Trondheim', nameEn: 'Trondheim', nameAr: 'تروندهايم', nameKu: 'ترۆندهایم', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 63.4305, longitude: 10.3951, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Stavanger', nameEn: 'Stavanger', nameAr: 'ستافانغر', nameKu: 'ستاڤانگەر', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 58.9700, longitude: 5.7331, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kristiansand', nameEn: 'Kristiansand', nameAr: 'كريستيانساند', nameKu: 'کریستیانساند', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 58.1599, longitude: 8.0182, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Drammen', nameEn: 'Drammen', nameAr: 'درامن', nameKu: 'درامێن', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.7441, longitude: 10.2045, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fredrikstad', nameEn: 'Fredrikstad', nameAr: 'فريدريكستاد', nameKu: 'فرێدریکستاد', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.2181, longitude: 10.9298, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tromso', nameEn: 'Tromsø', nameAr: 'ترومسو', nameKu: 'ترۆمسۆ', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 69.6492, longitude: 18.9553, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sandnes', nameEn: 'Sandnes', nameAr: 'ساندنس', nameKu: 'ساندنێس', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 58.8524, longitude: 5.7352, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Skien', nameEn: 'Skien', nameAr: 'شين', nameKu: 'شین', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.2096, longitude: 9.6090, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Alesund', nameEn: 'Ålesund', nameAr: 'أوليسوند', nameKu: 'ئۆلێسووند', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 62.4722, longitude: 6.1495, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tonsberg', nameEn: 'Tønsberg', nameAr: 'تونسبرغ', nameKu: 'تۆنسبێرگ', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.2676, longitude: 10.4076, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Haugesund', nameEn: 'Haugesund', nameAr: 'هاوغيسوند', nameKu: 'هاوگێسووند', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.4138, longitude: 5.2680, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bodo', nameEn: 'Bodø', nameAr: 'بودو', nameKu: 'بۆدۆ', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 67.2804, longitude: 14.4049, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Denmark
    CountryGroup(
      id: 'denmark',
      nameEn: 'Denmark',
      nameAr: 'الدنمارك',
      nameKu: 'دانیمارک',
      flag: '🇩🇰',
      cities: [
        WorldCity(id: 'Copenhagen', nameEn: 'Copenhagen / København', nameAr: 'كوبنهاغن', nameKu: 'کۆپنهاگن', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.6761, longitude: 12.5683, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aarhus', nameEn: 'Aarhus', nameAr: 'آرهوس', nameKu: 'ئۆرهووس', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 56.1629, longitude: 10.2039, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Odense', nameEn: 'Odense', nameAr: 'أودنسه', nameKu: 'ئۆدێنسێ', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.4038, longitude: 10.4024, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aalborg', nameEn: 'Aalborg', nameAr: 'أولبورغ', nameKu: 'ئۆڵبۆرگ', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 57.0488, longitude: 9.9217, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Esbjerg', nameEn: 'Esbjerg', nameAr: 'إسبيرغ', nameKu: 'ئێسبێرگ', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.4670, longitude: 8.4519, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Randers', nameEn: 'Randers', nameAr: 'راندرس', nameKu: 'ڕاندێرس', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 56.4607, longitude: 10.0364, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kolding', nameEn: 'Kolding', nameAr: 'كولدينغ', nameKu: 'کۆڵدینگ', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.4904, longitude: 9.4722, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Horsens', nameEn: 'Horsens', nameAr: 'هورسنز', nameKu: 'هۆرسێنس', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.8607, longitude: 9.8503, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vejle', nameEn: 'Vejle', nameAr: 'فايله', nameKu: 'ڤایڵە', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.7093, longitude: 9.5357, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Roskilde', nameEn: 'Roskilde', nameAr: 'روسكيلده', nameKu: 'ڕۆسکیڵدە', countryEn: 'Denmark', countryAr: 'الدنمارك', countryKu: 'دانیمارک', latitude: 55.6415, longitude: 12.0804, timezoneId: 'Europe/Copenhagen', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Finland
    CountryGroup(
      id: 'finland',
      nameEn: 'Finland',
      nameAr: 'فنلندا',
      nameKu: 'فینلاند',
      flag: '🇫🇮',
      cities: [
        WorldCity(id: 'Helsinki', nameEn: 'Helsinki', nameAr: 'هلسنكي', nameKu: 'هێلسینکی', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 60.1699, longitude: 24.9384, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Espoo', nameEn: 'Espoo', nameAr: 'إسبو', nameKu: 'ئێسپۆ', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 60.2055, longitude: 24.6559, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tampere', nameEn: 'Tampere', nameAr: 'تامبيري', nameKu: 'تامپێرێ', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 61.4978, longitude: 23.7610, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vantaa', nameEn: 'Vantaa', nameAr: 'فانتا', nameKu: 'ڤانتا', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 60.2934, longitude: 25.0378, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oulu', nameEn: 'Oulu', nameAr: 'أولو', nameKu: 'ئۆولو', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 65.0121, longitude: 25.4651, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Turku', nameEn: 'Turku', nameAr: 'توركو', nameKu: 'تورکو', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 60.4518, longitude: 22.2666, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jyvaskyla', nameEn: 'Jyväskylä', nameAr: 'يوفاسكولا', nameKu: 'یڤاسکیلا', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 62.2426, longitude: 25.7473, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lahti', nameEn: 'Lahti', nameAr: 'لاهتي', nameKu: 'لاهتی', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 60.9827, longitude: 25.6612, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kuopio', nameEn: 'Kuopio', nameAr: 'كوبيو', nameKu: 'کوۆپیۆ', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 62.8924, longitude: 27.6770, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pori', nameEn: 'Pori', nameAr: 'بوري', nameKu: 'پۆری', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 61.4851, longitude: 21.7974, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vaasa', nameEn: 'Vaasa', nameAr: 'فاسا', nameKu: 'ڤاسا', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 63.0951, longitude: 21.6165, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rovaniemi', nameEn: 'Rovaniemi', nameAr: 'روفانييمي', nameKu: 'ڕۆڤانیێمی', countryEn: 'Finland', countryAr: 'فنلندا', countryKu: 'فینلاند', latitude: 66.5039, longitude: 25.7294, timezoneId: 'Europe/Helsinki', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Netherlands
    CountryGroup(
      id: 'netherlands',
      nameEn: 'Netherlands',
      nameAr: 'هولندا',
      nameKu: 'هۆڵەندا',
      flag: '🇳🇱',
      cities: [
        WorldCity(id: 'Amsterdam', nameEn: 'Amsterdam', nameAr: 'أمستردام', nameKu: 'ئەمستەردام', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.3676, longitude: 4.9041, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rotterdam', nameEn: 'Rotterdam', nameAr: 'روتردام', nameKu: 'ڕۆتەردام', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.9244, longitude: 4.4777, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'TheHague', nameEn: 'The Hague / Den Haag', nameAr: 'لاهاي', nameKu: 'لاهـای', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.0705, longitude: 4.3007, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Utrecht', nameEn: 'Utrecht', nameAr: 'أوتريخت', nameKu: 'ئۆترێخت', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.0907, longitude: 5.1214, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Eindhoven', nameEn: 'Eindhoven', nameAr: 'آيندهوفن', nameKu: 'ئایندھۆڤن', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.4416, longitude: 5.4697, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tilburg', nameEn: 'Tilburg', nameAr: 'تيلبورغ', nameKu: 'تیلبۆرگ', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.5555, longitude: 5.0913, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Groningen', nameEn: 'Groningen', nameAr: 'خرونينغن', nameKu: 'گرۆنینگن', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 53.2194, longitude: 6.5665, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Almere', nameEn: 'Almere', nameAr: 'ألميرا', nameKu: 'ئالمێرە', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.3508, longitude: 5.2647, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Breda', nameEn: 'Breda', nameAr: 'بريدا', nameKu: 'برێدا', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.5719, longitude: 4.7683, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nijmegen', nameEn: 'Nijmegen', nameAr: 'نايميخن', nameKu: 'نایمێخن', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.8126, longitude: 5.8372, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Enschede', nameEn: 'Enschede', nameAr: 'إنschede', nameKu: 'ئێنشێدە', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.2215, longitude: 6.8937, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Haarlem', nameEn: 'Haarlem', nameAr: 'هارلم', nameKu: 'هارلم', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.3874, longitude: 4.6462, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Arnhem', nameEn: 'Arnhem', nameAr: 'أرنهم', nameKu: 'ئارنهێم', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 51.9851, longitude: 5.8987, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Amersfoort', nameEn: 'Amersfoort', nameAr: 'أمرسفورت', nameKu: 'ئامێرسفۆرت', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.1561, longitude: 5.3878, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Maastricht', nameEn: 'Maastricht', nameAr: 'ماستريخت', nameKu: 'ماستریخت', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 50.8514, longitude: 5.6910, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Leiden', nameEn: 'Leiden', nameAr: 'لايدن', nameKu: 'لایدن', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.1601, longitude: 4.4970, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Belgium
    CountryGroup(
      id: 'belgium',
      nameEn: 'Belgium',
      nameAr: 'بلجيكا',
      nameKu: 'بەلجیکا',
      flag: '🇧🇪',
      cities: [
        WorldCity(id: 'Brussels', nameEn: 'Brussels', nameAr: 'بروكسل', nameKu: 'برۆکسل', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.8503, longitude: 4.3517, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Antwerp', nameEn: 'Antwerp', nameAr: 'أنتويرب', nameKu: 'ئانتوێرپ', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 51.2194, longitude: 4.4025, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ghent', nameEn: 'Ghent', nameAr: 'غنت', nameKu: 'گێنت', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 51.0543, longitude: 3.7174, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Charleroi', nameEn: 'Charleroi', nameAr: 'شارلوروا', nameKu: 'شارلەروا', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.4108, longitude: 4.4446, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Liege', nameEn: 'Liège', nameAr: 'لييج', nameKu: 'لیێج', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.6326, longitude: 5.5797, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bruges', nameEn: 'Bruges', nameAr: 'بروج', nameKu: 'برووژ', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 51.2093, longitude: 3.2247, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Namur', nameEn: 'Namur', nameAr: 'نامور', nameKu: 'نامور', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.4674, longitude: 4.8719, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Leuven', nameEn: 'Leuven', nameAr: 'لوفان', nameKu: 'لووڤێن', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.8798, longitude: 4.7005, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mons', nameEn: 'Mons', nameAr: 'مونس', nameKu: 'مۆنس', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.4542, longitude: 3.9567, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aalst', nameEn: 'Aalst', nameAr: 'آلست', nameKu: 'ئالست', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.9360, longitude: 4.0355, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mechelen', nameEn: 'Mechelen', nameAr: 'ميشيلين', nameKu: 'مێخلن', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 51.0257, longitude: 4.4776, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hasselt', nameEn: 'Hasselt', nameAr: 'هاسلت', nameKu: 'هاسێڵت', countryEn: 'Belgium', countryAr: 'بلجيكا', countryKu: 'بەلجیکا', latitude: 50.9307, longitude: 5.3378, timezoneId: 'Europe/Brussels', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: France
    CountryGroup(
      id: 'france',
      nameEn: 'France',
      nameAr: 'فرنسا',
      nameKu: 'فەرەنسا',
      flag: '🇫🇷',
      cities: [
        WorldCity(id: 'Paris', nameEn: 'Paris', nameAr: 'باريس', nameKu: 'پاریس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 48.8566, longitude: 2.3522, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Marseille', nameEn: 'Marseille', nameAr: 'مارسيليا', nameKu: 'مارسێلیا', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.2965, longitude: 5.3698, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Lyon', nameEn: 'Lyon', nameAr: 'ليون', nameKu: 'لیۆن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 45.7640, longitude: 4.8357, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Toulouse', nameEn: 'Toulouse', nameAr: 'تولوز', nameKu: 'توولوز', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.6047, longitude: 1.4442, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Nice', nameEn: 'Nice', nameAr: 'نيس', nameKu: 'نیس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.7102, longitude: 7.2620, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Nantes', nameEn: 'Nantes', nameAr: 'نانت', nameKu: 'نانت', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 47.2184, longitude: -1.5536, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Montpellier', nameEn: 'Montpellier', nameAr: 'مونبلييه', nameKu: 'مۆنپێلیێ', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.6108, longitude: 3.8767, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Strasbourg', nameEn: 'Strasbourg', nameAr: 'ستراسبورغ', nameKu: 'ستراسبۆرگ', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 48.5734, longitude: 7.7521, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Bordeaux', nameEn: 'Bordeaux', nameAr: 'بوردو', nameKu: 'بۆردۆ', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 44.8378, longitude: -0.5792, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Lille', nameEn: 'Lille', nameAr: 'ليل', nameKu: 'لیل', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 50.6292, longitude: 3.0573, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Rennes', nameEn: 'Rennes', nameAr: 'رين', nameKu: 'ڕێن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 48.1173, longitude: -1.6778, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Reims', nameEn: 'Reims', nameAr: 'ريمس', nameKu: 'ڕێمس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 49.2583, longitude: 4.0317, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'SaintEtienne', nameEn: 'Saint-Étienne', nameAr: 'سانت إتيان', nameKu: 'سانت ئیتیێن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 45.4397, longitude: 4.3872, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Toulon', nameEn: 'Toulon', nameAr: 'تولون', nameKu: 'توولۆن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.1242, longitude: 5.9280, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'LeHavre', nameEn: 'Le Havre', nameAr: 'لو هافر', nameKu: 'لۆ هاڤر', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 49.4944, longitude: 0.1079, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Grenoble', nameEn: 'Grenoble', nameAr: 'غرونوبل', nameKu: 'گرێنۆبڵ', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 45.1885, longitude: 5.7245, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Dijon', nameEn: 'Dijon', nameAr: 'ديجون', nameKu: 'دیژۆن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 47.3220, longitude: 5.0415, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Angers', nameEn: 'Angers', nameAr: 'أنجيه', nameKu: 'ئانژێ', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 47.4784, longitude: -0.5632, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Nimes', nameEn: 'Nîmes', nameAr: 'نيم', nameKu: 'نیم', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.8367, longitude: 4.3601, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'ClermontFerrand', nameEn: 'Clermont-Ferrand', nameAr: 'كليرمون فيران', nameKu: 'کلێرمۆن فێران', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 45.7772, longitude: 3.0870, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'AixEnProvence', nameEn: 'Aix-en-Provence', nameAr: 'إيكس أون بروفانس', nameKu: 'ئێکس ئۆن پرۆڤانس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 43.5297, longitude: 5.4474, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'BrestFR', nameEn: 'Brest', nameAr: 'بريست', nameKu: 'برێست', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 48.3904, longitude: -4.4861, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Tours', nameEn: 'Tours', nameAr: 'تور', nameKu: 'توور', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 47.3941, longitude: 0.6848, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Amiens', nameEn: 'Amiens', nameAr: 'أميان', nameKu: 'ئامیان', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 49.8941, longitude: 2.2957, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Metz', nameEn: 'Metz', nameAr: 'ميتز', nameKu: 'مێتس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 49.1193, longitude: 6.1757, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Mulhouse', nameEn: 'Mulhouse', nameAr: 'مولوز', nameKu: 'مولهووز', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 47.7508, longitude: 7.3359, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
        WorldCity(id: 'Rouen', nameEn: 'Rouen', nameAr: 'روان', nameKu: 'ڕۆئێن', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 49.4432, longitude: 1.0999, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france'),
      ],
    ),

    // European Group: Italy
    CountryGroup(
      id: 'italy',
      nameEn: 'Italy',
      nameAr: 'إيطاليا',
      nameKu: 'ئیتاڵیا',
      flag: '🇮🇹',
      cities: [
        WorldCity(id: 'Rome', nameEn: 'Rome', nameAr: 'روما', nameKu: 'ڕۆما', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 41.9028, longitude: 12.4964, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Milan', nameEn: 'Milan', nameAr: 'ميلانو', nameKu: 'میلان', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.4642, longitude: 9.1900, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Naples', nameEn: 'Naples', nameAr: 'نابولي', nameKu: 'ناپۆلی', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 40.8518, longitude: 14.2681, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Turin', nameEn: 'Turin', nameAr: 'تورينو', nameKu: 'تۆرینۆ', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.0703, longitude: 7.6869, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Palermo', nameEn: 'Palermo', nameAr: 'باليرمو', nameKu: 'پالێرمۆ', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 38.1157, longitude: 13.3615, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Genoa', nameEn: 'Genoa', nameAr: 'جنوة', nameKu: 'جێنەوا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 44.4056, longitude: 8.9463, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bologna', nameEn: 'Bologna', nameAr: 'بولونيا', nameKu: 'بۆڵۆنیا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 44.4949, longitude: 11.3426, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Florence', nameEn: 'Florence', nameAr: 'فلورنسا', nameKu: 'فلۆرێنس', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 43.7696, longitude: 11.2558, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bari', nameEn: 'Bari', nameAr: 'باري', nameKu: 'باری', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 41.1171, longitude: 16.8719, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Catania', nameEn: 'Catania', nameAr: 'كاتانيا', nameKu: 'کاتانیا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 37.5079, longitude: 15.0830, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Venice', nameEn: 'Venice', nameAr: 'البندقية', nameKu: 'ڤێنیز', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.4408, longitude: 12.3155, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Verona', nameEn: 'Verona', nameAr: 'فيرونا', nameKu: 'ڤێرۆنا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.4384, longitude: 10.9916, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Messina', nameEn: 'Messina', nameAr: 'ميسينا', nameKu: 'مێسینا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 38.1938, longitude: 15.5540, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Padua', nameEn: 'Padua', nameAr: 'بادوفا', nameKu: 'پادوا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.4064, longitude: 11.8768, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Trieste', nameEn: 'Trieste', nameAr: 'تريستي', nameKu: 'تریێستێ', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.6495, longitude: 13.7768, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Brescia', nameEn: 'Brescia', nameAr: 'بريشيا', nameKu: 'برێشیا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 45.5416, longitude: 10.2118, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Parma', nameEn: 'Parma', nameAr: 'بارما', nameKu: 'پارما', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 44.8015, longitude: 10.3279, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Modena', nameEn: 'Modena', nameAr: 'مودينا', nameKu: 'مۆدێنا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 44.6471, longitude: 10.9252, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'ReggioEmilia', nameEn: 'Reggio Emilia', nameAr: 'ريجيو إميليا', nameKu: 'ڕێجیۆ ئیمیلیا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 44.6989, longitude: 10.6312, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Perugia', nameEn: 'Perugia', nameAr: 'بيروجيا', nameKu: 'پێروجا', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 43.1107, longitude: 12.3908, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Spain
    CountryGroup(
      id: 'spain',
      nameEn: 'Spain',
      nameAr: 'إسبانيا',
      nameKu: 'ئیسپانیا',
      flag: '🇪🇸',
      cities: [
        WorldCity(id: 'Madrid', nameEn: 'Madrid', nameAr: 'مدريد', nameKu: 'مەدرید', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 40.4168, longitude: -3.7038, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Barcelona', nameEn: 'Barcelona', nameAr: 'برشلونة', nameKu: 'بارسێلۆنا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 41.3879, longitude: 2.1686, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Valencia', nameEn: 'Valencia', nameAr: 'بلنسية', nameKu: 'ڤالێنسیا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 39.4699, longitude: -0.3763, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Seville', nameEn: 'Seville', nameAr: 'إشبيلية', nameKu: 'سێڤیلیا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 37.3891, longitude: -5.9845, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Zaragoza', nameEn: 'Zaragoza', nameAr: 'سرقسطة', nameKu: 'زاراگۆزا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 41.6488, longitude: -0.8891, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Malaga', nameEn: 'Málaga', nameAr: 'مالقة', nameKu: 'مالاگا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 36.7213, longitude: -4.4214, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Murcia', nameEn: 'Murcia', nameAr: 'مرسية', nameKu: 'مورسیا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 37.9922, longitude: -1.1307, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Palma', nameEn: 'Palma de Mallorca', nameAr: 'بالما دي مايوركا', nameKu: 'پاڵما', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 39.5696, longitude: 2.6502, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'LasPalmas', nameEn: 'Las Palmas', nameAr: 'لاس بالماس', nameKu: 'لاس پالماس', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 28.1235, longitude: -15.4363, timezoneId: 'Atlantic/Canary', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bilbao', nameEn: 'Bilbao', nameAr: 'بلباو', nameKu: 'بیلباو', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 43.2630, longitude: -2.9350, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Alicante', nameEn: 'Alicante', nameAr: 'أليكانتي', nameKu: 'ئالیکانتێ', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 38.3452, longitude: -0.4810, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cordoba', nameEn: 'Córdoba', nameAr: 'قرطبة', nameKu: 'کۆردۆبا (قورتوبە)', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 37.8882, longitude: -4.7794, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Valladolid', nameEn: 'Valladolid', nameAr: 'بلد الوليد', nameKu: 'ڤایادۆلید', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 41.6523, longitude: -4.7245, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Granada', nameEn: 'Granada', nameAr: 'غرناطة', nameKu: 'گرانادا (غەرناتە)', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 37.1773, longitude: -3.5986, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vigo', nameEn: 'Vigo', nameAr: 'فيغو', nameKu: 'ڤیگۆ', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 42.2406, longitude: -8.7207, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gijon', nameEn: 'Gijón', nameAr: 'خيخون', nameKu: 'خیخۆن', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 43.5322, longitude: -5.6611, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pamplona', nameEn: 'Pamplona', nameAr: 'بامبلونا', nameKu: 'پامپلۆنا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 42.8125, longitude: -1.6458, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Almeria', nameEn: 'Almería', nameAr: 'المرية', nameKu: 'ئەلمێریا', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 36.8381, longitude: -2.4597, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Switzerland
    CountryGroup(
      id: 'switzerland',
      nameEn: 'Switzerland',
      nameAr: 'سويسرا',
      nameKu: 'سویسرا',
      flag: '🇨🇭',
      cities: [
        WorldCity(id: 'Zurich', nameEn: 'Zurich', nameAr: 'زيورخ', nameKu: 'زیوریخ', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.3769, longitude: 8.5417, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Geneva', nameEn: 'Geneva', nameAr: 'جنيف', nameKu: 'جنێڤ', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 46.2044, longitude: 6.1432, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Basel', nameEn: 'Basel', nameAr: 'بازل', nameKu: 'بازل', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.5596, longitude: 7.5886, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bern', nameEn: 'Bern', nameAr: 'بيرن', nameKu: 'بێرن', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 46.9480, longitude: 7.4474, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lausanne', nameEn: 'Lausanne', nameAr: 'لوزان', nameKu: 'لۆزان', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 46.5197, longitude: 6.6323, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Winterthur', nameEn: 'Winterthur', nameAr: 'فينترتور', nameKu: 'ڤینتەرتوور', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.4988, longitude: 8.7237, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lucerne', nameEn: 'Lucerne / Luzern', nameAr: 'لوسيرن', nameKu: 'لوتسێرن', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.0502, longitude: 8.3093, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'StGallen', nameEn: 'St. Gallen', nameAr: 'سانت غالن', nameKu: 'سانت گالێن', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.4245, longitude: 9.3767, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lugano', nameEn: 'Lugano', nameAr: 'لوغانو', nameKu: 'لوگانۆ', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 46.0037, longitude: 8.9511, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'BielBienne', nameEn: 'Biel / Bienne', nameAr: 'بيل', nameKu: 'بیێل', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.1368, longitude: 7.2468, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fribourg', nameEn: 'Fribourg', nameAr: 'فريبورغ', nameKu: 'فریبۆرگ', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 46.8065, longitude: 7.1620, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Schaffhausen', nameEn: 'Schaffhausen', nameAr: 'شافهاوزن', nameKu: 'شافهاوزن', countryEn: 'Switzerland', countryAr: 'سويسرا', countryKu: 'سویسرا', latitude: 47.6973, longitude: 8.6349, timezoneId: 'Europe/Zurich', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Austria
    CountryGroup(
      id: 'austria',
      nameEn: 'Austria',
      nameAr: 'النمسا',
      nameKu: 'نەمسا',
      flag: '🇦🇹',
      cities: [
        WorldCity(id: 'Vienna', nameEn: 'Vienna', nameAr: 'فيينا', nameKu: 'ڤییەنا', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 48.2082, longitude: 16.3738, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Graz', nameEn: 'Graz', nameAr: 'غراتس', nameKu: 'گراتس', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 47.0707, longitude: 15.4395, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Linz', nameEn: 'Linz', nameAr: 'لينز', nameKu: 'لینز', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 48.3069, longitude: 14.2858, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Salzburg', nameEn: 'Salzburg', nameAr: 'سالزبورغ', nameKu: 'سالزبۆرگ', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 47.8095, longitude: 13.0550, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Innsbruck', nameEn: 'Innsbruck', nameAr: 'إنسبروك', nameKu: 'ئینسبڕووک', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 47.2692, longitude: 11.4041, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Klagenfurt', nameEn: 'Klagenfurt', nameAr: 'كلاغنفورت', nameKu: 'کلاگێنفۆرت', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 46.6247, longitude: 14.3053, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Villach', nameEn: 'Villach', nameAr: 'فيلاخ', nameKu: 'ڤیلاخ', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 46.6111, longitude: 13.8558, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Wels', nameEn: 'Wels', nameAr: 'فيلس', nameKu: 'ڤێڵس', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 48.1567, longitude: 14.0246, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'SanktPolten', nameEn: 'Sankt Pölten', nameAr: 'سانكت بولتن', nameKu: 'سانکت پۆڵتن', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 48.2045, longitude: 15.6256, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dornbirn', nameEn: 'Dornbirn', nameAr: 'دورنبيرن', nameKu: 'دۆرنبیرن', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 47.4125, longitude: 9.7417, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bregenz', nameEn: 'Bregenz', nameAr: 'بريغنز', nameKu: 'برێگێنتس', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 47.5031, longitude: 9.7471, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Ireland
    CountryGroup(
      id: 'ireland',
      nameEn: 'Ireland',
      nameAr: 'أيرلندا',
      nameKu: 'ئیرلەندا',
      flag: '🇮🇪',
      cities: [
        WorldCity(id: 'Dublin', nameEn: 'Dublin', nameAr: 'دبلن', nameKu: 'دەبلین', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 53.3498, longitude: -6.2603, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cork', nameEn: 'Cork', nameAr: 'كورك', nameKu: 'کۆرک', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 51.8985, longitude: -8.4756, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Limerick', nameEn: 'Limerick', nameAr: 'ليمريك', nameKu: 'لیمریک', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 52.6638, longitude: -8.6267, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Galway', nameEn: 'Galway', nameAr: 'غالواي', nameKu: 'گالوەی', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 53.2707, longitude: -9.0568, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Waterford', nameEn: 'Waterford', nameAr: 'واترفورد', nameKu: 'واتەرفۆرد', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 52.2593, longitude: -7.1101, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Drogheda', nameEn: 'Drogheda', nameAr: 'دروغيدا', nameKu: 'درۆگێدا', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 53.7189, longitude: -6.3478, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dundalk', nameEn: 'Dundalk', nameAr: 'دوندالك', nameKu: 'دۆنداڵک', countryEn: 'Ireland', countryAr: 'أيرلندا', countryKu: 'ئیرلەندا', latitude: 54.0039, longitude: -6.4022, timezoneId: 'Europe/Dublin', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Portugal
    CountryGroup(
      id: 'portugal',
      nameEn: 'Portugal',
      nameAr: 'البرتغال',
      nameKu: 'پورتوگال',
      flag: '🇵🇹',
      cities: [
        WorldCity(id: 'Lisbon', nameEn: 'Lisbon', nameAr: 'لشبونة', nameKu: 'لیشبۆنە', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 38.7223, longitude: -9.1393, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Porto', nameEn: 'Porto', nameAr: 'بورتو', nameKu: 'پۆرتۆ', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 41.1579, longitude: -8.6291, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'VilaNovaGaia', nameEn: 'Vila Nova de Gaia', nameAr: 'فيلا نوفا دي غايا', nameKu: 'ڤیلا نۆڤا دێ گایا', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 41.1239, longitude: -8.6118, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Braga', nameEn: 'Braga', nameAr: 'براغا', nameKu: 'براگا', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 41.5454, longitude: -8.4265, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Coimbra', nameEn: 'Coimbra', nameAr: 'كويمبرا', nameKu: 'کۆیمبرا', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 40.2033, longitude: -8.4103, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Setubal', nameEn: 'Setúbal', nameAr: 'ستوبال', nameKu: 'سێتوبال', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 38.5244, longitude: -8.8882, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Faro', nameEn: 'Faro', nameAr: 'فارو', nameKu: 'فارۆ', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 37.0194, longitude: -7.9307, timezoneId: 'Europe/Lisbon', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Funchal', nameEn: 'Funchal (Madeira)', nameAr: 'فونشال (ماديرا)', nameKu: 'فۆنشال', countryEn: 'Portugal', countryAr: 'البرتغال', countryKu: 'پورتوگال', latitude: 32.6669, longitude: -16.9241, timezoneId: 'Atlantic/Madeira', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Greece
    CountryGroup(
      id: 'greece',
      nameEn: 'Greece',
      nameAr: 'اليونان',
      nameKu: 'یۆنان',
      flag: '🇬🇷',
      cities: [
        WorldCity(id: 'Athens', nameEn: 'Athens', nameAr: 'أثينا', nameKu: 'ئەتینا', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 37.9838, longitude: 23.7275, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Thessaloniki', nameEn: 'Thessaloniki', nameAr: 'سالونيك', nameKu: 'سالۆنیک', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 40.6401, longitude: 22.9444, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Patras', nameEn: 'Patras', nameAr: 'باتراس', nameKu: 'پاتراس', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 38.2466, longitude: 21.7346, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Heraklion', nameEn: 'Heraklion (Crete)', nameAr: 'كاندية (كريت)', nameKu: 'هیراکلیۆن (کریت)', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 35.3387, longitude: 25.1442, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Larissa', nameEn: 'Larissa', nameAr: 'لاريسا', nameKu: 'لاریسا', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 39.6390, longitude: 22.4191, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Komotini', nameEn: 'Komotini (Gümülcine)', nameAr: 'كوموتيني', nameKu: 'کۆمۆتینی', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 41.1192, longitude: 25.4054, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Xanthi', nameEn: 'Xanthi (İskeçe)', nameAr: 'كسانثي', nameKu: 'کسانتی', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 41.1349, longitude: 24.8880, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rhodes', nameEn: 'Rhodes', nameAr: 'رودس', nameKu: 'ڕۆدس', countryEn: 'Greece', countryAr: 'اليونان', countryKu: 'یۆنان', latitude: 36.4349, longitude: 28.2175, timezoneId: 'Europe/Athens', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Bosnia and Herzegovina
    CountryGroup(
      id: 'bosnia',
      nameEn: 'Bosnia and Herzegovina',
      nameAr: 'البوسنة والهرسك',
      nameKu: 'بۆسنە و هێرزگۆڤینا',
      flag: '🇧🇦',
      cities: [
        WorldCity(id: 'Sarajevo', nameEn: 'Sarajevo', nameAr: 'سراييفو', nameKu: 'سارایێڤۆ', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 43.8563, longitude: 18.4131, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'BanjaLuka', nameEn: 'Banja Luka', nameAr: 'بانيا لوكا', nameKu: 'بانیا لووکا', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.7722, longitude: 17.1910, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Tuzla', nameEn: 'Tuzla', nameAr: 'توزلا', nameKu: 'توزلا', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.5384, longitude: 18.6671, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Zenica', nameEn: 'Zenica', nameAr: 'زينيتسا', nameKu: 'زێنیتسا', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.2014, longitude: 17.9078, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Mostar', nameEn: 'Mostar', nameAr: 'موستار', nameKu: 'مۆستار', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 43.3438, longitude: 17.8078, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Bihac', nameEn: 'Bihać', nameAr: 'بيخاتش', nameKu: 'بیهاچ', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.8169, longitude: 15.8708, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Brcko', nameEn: 'Brčko', nameAr: 'برتشكو', nameKu: 'برچکۆ', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.8728, longitude: 18.8108, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Travnik', nameEn: 'Travnik', nameAr: 'ترافنيك', nameKu: 'تراڤنیک', countryEn: 'Bosnia and Herzegovina', countryAr: 'البوسنة والهرسك', countryKu: 'بۆسنە و هێرزگۆڤینا', latitude: 44.2264, longitude: 17.6658, timezoneId: 'Europe/Sarajevo', utcOffsetStandard: 1.0, recommendedMethodId: 'diyanet'),
      ],
    ),

    // European Group: Albania
    CountryGroup(
      id: 'albania',
      nameEn: 'Albania',
      nameAr: 'ألبانيا',
      nameKu: 'ئەلبانیا',
      flag: '🇦🇱',
      cities: [
        WorldCity(id: 'Tirana', nameEn: 'Tirana', nameAr: 'تيرانا', nameKu: 'تیرانا', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 41.3275, longitude: 19.8187, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Durres', nameEn: 'Durrës', nameAr: 'دراس', nameKu: 'دورێس', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 41.3230, longitude: 19.4414, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vlore', nameEn: 'Vlorë', nameAr: 'فلورا', nameKu: 'ڤلۆرە', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 40.4667, longitude: 19.4897, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Shkoder', nameEn: 'Shkodër', nameAr: 'شكودرا', nameKu: 'شکۆدەر', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 42.0683, longitude: 19.5126, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Elbasan', nameEn: 'Elbasan', nameAr: 'إلباسان', nameKu: 'ئێلباسان', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 41.1125, longitude: 20.0822, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fier', nameEn: 'Fier', nameAr: 'فير', nameKu: 'فیێر', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 40.7239, longitude: 19.5561, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Korce', nameEn: 'Korçë', nameAr: 'كورتشي', nameKu: 'کۆرچە', countryEn: 'Albania', countryAr: 'ألبانيا', countryKu: 'ئەلبانیا', latitude: 40.6142, longitude: 20.7778, timezoneId: 'Europe/Tirane', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Kosovo
    CountryGroup(
      id: 'kosovo',
      nameEn: 'Kosovo',
      nameAr: 'كوسوفو',
      nameKu: 'کۆسۆڤۆ',
      flag: '🇽🇰',
      cities: [
        WorldCity(id: 'Pristina', nameEn: 'Pristina', nameAr: 'برشتينا', nameKu: 'پریشتینا', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.6629, longitude: 21.1655, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Prizren', nameEn: 'Prizren', nameAr: 'بريزرن', nameKu: 'پریزڕێن', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.2153, longitude: 20.7415, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ferizaj', nameEn: 'Ferizaj', nameAr: 'فريزاي', nameKu: 'فەریزای', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.3705, longitude: 21.1557, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Peja', nameEn: 'Peja', nameAr: 'بيخا', nameKu: 'پێیا', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.6591, longitude: 20.2883, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gjakova', nameEn: 'Gjakova', nameAr: 'جاكوفا', nameKu: 'گیاکۆڤا', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.3804, longitude: 20.4308, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gjilan', nameEn: 'Gjilan', nameAr: 'غيلان', nameKu: 'گیلان', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.4636, longitude: 21.4694, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mitrovica', nameEn: 'Mitrovica', nameAr: 'ميتروفيتسا', nameKu: 'میترۆڤیتسا', countryEn: 'Kosovo', countryAr: 'كوسوفو', countryKu: 'کۆسۆڤۆ', latitude: 42.8914, longitude: 20.8660, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: North Macedonia
    CountryGroup(
      id: 'north_macedonia',
      nameEn: 'North Macedonia',
      nameAr: 'مقدونيا الشمالية',
      nameKu: 'مەقدۆنیای باکوور',
      flag: '🇲🇰',
      cities: [
        WorldCity(id: 'Skopje', nameEn: 'Skopje', nameAr: 'سكوبيه', nameKu: 'سکۆپیە', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 41.9981, longitude: 21.4254, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bitola', nameEn: 'Bitola', nameAr: 'بيتولا', nameKu: 'بیتۆلا', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 41.0319, longitude: 21.3347, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kumanovo', nameEn: 'Kumanovo', nameAr: 'كومانوفو', nameKu: 'کومانۆڤۆ', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 42.1322, longitude: 21.7144, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tetovo', nameEn: 'Tetovo', nameAr: 'تيتوفو', nameKu: 'تێتۆڤۆ', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 42.0106, longitude: 20.9714, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gostivar', nameEn: 'Gostivar', nameAr: 'غوستيفار', nameKu: 'گۆستیڤار', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 41.7961, longitude: 20.9083, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ohrid', nameEn: 'Ohrid', nameAr: 'أوخريد', nameKu: 'ئۆهرید', countryEn: 'North Macedonia', countryAr: 'مقدونيا الشمالية', countryKu: 'مەقدۆنیای باکوور', latitude: 41.1172, longitude: 20.8019, timezoneId: 'Europe/Skopje', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Poland
    CountryGroup(
      id: 'poland',
      nameEn: 'Poland',
      nameAr: 'بولندا',
      nameKu: 'پۆڵەندا',
      flag: '🇵🇱',
      cities: [
        WorldCity(id: 'Warsaw', nameEn: 'Warsaw', nameAr: 'وارسو', nameKu: 'وارشۆ', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 52.2297, longitude: 21.0122, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Krakow', nameEn: 'Kraków', nameAr: 'كراكوف', nameKu: 'کراکۆڤ', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 50.0647, longitude: 19.9450, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lodz', nameEn: 'Łódź', nameAr: 'لودز', nameKu: 'وودز', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 51.7592, longitude: 19.4560, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Wroclaw', nameEn: 'Wrocław', nameAr: 'فروتسواف', nameKu: 'ڤرۆتسواف', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 51.1079, longitude: 17.0385, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Poznan', nameEn: 'Poznań', nameAr: 'بوزنان', nameKu: 'پۆزنان', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 52.4064, longitude: 16.9252, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gdansk', nameEn: 'Gdańsk', nameAr: 'غدانسك', nameKu: 'گدانسک', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 54.3520, longitude: 18.6466, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Szczecin', nameEn: 'Szczecin', nameAr: 'شتشين', nameKu: 'شچێچین', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 53.4285, longitude: 14.5528, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bialystok', nameEn: 'Białystok', nameAr: 'بياويستوك', nameKu: 'بیالیستۆک', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 53.1325, longitude: 23.1688, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Katowice', nameEn: 'Katowice', nameAr: 'كاتوفيتسه', nameKu: 'کاتۆڤیتسە', countryEn: 'Poland', countryAr: 'بولندا', countryKu: 'پۆڵەندا', latitude: 50.2649, longitude: 19.0238, timezoneId: 'Europe/Warsaw', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Czech Republic
    CountryGroup(
      id: 'czech',
      nameEn: 'Czech Republic',
      nameAr: 'التشيك',
      nameKu: 'کۆماری چیک',
      flag: '🇨🇿',
      cities: [
        WorldCity(id: 'Prague', nameEn: 'Prague', nameAr: 'براغ', nameKu: 'پراگ', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 50.0755, longitude: 14.4378, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Brno', nameEn: 'Brno', nameAr: 'برنو', nameKu: 'برنۆ', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 49.1951, longitude: 16.6068, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ostrava', nameEn: 'Ostrava', nameAr: 'أوسترافا', nameKu: 'ئۆستراڤا', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 49.8209, longitude: 18.2625, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Plzen', nameEn: 'Plzeň', nameAr: 'بلزن', nameKu: 'پلزن', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 49.7384, longitude: 13.3736, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Liberec', nameEn: 'Liberec', nameAr: 'ليبيريتس', nameKu: 'لیبێرێتس', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 50.7663, longitude: 15.0543, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Olomouc', nameEn: 'Olomouc', nameAr: 'أولوموتس', nameKu: 'ئۆلۆمۆتس', countryEn: 'Czech Republic', countryAr: 'التشيك', countryKu: 'کۆماری چیک', latitude: 49.5938, longitude: 17.2509, timezoneId: 'Europe/Prague', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Hungary
    CountryGroup(
      id: 'hungary',
      nameEn: 'Hungary',
      nameAr: 'المجر',
      nameKu: 'مەجەرستان',
      flag: '🇭🇺',
      cities: [
        WorldCity(id: 'Budapest', nameEn: 'Budapest', nameAr: 'بودابست', nameKu: 'بوداپێست', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 47.4979, longitude: 19.0402, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Debrecen', nameEn: 'Debrecen', nameAr: 'ديبريتسين', nameKu: 'دێبرێتسێن', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 47.5316, longitude: 21.6273, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Szeged', nameEn: 'Szeged', nameAr: 'سيغيد', nameKu: 'سێگێد', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 46.2530, longitude: 20.1414, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Miskolc', nameEn: 'Miskolc', nameAr: 'ميشكولتس', nameKu: 'میشکۆڵتس', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 48.1035, longitude: 20.7784, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pecs', nameEn: 'Pécs', nameAr: 'بيتش', nameKu: 'پێچ', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 46.0727, longitude: 18.2323, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gyor', nameEn: 'Győr', nameAr: 'غيور', nameKu: 'گیۆر', countryEn: 'Hungary', countryAr: 'المجر', countryKu: 'مەجەرستان', latitude: 47.6875, longitude: 17.6504, timezoneId: 'Europe/Budapest', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Romania
    CountryGroup(
      id: 'romania',
      nameEn: 'Romania',
      nameAr: 'رومانيا',
      nameKu: 'ڕۆمانیا',
      flag: '🇷🇴',
      cities: [
        WorldCity(id: 'Bucharest', nameEn: 'Bucharest', nameAr: 'بوخارست', nameKu: 'بوخارست', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 44.4268, longitude: 26.1025, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'ClujNapoca', nameEn: 'Cluj-Napoca', nameAr: 'كلوج نابوكا', nameKu: 'کلوژ ناپۆکا', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 46.7712, longitude: 23.6236, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Timisoara', nameEn: 'Timișoara', nameAr: 'تيميشوارا', nameKu: 'تیمیشوارا', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 45.7537, longitude: 21.2257, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Iasi', nameEn: 'Iași', nameAr: 'ياشي', nameKu: 'یاشی', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 47.1585, longitude: 27.6014, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Constanta', nameEn: 'Constanța', nameAr: 'كونستانتسا', nameKu: 'کۆنستانتا', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 44.1792, longitude: 28.6498, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Craiova', nameEn: 'Craiova', nameAr: 'كرايوفا', nameKu: 'کرایۆڤا', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 44.3302, longitude: 23.7949, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Brasov', nameEn: 'Brașov', nameAr: 'براشوف', nameKu: 'براشۆڤ', countryEn: 'Romania', countryAr: 'رومانيا', countryKu: 'ڕۆمانیا', latitude: 45.6579, longitude: 25.6012, timezoneId: 'Europe/Bucharest', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Bulgaria
    CountryGroup(
      id: 'bulgaria',
      nameEn: 'Bulgaria',
      nameAr: 'بلغاريا',
      nameKu: 'بولگاریا',
      flag: '🇧🇬',
      cities: [
        WorldCity(id: 'Sofia', nameEn: 'Sofia', nameAr: 'صوفيا', nameKu: 'سۆفیا', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 42.6977, longitude: 23.3219, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Plovdiv', nameEn: 'Plovdiv', nameAr: 'بلوفديف', nameKu: 'پلۆڤدیڤ', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 42.1354, longitude: 24.7453, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Varna', nameEn: 'Varna', nameAr: 'فارنا', nameKu: 'ڤارنا', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 43.2141, longitude: 27.9147, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Burgas', nameEn: 'Burgas', nameAr: 'بورغاس', nameKu: 'بورگاس', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 42.5048, longitude: 27.4626, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ruse', nameEn: 'Ruse', nameAr: 'روسه', nameKu: 'ڕووسێ', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 43.8356, longitude: 25.9657, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Shumen', nameEn: 'Shumen', nameAr: 'شومن', nameKu: 'شومێن', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 43.2712, longitude: 26.9361, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kardzhali', nameEn: 'Kardzhali', nameAr: 'كردجالي', nameKu: 'کاردژالی', countryEn: 'Bulgaria', countryAr: 'بلغاريا', countryKu: 'بولگاریا', latitude: 41.6428, longitude: 25.3725, timezoneId: 'Europe/Sofia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Russia
    CountryGroup(
      id: 'russia',
      nameEn: 'Russia',
      nameAr: 'روسيا',
      nameKu: 'ڕووسیا',
      flag: '🇷🇺',
      cities: [
        WorldCity(id: 'Moscow', nameEn: 'Moscow', nameAr: 'موسكو', nameKu: 'مۆسکۆ', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 55.7558, longitude: 37.6173, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'SaintPetersburg', nameEn: 'Saint Petersburg', nameAr: 'سانت بطرسبرغ', nameKu: 'سانت پترسبۆرگ', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 59.9311, longitude: 30.3609, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Kazan', nameEn: 'Kazan', nameAr: 'قازان', nameKu: 'قازان', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 55.8304, longitude: 49.0661, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Ufa', nameEn: 'Ufa', nameAr: 'أوفا', nameKu: 'ئوفا', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 54.7388, longitude: 55.9721, timezoneId: 'Asia/Yekaterinburg', utcOffsetStandard: 5.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Grozny', nameEn: 'Grozny', nameAr: 'غروزني', nameKu: 'گرۆزنی', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 43.3169, longitude: 45.6986, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Makhachkala', nameEn: 'Makhachkala', nameAr: 'محج قلعة', nameKu: 'مەخاچقەڵا', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 42.9849, longitude: 47.5047, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'NizhnyNovgorod', nameEn: 'Nizhny Novgorod', nameAr: 'نيجني نوفغورود', nameKu: 'نیژنی نۆڤگۆرۆد', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 56.3269, longitude: 44.0059, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Samara', nameEn: 'Samara', nameAr: 'سامارا', nameKu: 'سامارا', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 53.2415, longitude: 50.2212, timezoneId: 'Europe/Samara', utcOffsetStandard: 4.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'RostovOnDon', nameEn: 'Rostov-on-Don', nameAr: 'روستوف على نهر الدون', nameKu: 'ڕۆستۆڤ', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 47.2357, longitude: 39.7015, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
        WorldCity(id: 'Krasnodar', nameEn: 'Krasnodar', nameAr: 'كراسنودار', nameKu: 'کراسنۆدار', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 45.0393, longitude: 38.9872, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
      ],
    ),

    // European Group: Ukraine
    CountryGroup(
      id: 'ukraine',
      nameEn: 'Ukraine',
      nameAr: 'أوكرانيا',
      nameKu: 'ئۆکرانیا',
      flag: '🇺🇦',
      cities: [
        WorldCity(id: 'Kyiv', nameEn: 'Kyiv', nameAr: 'كييف', nameKu: 'کیێڤ', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 50.4501, longitude: 30.5234, timezoneId: 'Europe/Kyiv', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kharkiv', nameEn: 'Kharkiv', nameAr: 'خاركيف', nameKu: 'خارکیڤ', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 49.9935, longitude: 36.2304, timezoneId: 'Europe/Kyiv', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Odesa', nameEn: 'Odesa', nameAr: 'أوديسا', nameKu: 'ئۆدێسا', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 46.4825, longitude: 30.7233, timezoneId: 'Europe/Kyiv', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dnipro', nameEn: 'Dnipro', nameAr: 'دنيبرو', nameKu: 'دنیپرۆ', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 48.4647, longitude: 35.0462, timezoneId: 'Europe/Kyiv', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lviv', nameEn: 'Lviv', nameAr: 'لفيف', nameKu: 'لڤیڤ', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 49.8397, longitude: 24.0297, timezoneId: 'Europe/Kyiv', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Simferopol', nameEn: 'Simferopol (Crimea)', nameAr: 'سيمفروبول (القرم)', nameKu: 'سیمفرۆپۆل (قرم)', countryEn: 'Ukraine', countryAr: 'أوكرانيا', countryKu: 'ئۆکرانیا', latitude: 44.9521, longitude: 34.1024, timezoneId: 'Europe/Simferopol', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Croatia & Slovenia
    CountryGroup(
      id: 'croatia_slovenia',
      nameEn: 'Croatia & Slovenia',
      nameAr: 'كرواتيا وسلوفينيا',
      nameKu: 'کرۆواتیا و سلۆڤینیا',
      flag: '🇭🇷',
      cities: [
        WorldCity(id: 'Zagreb', nameEn: 'Zagreb', nameAr: 'زغرب', nameKu: 'زاگرێب', countryEn: 'Croatia & Slovenia', countryAr: 'كرواتيا وسلوفينيا', countryKu: 'کرۆواتیا و سلۆڤینیا', latitude: 45.8150, longitude: 15.9819, timezoneId: 'Europe/Zagreb', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Split', nameEn: 'Split', nameAr: 'سبليت', nameKu: 'سپلیت', countryEn: 'Croatia & Slovenia', countryAr: 'كرواتيا وسلوفينيا', countryKu: 'کرۆواتیا و سلۆڤینیا', latitude: 43.5081, longitude: 16.4402, timezoneId: 'Europe/Zagreb', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rijeka', nameEn: 'Rijeka', nameAr: 'رييكا', nameKu: 'ڕیێکا', countryEn: 'Croatia & Slovenia', countryAr: 'كرواتيا وسلوفينيا', countryKu: 'کرۆواتیا و سلۆڤینیا', latitude: 45.3271, longitude: 14.4422, timezoneId: 'Europe/Zagreb', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ljubljana', nameEn: 'Ljubljana', nameAr: 'ليوبليانا', nameKu: 'لیوبلیانا', countryEn: 'Croatia & Slovenia', countryAr: 'كرواتيا وسلوفينيا', countryKu: 'کرۆواتیا و سلۆڤینیا', latitude: 46.0569, longitude: 14.5058, timezoneId: 'Europe/Ljubljana', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Maribor', nameEn: 'Maribor', nameAr: 'ماريبور', nameKu: 'ماریبۆر', countryEn: 'Croatia & Slovenia', countryAr: 'كرواتيا وسلوفينيا', countryKu: 'کرۆواتیا و سلۆڤینیا', latitude: 46.5547, longitude: 15.6459, timezoneId: 'Europe/Ljubljana', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Serbia & Montenegro
    CountryGroup(
      id: 'serbia_montenegro',
      nameEn: 'Serbia & Montenegro',
      nameAr: 'صربيا والجبل الأسود',
      nameKu: 'سڕبیا و مۆنتینیگرۆ',
      flag: '🇷🇸',
      cities: [
        WorldCity(id: 'Belgrade', nameEn: 'Belgrade', nameAr: 'بلغراد', nameKu: 'بێلگراد', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 44.7866, longitude: 20.4489, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'NoviSad', nameEn: 'Novi Sad', nameAr: 'نوفي ساد', nameKu: 'نۆڤی ساد', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 45.2671, longitude: 19.8335, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nis', nameEn: 'Niš', nameAr: 'نيش', nameKu: 'نیش', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 43.3209, longitude: 21.8958, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'NoviPazar', nameEn: 'Novi Pazar (Sandžak)', nameAr: 'نوفي بازار (السنجق)', nameKu: 'نۆڤی پازار (سەنجەق)', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 43.1407, longitude: 20.5181, timezoneId: 'Europe/Belgrade', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Podgorica', nameEn: 'Podgorica', nameAr: 'بودغوريتسا', nameKu: 'پۆدگۆریتسا', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 42.4304, longitude: 19.2594, timezoneId: 'Europe/Podgorica', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ulcinj', nameEn: 'Ulcinj', nameAr: 'أولسيني', nameKu: 'ئۆلسین', countryEn: 'Serbia & Montenegro', countryAr: 'صربيا والجبل الأسود', countryKu: 'سڕبیا و مۆنتینیگرۆ', latitude: 41.9311, longitude: 19.2144, timezoneId: 'Europe/Podgorica', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Cyprus
    CountryGroup(
      id: 'cyprus',
      nameEn: 'Cyprus',
      nameAr: 'قبرص',
      nameKu: 'قوبرس',
      flag: '🇨🇾',
      cities: [
        WorldCity(id: 'Nicosia', nameEn: 'Nicosia / Lefkoşa', nameAr: 'نيقوسيا', nameKu: 'نیکۆسیا', countryEn: 'Cyprus', countryAr: 'قبرص', countryKu: 'قوبرس', latitude: 35.1856, longitude: 33.3823, timezoneId: 'Asia/Nicosia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Limassol', nameEn: 'Limassol', nameAr: 'ليماسول', nameKu: 'لیماسۆڵ', countryEn: 'Cyprus', countryAr: 'قبرص', countryKu: 'قوبرس', latitude: 34.6786, longitude: 33.0413, timezoneId: 'Asia/Nicosia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Larnaca', nameEn: 'Larnaca', nameAr: 'لارنكا', nameKu: 'لارناکا', countryEn: 'Cyprus', countryAr: 'قبرص', countryKu: 'قوبرس', latitude: 34.9003, longitude: 33.6232, timezoneId: 'Asia/Nicosia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kyrenia', nameEn: 'Kyrenia / Girne', nameAr: 'كيرينيا', nameKu: 'گیرنێ', countryEn: 'Cyprus', countryAr: 'قبرص', countryKu: 'قوبرس', latitude: 35.3403, longitude: 33.3192, timezoneId: 'Asia/Nicosia', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // European Group: Caucasus (Azerbaijan & Georgia)
    CountryGroup(
      id: 'caucasus',
      nameEn: 'Caucasus (Azerbaijan & Georgia)',
      nameAr: 'القوقاز (أذربيجان وجورجيا)',
      nameKu: 'قەوقاز (ئازەربایجان و گورجستان)',
      flag: '🇦🇿',
      cities: [
        WorldCity(id: 'Baku', nameEn: 'Baku', nameAr: 'باكو', nameKu: 'باکوو', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 40.4093, longitude: 49.8671, timezoneId: 'Asia/Baku', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ganja', nameEn: 'Ganja', nameAr: 'كنجه', nameKu: 'گه‌نجه', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 40.6828, longitude: 46.3606, timezoneId: 'Asia/Baku', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sumqayit', nameEn: 'Sumqayit', nameAr: 'سومقاييت', nameKu: 'سومقاییت', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 40.5897, longitude: 49.6686, timezoneId: 'Asia/Baku', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tbilisi', nameEn: 'Tbilisi', nameAr: 'تبليسي', nameKu: 'تفلیس', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 41.7151, longitude: 44.8271, timezoneId: 'Asia/Tbilisi', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Batumi', nameEn: 'Batumi', nameAr: 'باتومي', nameKu: 'باتوومی', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 41.6416, longitude: 41.6359, timezoneId: 'Asia/Tbilisi', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Yerevan', nameEn: 'Yerevan', nameAr: 'يريفان', nameKu: 'یەریڤان', countryEn: 'Caucasus (Azerbaijan & Georgia)', countryAr: 'القوقاز (أذربيجان وجورجيا)', countryKu: 'قەوقاز (ئازەربایجان و گورجستان)', latitude: 40.1792, longitude: 44.4991, timezoneId: 'Asia/Yerevan', utcOffsetStandard: 4.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // 15. United States
    CountryGroup(
      id: 'usa',
      nameEn: 'United States',
      nameAr: 'الولايات المتحدة الأمريكية',
      nameKu: 'ویلایەتە یەکگرتووەکانی ئەمریکا',
      flag: '🇺🇸',
      cities: [
        WorldCity(id: 'Nashville', nameEn: 'Nashville (Little Kurdistan)', nameAr: 'ناشفيل (كردستان الصغرى)', nameKu: 'ناشفیل (کوردستانی بچووک)', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 36.1627, longitude: -86.7816, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Dallas', nameEn: 'Dallas', nameAr: 'دالاس', nameKu: 'دالاس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 32.7767, longitude: -96.7970, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'NewYork', nameEn: 'New York City', nameAr: 'نيويورك', nameKu: 'نیویۆرک', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 40.7128, longitude: -74.0060, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'LosAngeles', nameEn: 'Los Angeles', nameAr: 'لوس أنجلوس', nameKu: 'لۆس ئەنجلەس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 34.0522, longitude: -118.2437, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Chicago', nameEn: 'Chicago', nameAr: 'شيكاغو', nameKu: 'شیکاگۆ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 41.8781, longitude: -87.6298, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Houston', nameEn: 'Houston', nameAr: 'هيوستن', nameKu: 'هیۆستن', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 29.7604, longitude: -95.3698, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Austin', nameEn: 'Austin', nameAr: 'أوستن', nameKu: 'ئۆستن', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 30.2672, longitude: -97.7431, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'WashingtonDC', nameEn: 'Washington D.C.', nameAr: 'واشنطن العاصمة', nameKu: 'واشنتۆن دی سی', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 38.9072, longitude: -77.0369, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'SanDiego', nameEn: 'San Diego', nameAr: 'سان دييغو', nameKu: 'سان دیێگۆ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 32.7157, longitude: -117.1611, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'SanFrancisco', nameEn: 'San Francisco', nameAr: 'سان فرانسيسكو', nameKu: 'سان فرانسیسکۆ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 37.7749, longitude: -122.4194, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'SanJose', nameEn: 'San Jose', nameAr: 'سان خوسيه', nameKu: 'سان خۆسێ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 37.3382, longitude: -121.8863, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Seattle', nameEn: 'Seattle', nameAr: 'سياتل', nameKu: 'سیاتڵ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 47.6062, longitude: -122.3321, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Denver', nameEn: 'Denver', nameAr: 'دنفر', nameKu: 'دێنڤەر', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 39.7392, longitude: -104.9903, timezoneId: 'America/Denver', utcOffsetStandard: -7.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Phoenix', nameEn: 'Phoenix', nameAr: 'فينيكس', nameKu: 'فینیکس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 33.4484, longitude: -112.0740, timezoneId: 'America/Phoenix', utcOffsetStandard: -7.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Philadelphia', nameEn: 'Philadelphia', nameAr: 'فيلادلفيا', nameKu: 'فیلادێلفیا', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 39.9526, longitude: -75.1652, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Detroit', nameEn: 'Detroit', nameAr: 'ديترويت', nameKu: 'دیترۆیت', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 42.3314, longitude: -83.0458, timezoneId: 'America/Detroit', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Columbus', nameEn: 'Columbus', nameAr: 'كولومبوس', nameKu: 'کۆلۆمبوس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 39.9612, longitude: -82.9988, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Atlanta', nameEn: 'Atlanta', nameAr: 'أتلانتا', nameKu: 'ئەتلانتا', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 33.7490, longitude: -84.3880, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Miami', nameEn: 'Miami', nameAr: 'ميامي', nameKu: 'میامی', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 25.7617, longitude: -80.1918, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Minneapolis', nameEn: 'Minneapolis', nameAr: 'مينيابوليس', nameKu: 'مینیاپۆلیس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 44.9778, longitude: -93.2650, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Boston', nameEn: 'Boston', nameAr: 'بوسطن', nameKu: 'بۆستن', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 42.3601, longitude: -71.0589, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
      ],
    ),

    // 16. Canada
    CountryGroup(
      id: 'canada',
      nameEn: 'Canada',
      nameAr: 'كندا',
      nameKu: 'کەنەدا',
      flag: '🇨🇦',
      cities: [
        WorldCity(id: 'Toronto', nameEn: 'Toronto', nameAr: 'تورونتو', nameKu: 'تۆرۆنتۆ', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 43.6532, longitude: -79.3832, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Montreal', nameEn: 'Montreal', nameAr: 'مونتريال', nameKu: 'مۆنتریال', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 45.5017, longitude: -73.5673, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Vancouver', nameEn: 'Vancouver', nameAr: 'فانكوفر', nameKu: 'ڤانکۆڤەر', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 49.2827, longitude: -123.1207, timezoneId: 'America/Vancouver', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Calgary', nameEn: 'Calgary', nameAr: 'كالغاري', nameKu: 'کالگاری', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 51.0447, longitude: -114.0719, timezoneId: 'America/Edmonton', utcOffsetStandard: -7.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Edmonton', nameEn: 'Edmonton', nameAr: 'إدمونتون', nameKu: 'ئێدمۆنتن', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 53.5461, longitude: -113.4938, timezoneId: 'America/Edmonton', utcOffsetStandard: -7.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Ottawa', nameEn: 'Ottawa', nameAr: 'أوتاوا', nameKu: 'ئۆتاوا', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 45.4215, longitude: -75.6972, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Winnipeg', nameEn: 'Winnipeg', nameAr: 'وينيبيغ', nameKu: 'وینیپێگ', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 49.8951, longitude: -97.1384, timezoneId: 'America/Winnipeg', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'QuebecCity', nameEn: 'Quebec City', nameAr: 'مدينة كيبك', nameKu: 'شاری کێبێک', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 46.8139, longitude: -71.2080, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'HamiltonCA', nameEn: 'Hamilton', nameAr: 'هاملتون', nameKu: 'هامیڵتن', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 43.2557, longitude: -79.8711, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Kitchener', nameEn: 'Kitchener / Waterloo', nameAr: 'كيتشنر', nameKu: 'کیچنەر', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 43.4516, longitude: -80.4925, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'LondonCA', nameEn: 'London, Ontario', nameAr: 'لندن (أونتاريو)', nameKu: 'لەندن (ئۆنتاریۆ)', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 42.9849, longitude: -81.2453, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'VictoriaCA', nameEn: 'Victoria', nameAr: 'فيكتوريا', nameKu: 'ڤیکتۆریا', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 48.4284, longitude: -123.3656, timezoneId: 'America/Vancouver', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'HalifaxCA', nameEn: 'Halifax', nameAr: 'هاليفاكس', nameKu: 'هالیفاکس', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 44.6488, longitude: -63.5752, timezoneId: 'America/Halifax', utcOffsetStandard: -4.0, recommendedMethodId: 'isna'),
      ],
    ),

    // Regional Group: Australia
    CountryGroup(
      id: 'australia',
      nameEn: 'Australia',
      nameAr: 'أستراليا',
      nameKu: 'ئوسترالیا',
      flag: '🇦🇺',
      cities: [
        WorldCity(id: 'Sydney', nameEn: 'Sydney', nameAr: 'سيدني', nameKu: 'سیدنی', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -33.8688, longitude: 151.2093, timezoneId: 'Australia/Sydney', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Melbourne', nameEn: 'Melbourne', nameAr: 'ملبورن', nameKu: 'مێلبۆرن', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -37.8136, longitude: 144.9631, timezoneId: 'Australia/Melbourne', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Brisbane', nameEn: 'Brisbane', nameAr: 'بريزبان', nameKu: 'بریزبێن', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -27.4698, longitude: 153.0251, timezoneId: 'Australia/Brisbane', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Perth', nameEn: 'Perth', nameAr: 'بيرث', nameKu: 'پێرس', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -31.9505, longitude: 115.8605, timezoneId: 'Australia/Perth', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Adelaide', nameEn: 'Adelaide', nameAr: 'أديلايد', nameKu: 'ئەدێلاید', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -34.9285, longitude: 138.6007, timezoneId: 'Australia/Adelaide', utcOffsetStandard: 9.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'GoldCoast', nameEn: 'Gold Coast', nameAr: 'غولد كوست', nameKu: 'گۆڵد کۆست', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -28.0167, longitude: 153.4000, timezoneId: 'Australia/Brisbane', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Canberra', nameEn: 'Canberra', nameAr: 'كانبرا', nameKu: 'کانبێرا', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -35.2809, longitude: 149.1300, timezoneId: 'Australia/Sydney', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'NewcastleAU', nameEn: 'Newcastle (NSW)', nameAr: 'نيوكاسل (أستراليا)', nameKu: 'نیوکاسڵی ئوسترالیا', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -32.9283, longitude: 151.7817, timezoneId: 'Australia/Sydney', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hobart', nameEn: 'Hobart (Tasmania)', nameAr: 'هوبارت (تسمانيا)', nameKu: 'هۆبارت', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -42.8821, longitude: 147.3272, timezoneId: 'Australia/Hobart', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Regional Group: New Zealand
    CountryGroup(
      id: 'new_zealand',
      nameEn: 'New Zealand',
      nameAr: 'نيوزيلندا',
      nameKu: 'نیوزیلەند',
      flag: '🇳🇿',
      cities: [
        WorldCity(id: 'Auckland', nameEn: 'Auckland', nameAr: 'أوكلاند', nameKu: 'ئۆکلاند', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -36.8485, longitude: 174.7633, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Wellington', nameEn: 'Wellington', nameAr: 'ويلينغتون', nameKu: 'ویلینگتۆن', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -41.2865, longitude: 174.7762, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Christchurch', nameEn: 'Christchurch', nameAr: 'كرايستشيرش', nameKu: 'کرایستچەرچ', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -43.5321, longitude: 172.6362, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'HamiltonNZ', nameEn: 'Hamilton', nameAr: 'هاملتون (نيوزيلندا)', nameKu: 'هامیڵتن (نیوزیلەند)', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -37.7870, longitude: 175.2793, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tauranga', nameEn: 'Tauranga', nameAr: 'تاورانغا', nameKu: 'تاورانگا', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -37.6878, longitude: 176.1651, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dunedin', nameEn: 'Dunedin', nameAr: 'دنيدن', nameKu: 'دۆنیدین', countryEn: 'New Zealand', countryAr: 'نيوزيلندا', countryKu: 'نیوزیلەند', latitude: -45.8788, longitude: 170.5028, timezoneId: 'Pacific/Auckland', utcOffsetStandard: 12.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Regional Group: Egypt
    CountryGroup(
      id: 'egypt',
      nameEn: 'Egypt',
      nameAr: 'مصر',
      nameKu: 'میسر',
      flag: '🇪🇬',
      cities: [
        WorldCity(id: 'Cairo', nameEn: 'Cairo', nameAr: 'القاهرة', nameKu: 'قاهیرە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.0444, longitude: 31.2357, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Alexandria', nameEn: 'Alexandria', nameAr: 'الإسكندرية', nameKu: 'ئەلێکساندریا', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 31.2001, longitude: 29.9187, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Giza', nameEn: 'Giza', nameAr: 'الجيزة', nameKu: 'جیزە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.0131, longitude: 31.2089, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'PortSaid', nameEn: 'Port Said', nameAr: 'بورسعيد', nameKu: 'بۆرسەعید', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 31.2653, longitude: 32.3019, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Suez', nameEn: 'Suez', nameAr: 'السويس', nameKu: 'سوێس', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 29.9668, longitude: 32.5498, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Mansoura', nameEn: 'Mansoura', nameAr: 'المنصورة', nameKu: 'مەنسوورە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 31.0409, longitude: 31.3785, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Tanta', nameEn: 'Tanta', nameAr: 'طنطا', nameKu: 'تەنتا', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.7865, longitude: 31.0004, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Luxor', nameEn: 'Luxor', nameAr: 'الأقصر', nameKu: 'لوکسۆر', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 25.6872, longitude: 32.6396, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Aswan', nameEn: 'Aswan', nameAr: 'أسوان', nameKu: 'ئەسوان', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 24.0889, longitude: 32.8998, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Asyut', nameEn: 'Asyut', nameAr: 'أسيوط', nameKu: 'ئەسیووت', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 27.1783, longitude: 31.1859, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Fayoum', nameEn: 'Fayoum', nameAr: 'الفيوم', nameKu: 'فەیوم', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 29.3084, longitude: 30.8428, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Zagazig', nameEn: 'Zagazig', nameAr: 'الزقازيق', nameKu: 'زەقازیق', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.5877, longitude: 31.5020, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Ismailia', nameEn: 'Ismailia', nameAr: 'الإسماعيلية', nameKu: 'ئیسماعیلیە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.5965, longitude: 32.2715, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Hurghada', nameEn: 'Hurghada', nameAr: 'الغردقة', nameKu: 'غەردەقە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 27.2579, longitude: 33.8116, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'SharmElSheikh', nameEn: 'Sharm El Sheikh', nameAr: 'شرم الشيخ', nameKu: 'شەرم شێخ', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 27.9158, longitude: 34.3299, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
      ],
    ),

    // Regional Group: Morocco
    CountryGroup(
      id: 'morocco',
      nameEn: 'Morocco',
      nameAr: 'المغرب',
      nameKu: 'مەغریب',
      flag: '🇲🇦',
      cities: [
        WorldCity(id: 'Casablanca', nameEn: 'Casablanca', nameAr: 'الدار البيضاء', nameKu: 'کازابلانکا', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 33.5731, longitude: -7.5898, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rabat', nameEn: 'Rabat', nameAr: 'الرباط', nameKu: 'ڕەبات', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 34.0209, longitude: -6.8416, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fes', nameEn: 'Fes', nameAr: 'فاس', nameKu: 'فاس', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 34.0181, longitude: -5.0078, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tangier', nameEn: 'Tangier', nameAr: 'طنجة', nameKu: 'تەنجە', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 35.7595, longitude: -5.8340, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Marrakesh', nameEn: 'Marrakesh', nameAr: 'مراكش', nameKu: 'مەراکش', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 31.6295, longitude: -7.9811, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Agadir', nameEn: 'Agadir', nameAr: 'أكادير', nameKu: 'ئاگادیر', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 30.4278, longitude: -9.5981, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Meknes', nameEn: 'Meknes', nameAr: 'مكناس', nameKu: 'مەکناس', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 33.8935, longitude: -5.5473, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oujda', nameEn: 'Oujda', nameAr: 'وجدة', nameKu: 'وەجدە', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 34.6814, longitude: -1.9086, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kenitra', nameEn: 'Kenitra', nameAr: 'القنيطرة', nameKu: 'قەنیتەرە', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 34.2610, longitude: -6.5802, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tetouan', nameEn: 'Tetouan', nameAr: 'تطوان', nameKu: 'تێتوان', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 35.5785, longitude: -5.3684, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nador', nameEn: 'Nador', nameAr: 'الناظور', nameKu: 'نازوور', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 35.1667, longitude: -2.9333, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Regional Group: Algeria
    CountryGroup(
      id: 'algeria',
      nameEn: 'Algeria',
      nameAr: 'الجزائر',
      nameKu: 'جەزائیر',
      flag: '🇩🇿',
      cities: [
        WorldCity(id: 'Algiers', nameEn: 'Algiers', nameAr: 'الجزائر', nameKu: 'جەزائیر', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.7538, longitude: 3.0588, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oran', nameEn: 'Oran', nameAr: 'وهران', nameKu: 'وێهران', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 35.6987, longitude: -0.6349, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Constantine', nameEn: 'Constantine', nameAr: 'قسنطينة', nameKu: 'قوستەنتینە', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.3650, longitude: 6.6147, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Annaba', nameEn: 'Annaba', nameAr: 'عنابة', nameKu: 'عەنابەی جەزائیر', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.9000, longitude: 7.7667, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Blida', nameEn: 'Blida', nameAr: 'البليدة', nameKu: 'بلیدە', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.4700, longitude: 2.8300, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Batna', nameEn: 'Batna', nameAr: 'باتنة', nameKu: 'باتنە', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 35.5559, longitude: 6.1741, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Setif', nameEn: 'Sétif', nameAr: 'سطيف', nameKu: 'سێتیف', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.1900, longitude: 5.4100, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tlemcen', nameEn: 'Tlemcen', nameAr: 'تلمسان', nameKu: 'تلمسان', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 34.8783, longitude: -1.3150, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Biskra', nameEn: 'Biskra', nameAr: 'بسكرة', nameKu: 'بیسکرە', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 34.8500, longitude: 5.7333, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Regional Group: Tunisia
    CountryGroup(
      id: 'tunisia',
      nameEn: 'Tunisia',
      nameAr: 'تونس',
      nameKu: 'توونس',
      flag: '🇹🇳',
      cities: [
        WorldCity(id: 'Tunis', nameEn: 'Tunis', nameAr: 'تونس', nameKu: 'توونس', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 36.8065, longitude: 10.1815, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Sfax', nameEn: 'Sfax', nameAr: 'صفاقس', nameKu: 'سفاکس', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 34.7406, longitude: 10.7603, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Sousse', nameEn: 'Sousse', nameAr: 'سوسة', nameKu: 'سوسە', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 35.8254, longitude: 10.6369, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Kairouan', nameEn: 'Kairouan', nameAr: 'القيروان', nameKu: 'قەیرەوان', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 35.6781, longitude: 10.0963, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Bizerte', nameEn: 'Bizerte', nameAr: 'بنزرت', nameKu: 'بێنزەرت', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 37.2744, longitude: 9.8739, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Gabes', nameEn: 'Gabès', nameAr: 'قابس', nameKu: 'قابیس', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 33.8815, longitude: 10.0982, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
        WorldCity(id: 'Monastir', nameEn: 'Monastir', nameAr: 'المنستير', nameKu: 'مۆناستیر', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 35.7780, longitude: 10.8262, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'tunisia'),
      ],
    ),

    // Regional Group: Libya
    CountryGroup(
      id: 'libya',
      nameEn: 'Libya',
      nameAr: 'ليبيا',
      nameKu: 'لیبیا',
      flag: '🇱🇾',
      cities: [
        WorldCity(id: 'TripoliLibya', nameEn: 'Tripoli', nameAr: 'طرابلس الغرب', nameKu: 'تەرابلوسی لیبیا', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.8872, longitude: 13.1913, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Benghazi', nameEn: 'Benghazi', nameAr: 'بنغازي', nameKu: 'بەنغازی', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.1167, longitude: 20.0667, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Misrata', nameEn: 'Misrata', nameAr: 'مصراتة', nameKu: 'میسراتە', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.3754, longitude: 15.0925, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Bayda', nameEn: 'Bayda', nameAr: 'البيضاء', nameKu: 'بەیزا', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.7628, longitude: 21.7551, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Zawiya', nameEn: 'Zawiya', nameAr: 'الزاوية', nameKu: 'زاویە', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.7522, longitude: 12.7278, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Tobruk', nameEn: 'Tobruk', nameAr: 'طبرق', nameKu: 'تۆبروک', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 32.0836, longitude: 23.9764, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Sebha', nameEn: 'Sebha', nameAr: 'سبها', nameKu: 'سەبها', countryEn: 'Libya', countryAr: 'ليبيا', countryKu: 'لیبیا', latitude: 27.0377, longitude: 14.4283, timezoneId: 'Africa/Tripoli', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
      ],
    ),

    // Regional Group: Sudan
    CountryGroup(
      id: 'sudan',
      nameEn: 'Sudan',
      nameAr: 'السودان',
      nameKu: 'سوودان',
      flag: '🇸🇩',
      cities: [
        WorldCity(id: 'Khartoum', nameEn: 'Khartoum', nameAr: 'الخرطوم', nameKu: 'خەرتووم', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 15.5007, longitude: 32.5599, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Omdurman', nameEn: 'Omdurman', nameAr: 'أم درمان', nameKu: 'ئوم دورمان', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 15.6500, longitude: 32.4800, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'PortSudan', nameEn: 'Port Sudan', nameAr: 'بورتسودان', nameKu: 'بۆرتسوودان', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 19.6175, longitude: 37.2164, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Kassala', nameEn: 'Kassala', nameAr: 'كسلا', nameKu: 'کەسەلا', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 15.4510, longitude: 36.4000, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Nyala', nameEn: 'Nyala', nameAr: 'نيالا', nameKu: 'نیالا', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 12.0500, longitude: 24.8833, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'WadMadani', nameEn: 'Wad Madani', nameAr: 'ود مدني', nameKu: 'وەد مەدەنی', countryEn: 'Sudan', countryAr: 'السودان', countryKu: 'سوودان', latitude: 14.4000, longitude: 33.5167, timezoneId: 'Africa/Khartoum', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
      ],
    ),

    // Global Country/Region: Pakistan
    CountryGroup(
      id: 'pakistan',
      nameEn: 'Pakistan',
      nameAr: 'باكستان',
      nameKu: 'پاکستان',
      flag: '🇵🇰',
      cities: [
        WorldCity(id: 'Karachi', nameEn: 'Karachi', nameAr: 'كراتشي', nameKu: 'کراچی', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 24.8607, longitude: 67.0011, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Lahore', nameEn: 'Lahore', nameAr: 'لاهور', nameKu: 'لاهوور', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 31.5204, longitude: 74.3587, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Islamabad', nameEn: 'Islamabad', nameAr: 'إسلام آباد', nameKu: 'ئیسلام ئاباد', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 33.6844, longitude: 73.0479, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Rawalpindi', nameEn: 'Rawalpindi', nameAr: 'راولبندي', nameKu: 'ڕاوەڵپیندی', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 33.5651, longitude: 73.0169, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Faisalabad', nameEn: 'Faisalabad', nameAr: 'فيصل آباد', nameKu: 'فەیسەڵئاباد', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 31.4504, longitude: 73.1350, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Peshawar', nameEn: 'Peshawar', nameAr: 'بيشاور', nameKu: 'پێشاوەر', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 34.0151, longitude: 71.5249, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Quetta', nameEn: 'Quetta', nameAr: 'كويته', nameKu: 'کۆیەتا', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 30.1798, longitude: 66.9750, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Multan', nameEn: 'Multan', nameAr: 'مولتان', nameKu: 'مۆڵتان', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 30.1575, longitude: 71.5249, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Gujranwala', nameEn: 'Gujranwala', nameAr: 'غوجرانوالا', nameKu: 'گوجرانوالا', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 32.1617, longitude: 74.1883, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Sialkot', nameEn: 'Sialkot', nameAr: 'سيالكوت', nameKu: 'سیالکۆت', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 32.4925, longitude: 74.5311, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'HyderabadPK', nameEn: 'Hyderabad (Sindh)', nameAr: 'حيدر آباد (السند)', nameKu: 'حەیدەرئاباد (سند)', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 25.3960, longitude: 68.3578, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Muzaffarabad', nameEn: 'Muzaffarabad (Azad Kashmir)', nameAr: 'مظفر آباد', nameKu: 'موزەفەرئاباد', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 34.3700, longitude: 73.4711, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Gilgit', nameEn: 'Gilgit', nameAr: 'غلغت', nameKu: 'گیلگیت', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 35.9208, longitude: 74.3144, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
      ],
    ),

    // Global Country/Region: India
    CountryGroup(
      id: 'india',
      nameEn: 'India',
      nameAr: 'الهند',
      nameKu: 'هیندستان',
      flag: '🇮🇳',
      cities: [
        WorldCity(id: 'NewDelhi', nameEn: 'New Delhi', nameAr: 'نيودلهي', nameKu: 'نیودەلهی', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 28.6139, longitude: 77.2090, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Mumbai', nameEn: 'Mumbai', nameAr: 'مومباي', nameKu: 'مومبای', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 19.0760, longitude: 72.8777, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'HyderabadIN', nameEn: 'Hyderabad (Telangana)', nameAr: 'حيدر آباد (تلنغانة)', nameKu: 'حەیدەرئاباد', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 17.3850, longitude: 78.4867, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Bangalore', nameEn: 'Bangalore (Bengaluru)', nameAr: 'بنغالور', nameKu: 'بەنگالۆر', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 12.9716, longitude: 77.5946, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Chennai', nameEn: 'Chennai', nameAr: 'تشيناي', nameKu: 'چینای', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 13.0827, longitude: 80.2707, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Kolkata', nameEn: 'Kolkata', nameAr: 'كولكاتا', nameKu: 'کۆلکاتا', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 22.5726, longitude: 88.3639, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Ahmedabad', nameEn: 'Ahmedabad', nameAr: 'أحمد آباد', nameKu: 'ئەحمەدئاباد', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 23.0225, longitude: 72.5714, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Lucknow', nameEn: 'Lucknow', nameAr: 'لكناو', nameKu: 'لوکنەو', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 26.8467, longitude: 80.9462, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Srinagar', nameEn: 'Srinagar (Kashmir)', nameAr: 'سريناغار (كشمير)', nameKu: 'سرینگار (کشمیر)', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 34.0837, longitude: 74.7973, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Bhopal', nameEn: 'Bhopal', nameAr: 'بوبال', nameKu: 'بۆپال', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 23.2599, longitude: 77.4126, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Surat', nameEn: 'Surat', nameAr: 'سورت', nameKu: 'سورات', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 21.1702, longitude: 72.8311, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Pune', nameEn: 'Pune', nameAr: 'بونا', nameKu: 'پونێ', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 18.5204, longitude: 73.8567, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Patna', nameEn: 'Patna', nameAr: 'باتنا', nameKu: 'پاتنا', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 25.5941, longitude: 85.1376, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Calicut', nameEn: 'Kozhikode (Calicut - Kerala)', nameAr: 'كاليكوت (كيرلا)', nameKu: 'کالیکۆت (کێرالا)', countryEn: 'India', countryAr: 'الهند', countryKu: 'هیندستان', latitude: 11.2588, longitude: 75.7804, timezoneId: 'Asia/Kolkata', utcOffsetStandard: 5.5, recommendedMethodId: 'karachi'),
      ],
    ),

    // Global Country/Region: Bangladesh
    CountryGroup(
      id: 'bangladesh',
      nameEn: 'Bangladesh',
      nameAr: 'بنغلاديش',
      nameKu: 'بەنگلادیش',
      flag: '🇧🇩',
      cities: [
        WorldCity(id: 'Dhaka', nameEn: 'Dhaka', nameAr: 'دكا', nameKu: 'داکا', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 23.8103, longitude: 90.4125, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Chittagong', nameEn: 'Chittagong (Chattogram)', nameAr: 'شيتاغونغ', nameKu: 'چیتاگۆنگ', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 22.3569, longitude: 91.7832, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Sylhet', nameEn: 'Sylhet', nameAr: 'سلهت', nameKu: 'سیلهێت', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 24.8949, longitude: 91.8687, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Rajshahi', nameEn: 'Rajshahi', nameAr: 'راجشاهي', nameKu: 'ڕاجشاهی', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 24.3745, longitude: 88.6042, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Khulna', nameEn: 'Khulna', nameAr: 'خولنا', nameKu: 'خوڵنا', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 22.8456, longitude: 89.5403, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Barisal', nameEn: 'Barisal', nameAr: 'باريسال', nameKu: 'باریسال', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 22.7010, longitude: 90.3535, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Rangpur', nameEn: 'Rangpur', nameAr: 'رانغبور', nameKu: 'ڕەنگپور', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 25.7439, longitude: 89.2752, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Comilla', nameEn: 'Comilla (Cumilla)', nameAr: 'كوميلا', nameKu: 'کۆمیلا', countryEn: 'Bangladesh', countryAr: 'بنغلاديش', countryKu: 'بەنگلادیش', latitude: 23.4682, longitude: 91.1788, timezoneId: 'Asia/Dhaka', utcOffsetStandard: 6.0, recommendedMethodId: 'karachi'),
      ],
    ),

    // Global Country/Region: Afghanistan
    CountryGroup(
      id: 'afghanistan',
      nameEn: 'Afghanistan',
      nameAr: 'أفغانستان',
      nameKu: 'ئەفغانستان',
      flag: '🇦🇫',
      cities: [
        WorldCity(id: 'Kabul', nameEn: 'Kabul', nameAr: 'كابول', nameKu: 'کابول', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 34.5553, longitude: 69.2075, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Herat', nameEn: 'Herat', nameAr: 'هرات', nameKu: 'هێرات', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 34.3529, longitude: 62.2040, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'MazarISharif', nameEn: 'Mazar-i-Sharif', nameAr: 'مزار شريف', nameKu: 'مەزاری شەریف', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 36.7090, longitude: 67.1109, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Kandahar', nameEn: 'Kandahar', nameAr: 'قندهار', nameKu: 'قەندەهار', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 31.6289, longitude: 65.7372, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Jalalabad', nameEn: 'Jalalabad', nameAr: 'جلال آباد', nameKu: 'جەلالئاباد', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 34.4265, longitude: 70.4515, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Kunduz', nameEn: 'Kunduz', nameAr: 'قندوز', nameKu: 'قۆندۆز', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 36.7289, longitude: 68.8570, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Ghazni', nameEn: 'Ghazni', nameAr: 'غزني', nameKu: 'غەزنی', countryEn: 'Afghanistan', countryAr: 'أفغانستان', countryKu: 'ئەفغانستان', latitude: 33.5539, longitude: 68.4209, timezoneId: 'Asia/Kabul', utcOffsetStandard: 4.5, recommendedMethodId: 'karachi'),
      ],
    ),

    // Global Country/Region: Sri Lanka & Maldives
    CountryGroup(
      id: 'sri_lanka_maldives',
      nameEn: 'Sri Lanka & Maldives',
      nameAr: 'سريلانكا والمالديف',
      nameKu: 'سریلانکا و مالدیڤ',
      flag: '🇱🇰',
      cities: [
        WorldCity(id: 'Colombo', nameEn: 'Colombo', nameAr: 'كولومبو', nameKu: 'کۆلۆمبۆ', countryEn: 'Sri Lanka & Maldives', countryAr: 'سريلانكا والمالديف', countryKu: 'سریلانکا و مالدیڤ', latitude: 6.9271, longitude: 79.8612, timezoneId: 'Asia/Colombo', utcOffsetStandard: 5.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kandy', nameEn: 'Kandy', nameAr: 'كاندي', nameKu: 'کاندی', countryEn: 'Sri Lanka & Maldives', countryAr: 'سريلانكا والمالديف', countryKu: 'سریلانکا و مالدیڤ', latitude: 7.2906, longitude: 80.6337, timezoneId: 'Asia/Colombo', utcOffsetStandard: 5.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Galle', nameEn: 'Galle', nameAr: 'غالي', nameKu: 'گالی', countryEn: 'Sri Lanka & Maldives', countryAr: 'سريلانكا والمالديف', countryKu: 'سریلانکا و مالدیڤ', latitude: 6.0535, longitude: 80.2210, timezoneId: 'Asia/Colombo', utcOffsetStandard: 5.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Male', nameEn: 'Malé', nameAr: 'ماليه', nameKu: 'مالێ', countryEn: 'Sri Lanka & Maldives', countryAr: 'سريلانكا والمالديف', countryKu: 'سریلانکا و مالدیڤ', latitude: 4.1755, longitude: 73.5093, timezoneId: 'Indian/Maldives', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Indonesia
    CountryGroup(
      id: 'indonesia',
      nameEn: 'Indonesia',
      nameAr: 'إندونيسيا',
      nameKu: 'ئەندەنوسیا',
      flag: '🇮🇩',
      cities: [
        WorldCity(id: 'Jakarta', nameEn: 'Jakarta', nameAr: 'جاكرتا', nameKu: 'جاکارتا', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -6.2088, longitude: 106.8456, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Surabaya', nameEn: 'Surabaya', nameAr: 'سورابايا', nameKu: 'سورابایا', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -7.2575, longitude: 112.7521, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Bandung', nameEn: 'Bandung', nameAr: 'باندونغ', nameKu: 'باندۆنگ', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -6.9175, longitude: 107.6191, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Medan', nameEn: 'Medan', nameAr: 'ميدان', nameKu: 'مێدان', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: 3.5952, longitude: 98.6722, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Semarang', nameEn: 'Semarang', nameAr: 'سمارانغ', nameKu: 'سێمارانگ', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -6.9667, longitude: 110.4167, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Makassar', nameEn: 'Makassar', nameAr: 'ماكاسار', nameKu: 'ماکاسار', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -5.1477, longitude: 119.4327, timezoneId: 'Asia/Makassar', utcOffsetStandard: 8.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Palembang', nameEn: 'Palembang', nameAr: 'بالمبانغ', nameKu: 'پالێمبانگ', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -2.9761, longitude: 104.7754, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'BandaAceh', nameEn: 'Banda Aceh', nameAr: 'باندا آتشيه', nameKu: 'باندا ئاچێ', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: 5.5483, longitude: 95.3238, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Yogyakarta', nameEn: 'Yogyakarta', nameAr: 'يوغياكارتا', nameKu: 'یۆگیاکارتا', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -7.7956, longitude: 110.3695, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Denpasar', nameEn: 'Denpasar (Bali)', nameAr: 'دنپاسار (بالي)', nameKu: 'دێنپاسار (بالی)', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -8.6705, longitude: 115.2126, timezoneId: 'Asia/Makassar', utcOffsetStandard: 8.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Banjarmasin', nameEn: 'Banjarmasin', nameAr: 'بنجارماسين', nameKu: 'بانجارماسین', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -3.3194, longitude: 114.5908, timezoneId: 'Asia/Makassar', utcOffsetStandard: 8.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Padang', nameEn: 'Padang', nameAr: 'بادنغ', nameKu: 'پادانگ', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -0.9471, longitude: 100.4172, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
      ],
    ),

    // Global Country/Region: Malaysia
    CountryGroup(
      id: 'malaysia',
      nameEn: 'Malaysia',
      nameAr: 'ماليزيا',
      nameKu: 'مالیزیا',
      flag: '🇲🇾',
      cities: [
        WorldCity(id: 'KualaLumpur', nameEn: 'Kuala Lumpur', nameAr: 'كوالالمبور', nameKu: 'کوالالامپور', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 3.1390, longitude: 101.6869, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Putrajaya', nameEn: 'Putrajaya', nameAr: 'بوتراجاي', nameKu: 'پوتراجایا', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 2.9264, longitude: 101.6964, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Penang', nameEn: 'George Town / Penang', nameAr: 'جورج تاون (بينانغ)', nameKu: 'پێنانگ', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 5.4164, longitude: 100.3327, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'JohorBahru', nameEn: 'Johor Bahru', nameAr: 'جوهور بهرو', nameKu: 'جۆهۆر باهرو', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 1.4927, longitude: 103.7414, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Ipoh', nameEn: 'Ipoh', nameAr: 'إيبوه', nameKu: 'ئیپۆه', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 4.5975, longitude: 101.0901, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'ShahAlam', nameEn: 'Shah Alam', nameAr: 'شاه عالم', nameKu: 'شاە عەلەم', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 3.0738, longitude: 101.5183, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Malacca', nameEn: 'Malacca', nameAr: 'ملقا', nameKu: 'مەلەقا', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 2.1896, longitude: 102.2501, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'KotaKinabalu', nameEn: 'Kota Kinabalu (Sabah)', nameAr: 'كوتا كينابالو', nameKu: 'کۆتا کینابالو', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 5.9804, longitude: 116.0735, timezoneId: 'Asia/Kuching', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Kuching', nameEn: 'Kuching (Sarawak)', nameAr: 'كوتشينغ', nameKu: 'کوچینگ', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 1.5535, longitude: 110.3592, timezoneId: 'Asia/Kuching', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'KotaBharu', nameEn: 'Kota Bharu', nameAr: 'كوتا بهارو', nameKu: 'کۆتا بارۆ', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 6.1254, longitude: 102.2386, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Kuantan', nameEn: 'Kuantan', nameAr: 'كوانتان', nameKu: 'کوانتان', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 3.8077, longitude: 103.3260, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
      ],
    ),

    // Global Country/Region: Singapore & Brunei
    CountryGroup(
      id: 'singapore_brunei',
      nameEn: 'Singapore & Brunei',
      nameAr: 'سنغافورة وبروناي',
      nameKu: 'سەنگافورە و برۆنای',
      flag: '🇸🇬',
      cities: [
        WorldCity(id: 'Singapore', nameEn: 'Singapore', nameAr: 'سنغافورة', nameKu: 'سەنگافورە', countryEn: 'Singapore & Brunei', countryAr: 'سنغافورة وبروناي', countryKu: 'سەنگافورە و برۆنای', latitude: 1.3521, longitude: 103.8198, timezoneId: 'Asia/Singapore', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'BandarSeriBegawan', nameEn: 'Bandar Seri Begawan', nameAr: 'بندر سري بكاوان', nameKu: 'بەندەر سێری بێگاوان', countryEn: 'Singapore & Brunei', countryAr: 'سنغافورة وبروناي', countryKu: 'سەنگافورە و برۆنای', latitude: 4.9031, longitude: 114.9398, timezoneId: 'Asia/Brunei', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
      ],
    ),

    // Global Country/Region: Thailand & Philippines
    CountryGroup(
      id: 'thailand_philippines',
      nameEn: 'Thailand & Philippines',
      nameAr: 'تايلاند والفلبين',
      nameKu: 'تایلەند و فیلیپین',
      flag: '🇹🇭',
      cities: [
        WorldCity(id: 'Bangkok', nameEn: 'Bangkok', nameAr: 'بانكوك', nameKu: 'بانکۆک', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 13.7563, longitude: 100.5018, timezoneId: 'Asia/Bangkok', utcOffsetStandard: 7.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'HatYai', nameEn: 'Hat Yai', nameAr: 'هات ياي', nameKu: 'هات یای', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 7.0084, longitude: 100.4767, timezoneId: 'Asia/Bangkok', utcOffsetStandard: 7.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pattani', nameEn: 'Pattani', nameAr: 'فطاني', nameKu: 'پاتانی', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 6.8674, longitude: 101.2501, timezoneId: 'Asia/Bangkok', utcOffsetStandard: 7.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Yala', nameEn: 'Yala', nameAr: 'يالا', nameKu: 'یالا', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 6.5411, longitude: 101.2813, timezoneId: 'Asia/Bangkok', utcOffsetStandard: 7.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Phuket', nameEn: 'Phuket', nameAr: 'بوكيت', nameKu: 'پوکێت', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 7.8804, longitude: 98.3923, timezoneId: 'Asia/Bangkok', utcOffsetStandard: 7.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Manila', nameEn: 'Manila', nameAr: 'مانيلا', nameKu: 'مانیلا', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 14.5995, longitude: 120.9842, timezoneId: 'Asia/Manila', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cotabato', nameEn: 'Cotabato City (Bangsamoro)', nameAr: 'كوتاباتو', nameKu: 'کۆتاباتۆ', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 7.2236, longitude: 124.2464, timezoneId: 'Asia/Manila', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Zamboanga', nameEn: 'Zamboanga City', nameAr: 'زامبوانغا', nameKu: 'زامبوانگا', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 6.9214, longitude: 122.0790, timezoneId: 'Asia/Manila', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Marawi', nameEn: 'Marawi City (Bangsamoro)', nameAr: 'مراوي', nameKu: 'ماراوی', countryEn: 'Thailand & Philippines', countryAr: 'تايلاند والفلبين', countryKu: 'تایلەند و فیلیپین', latitude: 8.0039, longitude: 124.2858, timezoneId: 'Asia/Manila', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Uzbekistan
    CountryGroup(
      id: 'uzbekistan',
      nameEn: 'Uzbekistan',
      nameAr: 'أوزبكستان',
      nameKu: 'ئۆزبەکستان',
      flag: '🇺🇿',
      cities: [
        WorldCity(id: 'Tashkent', nameEn: 'Tashkent', nameAr: 'طشقند', nameKu: 'تاشکەند', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 41.2995, longitude: 69.2401, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Samarkand', nameEn: 'Samarkand', nameAr: 'سمرقند', nameKu: 'سەمەرقەند', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 39.6542, longitude: 66.9597, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bukhara', nameEn: 'Bukhara', nameAr: 'بخارى', nameKu: 'بوخارا', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 39.7747, longitude: 64.4286, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Namangan', nameEn: 'Namangan', nameAr: 'نمنغان', nameKu: 'نامەنگان', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 40.9983, longitude: 71.6726, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Andijan', nameEn: 'Andijan', nameAr: 'أنديجان', nameKu: 'ئەندیجان', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 40.7821, longitude: 72.3442, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fergana', nameEn: 'Fergana', nameAr: 'فرغانة', nameKu: 'فەرغانە', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 40.3842, longitude: 71.7843, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Khiva', nameEn: 'Khiva', nameAr: 'خيوة', nameKu: 'خیڤا', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 41.3783, longitude: 60.3639, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nukus', nameEn: 'Nukus (Karakalpakstan)', nameAr: 'نوكوس', nameKu: 'نوکوس', countryEn: 'Uzbekistan', countryAr: 'أوزبكستان', countryKu: 'ئۆزبەکستان', latitude: 42.4602, longitude: 59.6166, timezoneId: 'Asia/Tashkent', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Kazakhstan
    CountryGroup(
      id: 'kazakhstan',
      nameEn: 'Kazakhstan',
      nameAr: 'كازاخستان',
      nameKu: 'کازاخستان',
      flag: '🇰🇿',
      cities: [
        WorldCity(id: 'Almaty', nameEn: 'Almaty', nameAr: 'ألماتي', nameKu: 'ئالماتی', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 43.2220, longitude: 76.8512, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Astana', nameEn: 'Astana', nameAr: 'أستانا', nameKu: 'ئاستانا', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 51.1694, longitude: 71.4491, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Shymkent', nameEn: 'Shymkent', nameAr: 'شيمكنت', nameKu: 'شیمکێنت', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 42.3417, longitude: 69.5901, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aktobe', nameEn: 'Aktobe', nameAr: 'أكتوبي', nameKu: 'ئاکتۆبێ', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 50.2839, longitude: 57.1670, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Karaganda', nameEn: 'Karaganda', nameAr: 'قراغندي', nameKu: 'قەرەغەندی', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 49.8019, longitude: 73.1021, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Taraz', nameEn: 'Taraz', nameAr: 'طراز', nameKu: 'تەراز', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 42.9000, longitude: 71.3667, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pavlodar', nameEn: 'Pavlodar', nameAr: 'بافلودار', nameKu: 'پاڤلۆدار', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 52.2878, longitude: 76.9674, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Atyrau', nameEn: 'Atyrau', nameAr: 'أتيراو', nameKu: 'ئاتێراو', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 47.1167, longitude: 51.8833, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Semey', nameEn: 'Semey', nameAr: 'سيماي', nameKu: 'سێمێی', countryEn: 'Kazakhstan', countryAr: 'كازاخستان', countryKu: 'کازاخستان', latitude: 50.4111, longitude: 80.2275, timezoneId: 'Asia/Almaty', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Kyrgyzstan
    CountryGroup(
      id: 'kyrgyzstan',
      nameEn: 'Kyrgyzstan',
      nameAr: 'قيرغيزستان',
      nameKu: 'قیڕغیزستان',
      flag: '🇰🇬',
      cities: [
        WorldCity(id: 'Bishkek', nameEn: 'Bishkek', nameAr: 'بيشكك', nameKu: 'بیشکێک', countryEn: 'Kyrgyzstan', countryAr: 'قيرغيزستان', countryKu: 'قیڕغیزستان', latitude: 42.8746, longitude: 74.5698, timezoneId: 'Asia/Bishkek', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Osh', nameEn: 'Osh', nameAr: 'أوش', nameKu: 'ئۆش', countryEn: 'Kyrgyzstan', countryAr: 'قيرغيزستان', countryKu: 'قیڕغیزستان', latitude: 40.5283, longitude: 72.7985, timezoneId: 'Asia/Bishkek', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'JalalAbadKG', nameEn: 'Jalal-Abad', nameAr: 'جلال آباد (قيرغيزستان)', nameKu: 'جەلالئاباد', countryEn: 'Kyrgyzstan', countryAr: 'قيرغيزستان', countryKu: 'قیڕغیزستان', latitude: 40.9333, longitude: 72.9833, timezoneId: 'Asia/Bishkek', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Karakol', nameEn: 'Karakol', nameAr: 'كاراكول', nameKu: 'کاراکۆل', countryEn: 'Kyrgyzstan', countryAr: 'قيرغيزستان', countryKu: 'قیڕغیزستان', latitude: 42.4907, longitude: 78.3936, timezoneId: 'Asia/Bishkek', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Tajikistan
    CountryGroup(
      id: 'tajikistan',
      nameEn: 'Tajikistan',
      nameAr: 'طاجيكستان',
      nameKu: 'تاجیکستان',
      flag: '🇹🇯',
      cities: [
        WorldCity(id: 'Dushanbe', nameEn: 'Dushanbe', nameAr: 'دوشنبه', nameKu: 'دوشەنبە', countryEn: 'Tajikistan', countryAr: 'طاجيكستان', countryKu: 'تاجیکستان', latitude: 38.5598, longitude: 68.7870, timezoneId: 'Asia/Dushanbe', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Khujand', nameEn: 'Khujand', nameAr: 'خجندة', nameKu: 'خوجەند', countryEn: 'Tajikistan', countryAr: 'طاجيكستان', countryKu: 'تاجیکستان', latitude: 40.2826, longitude: 69.6222, timezoneId: 'Asia/Dushanbe', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bokhtar', nameEn: 'Bokhtar (Qurghonteppa)', nameAr: 'بوختار', nameKu: 'بۆختار', countryEn: 'Tajikistan', countryAr: 'طاجيكستان', countryKu: 'تاجیکستان', latitude: 37.8364, longitude: 68.7803, timezoneId: 'Asia/Dushanbe', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kulob', nameEn: 'Kulob', nameAr: 'كولاب', nameKu: 'کولۆب', countryEn: 'Tajikistan', countryAr: 'طاجيكستان', countryKu: 'تاجیکستان', latitude: 37.9147, longitude: 69.7850, timezoneId: 'Asia/Dushanbe', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Turkmenistan
    CountryGroup(
      id: 'turkmenistan',
      nameEn: 'Turkmenistan',
      nameAr: 'تركمانستان',
      nameKu: 'تورکمانستان',
      flag: '🇹🇲',
      cities: [
        WorldCity(id: 'Ashgabat', nameEn: 'Ashgabat', nameAr: 'عشق آباد', nameKu: 'عەشقاباد', countryEn: 'Turkmenistan', countryAr: 'تركمانستان', countryKu: 'تورکمانستان', latitude: 37.9601, longitude: 58.3261, timezoneId: 'Asia/Ashgabat', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Turkmenabat', nameEn: 'Turkmenabat', nameAr: 'تركمن أباد', nameKu: 'تورکمانئاباد', countryEn: 'Turkmenistan', countryAr: 'تركمانستان', countryKu: 'تورکمانستان', latitude: 39.0733, longitude: 63.5786, timezoneId: 'Asia/Ashgabat', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'MaryTM', nameEn: 'Mary', nameAr: 'مرو', nameKu: 'مەروو', countryEn: 'Turkmenistan', countryAr: 'تركمانستان', countryKu: 'تورکمانستان', latitude: 37.5958, longitude: 61.8294, timezoneId: 'Asia/Ashgabat', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dasoguz', nameEn: 'Daşoguz', nameAr: 'داش أوغوز', nameKu: 'داشئۆغوز', countryEn: 'Turkmenistan', countryAr: 'تركمانستان', countryKu: 'تورکمانستان', latitude: 41.8361, longitude: 59.9667, timezoneId: 'Asia/Ashgabat', utcOffsetStandard: 5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Japan
    CountryGroup(
      id: 'japan',
      nameEn: 'Japan',
      nameAr: 'اليابان',
      nameKu: 'ژاپۆن',
      flag: '🇯🇵',
      cities: [
        WorldCity(id: 'Tokyo', nameEn: 'Tokyo', nameAr: 'طوكيو', nameKu: 'تۆکیۆ', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 35.6762, longitude: 139.6503, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Osaka', nameEn: 'Osaka', nameAr: 'أوساكا', nameKu: 'ئۆساکا', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 34.6937, longitude: 135.5023, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kyoto', nameEn: 'Kyoto', nameAr: 'كيوتو', nameKu: 'کیۆتۆ', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 35.0116, longitude: 135.7681, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nagoya', nameEn: 'Nagoya', nameAr: 'ناغويا', nameKu: 'ناگۆیا', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 35.1815, longitude: 136.9066, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Yokohama', nameEn: 'Yokohama', nameAr: 'يوكوهاما', nameKu: 'یۆکۆهاما', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 35.4437, longitude: 139.6380, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kobe', nameEn: 'Kobe', nameAr: 'كوبي', nameKu: 'کۆبێ', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 34.6901, longitude: 135.1955, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Fukuoka', nameEn: 'Fukuoka', nameAr: 'فوكوكا', nameKu: 'فوکوئۆکا', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 33.5902, longitude: 130.4017, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sapporo', nameEn: 'Sapporo', nameAr: 'سابورو', nameKu: 'ساپۆرۆ', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 43.0618, longitude: 141.3545, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hiroshima', nameEn: 'Hiroshima', nameAr: 'هيروشيما', nameKu: 'هێرۆشیما', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 34.3853, longitude: 132.4553, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: South Korea
    CountryGroup(
      id: 'south_korea',
      nameEn: 'South Korea',
      nameAr: 'كوريا الجنوبية',
      nameKu: 'کۆریای باشوور',
      flag: '🇰🇷',
      cities: [
        WorldCity(id: 'Seoul', nameEn: 'Seoul', nameAr: 'سيول', nameKu: 'سیئۆل', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 37.5665, longitude: 126.9780, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Busan', nameEn: 'Busan', nameAr: 'بوسان', nameKu: 'بوسان', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 35.1796, longitude: 129.0756, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Incheon', nameEn: 'Incheon', nameAr: 'إنتشون', nameKu: 'ئینچۆن', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 37.4563, longitude: 126.7052, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Daegu', nameEn: 'Daegu', nameAr: 'دايغو', nameKu: 'دایگو', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 35.8714, longitude: 128.6014, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Daejeon', nameEn: 'Daejeon', nameAr: 'دايجون', nameKu: 'دایجۆن', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 36.3504, longitude: 127.3845, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gwangju', nameEn: 'Gwangju', nameAr: 'غوانغجو', nameKu: 'گوانگجو', countryEn: 'South Korea', countryAr: 'كوريا الجنوبية', countryKu: 'کۆریای باشوور', latitude: 35.1595, longitude: 126.8526, timezoneId: 'Asia/Seoul', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: China
    CountryGroup(
      id: 'china',
      nameEn: 'China',
      nameAr: 'الصين',
      nameKu: 'چین (تورکستانی ڕۆژهەڵات)',
      flag: '🇨🇳',
      cities: [
        WorldCity(id: 'Beijing', nameEn: 'Beijing', nameAr: 'بكين', nameKu: 'پەکین', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 39.9042, longitude: 116.4074, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Shanghai', nameEn: 'Shanghai', nameAr: 'شنغهاي', nameKu: 'شەنگهای', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 31.2304, longitude: 121.4737, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Guangzhou', nameEn: 'Guangzhou', nameAr: 'غوانغتشو', nameKu: 'گوانگژۆو', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 23.1291, longitude: 113.2644, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Shenzhen', nameEn: 'Shenzhen', nameAr: 'شنجن', nameKu: 'شێنزێن', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 22.5431, longitude: 114.0579, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'XianCN', nameEn: 'Xi\'an', nameAr: 'شيان', nameKu: 'شیان', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 34.3416, longitude: 108.9398, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Urumqi', nameEn: 'Ürümqi (East Turkestan)', nameAr: 'أورومتشي', nameKu: 'ئورومچی (تورکستانی ڕۆژهەڵات)', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 43.8256, longitude: 87.6168, timezoneId: 'Asia/Urumqi', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kashgar', nameEn: 'Kashgar (Qeshqer)', nameAr: 'كاشغر', nameKu: 'کاشغەر (قەشقەر)', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 39.4677, longitude: 75.9897, timezoneId: 'Asia/Urumqi', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Yining', nameEn: 'Ghulja / Yining', nameAr: 'غولدجا', nameKu: 'غوڵجا', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 43.9167, longitude: 81.3333, timezoneId: 'Asia/Urumqi', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hotan', nameEn: 'Hotan (Khotan)', nameAr: 'ختن', nameKu: 'خۆتان', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 37.1142, longitude: 79.9222, timezoneId: 'Asia/Urumqi', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Turpan', nameEn: 'Turpan', nameAr: 'توربان', nameKu: 'تورپان', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 42.9513, longitude: 89.1895, timezoneId: 'Asia/Urumqi', utcOffsetStandard: 6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lanzhou', nameEn: 'Lanzhou', nameAr: 'لانتشو', nameKu: 'لانژۆو', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 36.0611, longitude: 103.8343, timezoneId: 'Asia/Shanghai', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'HongKong', nameEn: 'Hong Kong', nameAr: 'هونغ كونغ', nameKu: 'هۆنگ کۆنگ', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 22.3193, longitude: 114.1694, timezoneId: 'Asia/Hong_Kong', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Taipei', nameEn: 'Taipei (Taiwan)', nameAr: 'تايبيه', nameKu: 'تایپێ', countryEn: 'China', countryAr: 'الصين', countryKu: 'چین (تورکستانی ڕۆژهەڵات)', latitude: 25.0330, longitude: 121.5654, timezoneId: 'Asia/Taipei', utcOffsetStandard: 8.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Nigeria
    CountryGroup(
      id: 'nigeria',
      nameEn: 'Nigeria',
      nameAr: 'نيجيريا',
      nameKu: 'نێجیریا',
      flag: '🇳🇬',
      cities: [
        WorldCity(id: 'Lagos', nameEn: 'Lagos', nameAr: 'لاغوس', nameKu: 'لاگۆس', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 6.5244, longitude: 3.3792, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Abuja', nameEn: 'Abuja', nameAr: 'أبوجا', nameKu: 'ئەبوجا', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 9.0765, longitude: 7.3986, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kano', nameEn: 'Kano', nameAr: 'كانو', nameKu: 'کانۆ', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 12.0022, longitude: 8.5920, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ibadan', nameEn: 'Ibadan', nameAr: 'إبادان', nameKu: 'ئیبادان', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 7.3775, longitude: 3.9470, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kaduna', nameEn: 'Kaduna', nameAr: 'كادونا', nameKu: 'کادونا', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 10.5105, longitude: 7.4165, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'PortHarcourt', nameEn: 'Port Harcourt', nameAr: 'بورت هاركورت', nameKu: 'پۆرت هارکۆرت', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 4.8156, longitude: 7.0498, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sokoto', nameEn: 'Sokoto', nameAr: 'صكتو', nameKu: 'سۆکۆتۆ', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 13.0609, longitude: 5.2476, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Maiduguri', nameEn: 'Maiduguri', nameAr: 'مايدوغوري', nameKu: 'مایدوگوری', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 11.8333, longitude: 13.1500, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Zaria', nameEn: 'Zaria', nameAr: 'زاريا', nameKu: 'زاریا', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 11.0855, longitude: 7.7199, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ilorin', nameEn: 'Ilorin', nameAr: 'إلورين', nameKu: 'ئیلۆرین', countryEn: 'Nigeria', countryAr: 'نيجيريا', countryKu: 'نێجیریا', latitude: 8.4799, longitude: 4.5418, timezoneId: 'Africa/Lagos', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: South Africa
    CountryGroup(
      id: 'south_africa',
      nameEn: 'South Africa',
      nameAr: 'جنوب إفريقيا',
      nameKu: 'ئەفریقای باشوور',
      flag: '🇿🇦',
      cities: [
        WorldCity(id: 'Johannesburg', nameEn: 'Johannesburg', nameAr: 'جوهانسبرغ', nameKu: 'جۆهانسبێرگ', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -26.2041, longitude: 28.0473, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'CapeTown', nameEn: 'Cape Town', nameAr: 'كيب تاون', nameKu: 'کەیپ تاون', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -33.9249, longitude: 18.4241, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Durban', nameEn: 'Durban', nameAr: 'ديربان', nameKu: 'دۆربان', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -29.8587, longitude: 31.0218, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Pretoria', nameEn: 'Pretoria', nameAr: 'بريتوريا', nameKu: 'پریتۆریا', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -25.7479, longitude: 28.2293, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'PortElizabeth', nameEn: 'Port Elizabeth (Gqeberha)', nameAr: 'بورت إليزابيث', nameKu: 'پۆرت ئەلیزابێس', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -33.9608, longitude: 25.6022, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bloemfontein', nameEn: 'Bloemfontein', nameAr: 'بلومفونتين', nameKu: 'بلومفۆنتین', countryEn: 'South Africa', countryAr: 'جنوب إفريقيا', countryKu: 'ئەفریقای باشوور', latitude: -29.0852, longitude: 26.1596, timezoneId: 'Africa/Johannesburg', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Kenya
    CountryGroup(
      id: 'kenya',
      nameEn: 'Kenya',
      nameAr: 'كينيا',
      nameKu: 'کینیا',
      flag: '🇰🇪',
      cities: [
        WorldCity(id: 'Nairobi', nameEn: 'Nairobi', nameAr: 'نيروبي', nameKu: 'نایرۆبی', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -1.2921, longitude: 36.8219, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mombasa', nameEn: 'Mombasa', nameAr: 'مومباسا', nameKu: 'مۆمباسا', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -4.0435, longitude: 39.6682, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kisumu', nameEn: 'Kisumu', nameAr: 'كيسومو', nameKu: 'کیسۆمۆ', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -0.0917, longitude: 34.7680, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Nakuru', nameEn: 'Nakuru', nameAr: 'ناكورو', nameKu: 'ناکۆرۆ', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -0.3031, longitude: 36.0800, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Garissa', nameEn: 'Garissa', nameAr: 'غاريسا', nameKu: 'گاریسا', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -0.4532, longitude: 39.6460, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Malindi', nameEn: 'Malindi', nameAr: 'ماليندي', nameKu: 'مالیندی', countryEn: 'Kenya', countryAr: 'كينيا', countryKu: 'کینیا', latitude: -3.2138, longitude: 40.1169, timezoneId: 'Africa/Nairobi', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Tanzania
    CountryGroup(
      id: 'tanzania',
      nameEn: 'Tanzania',
      nameAr: 'تنزانيا',
      nameKu: 'تانزانیا',
      flag: '🇹🇿',
      cities: [
        WorldCity(id: 'DarEsSalaam', nameEn: 'Dar es Salaam', nameAr: 'دار السلام', nameKu: 'دارولسەلام', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -6.7924, longitude: 39.2083, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'ZanzibarCity', nameEn: 'Zanzibar City', nameAr: 'زنجبار', nameKu: 'زەنگبار', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -6.1659, longitude: 39.2026, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Dodoma', nameEn: 'Dodoma', nameAr: 'دودوما', nameKu: 'دۆدۆما', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -6.1630, longitude: 35.7516, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Arusha', nameEn: 'Arusha', nameAr: 'أروشا', nameKu: 'ئاروشا', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -3.3869, longitude: 36.6830, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mwanza', nameEn: 'Mwanza', nameAr: 'موانزا', nameKu: 'موانزا', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -2.5164, longitude: 32.9000, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tanga', nameEn: 'Tanga', nameAr: 'تانغا', nameKu: 'تانگا', countryEn: 'Tanzania', countryAr: 'تنزانيا', countryKu: 'تانزانیا', latitude: -5.0689, longitude: 39.0988, timezoneId: 'Africa/Dar_es_Salaam', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Ethiopia
    CountryGroup(
      id: 'ethiopia',
      nameEn: 'Ethiopia',
      nameAr: 'إثيوبيا',
      nameKu: 'ئەتیۆپیا',
      flag: '🇪🇹',
      cities: [
        WorldCity(id: 'AddisAbaba', nameEn: 'Addis Ababa', nameAr: 'أديس أبابا', nameKu: 'ئەدیس ئەبابا', countryEn: 'Ethiopia', countryAr: 'إثيوبيا', countryKu: 'ئەتیۆپیا', latitude: 9.0320, longitude: 38.7469, timezoneId: 'Africa/Addis_Ababa', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'DireDawa', nameEn: 'Dire Dawa', nameAr: 'ديري داوا', nameKu: 'دیرێ داوا', countryEn: 'Ethiopia', countryAr: 'إثيوبيا', countryKu: 'ئەتیۆپیا', latitude: 9.5931, longitude: 41.8661, timezoneId: 'Africa/Addis_Ababa', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Harar', nameEn: 'Harar', nameAr: 'هرر', nameKu: 'هەرەر', countryEn: 'Ethiopia', countryAr: 'إثيوبيا', countryKu: 'ئەتیۆپیا', latitude: 9.3139, longitude: 42.1182, timezoneId: 'Africa/Addis_Ababa', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jimma', nameEn: 'Jimma', nameAr: 'جيما', nameKu: 'جیما', countryEn: 'Ethiopia', countryAr: 'إثيوبيا', countryKu: 'ئەتیۆپیا', latitude: 7.6734, longitude: 36.8344, timezoneId: 'Africa/Addis_Ababa', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Gondar', nameEn: 'Gondar', nameAr: 'غوندار', nameKu: 'گۆندار', countryEn: 'Ethiopia', countryAr: 'إثيوبيا', countryKu: 'ئەتیۆپیا', latitude: 12.6000, longitude: 37.4667, timezoneId: 'Africa/Addis_Ababa', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Somalia & Somaliland
    CountryGroup(
      id: 'somalia',
      nameEn: 'Somalia & Somaliland',
      nameAr: 'الصومال وصوماليلاند',
      nameKu: 'سۆماڵ و سۆماڵیلاند',
      flag: '🇸🇴',
      cities: [
        WorldCity(id: 'Mogadishu', nameEn: 'Mogadishu', nameAr: 'مقديشو', nameKu: 'مۆگادیشۆ', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: 2.0469, longitude: 45.3182, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hargeisa', nameEn: 'Hargeisa', nameAr: 'هرجيسا', nameKu: 'هەرگێیسا', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: 9.5600, longitude: 44.0650, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kismayo', nameEn: 'Kismayo', nameAr: 'كيسمايو', nameKu: 'کیسمایۆ', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: -0.3582, longitude: 42.5454, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bosaso', nameEn: 'Bosaso', nameAr: 'بوساسو', nameKu: 'بۆساسۆ', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: 10.7850, longitude: 49.1816, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Berbera', nameEn: 'Berbera', nameAr: 'بربرة', nameKu: 'بەربەرا', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: 10.4396, longitude: 45.0143, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Garowe', nameEn: 'Garowe', nameAr: 'غاروي', nameKu: 'گارۆوێ', countryEn: 'Somalia & Somaliland', countryAr: 'الصومال وصوماليلاند', countryKu: 'سۆماڵ و سۆماڵیلاند', latitude: 8.4064, longitude: 48.4819, timezoneId: 'Africa/Mogadishu', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Senegal
    CountryGroup(
      id: 'senegal',
      nameEn: 'Senegal',
      nameAr: 'السنغال',
      nameKu: 'سەنیگال',
      flag: '🇸🇳',
      cities: [
        WorldCity(id: 'Dakar', nameEn: 'Dakar', nameAr: 'داكار', nameKu: 'داکار', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 14.7167, longitude: -17.4677, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Touba', nameEn: 'Touba', nameAr: 'طوبى', nameKu: 'توبا', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 14.8667, longitude: -15.8833, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Thies', nameEn: 'Thiès', nameAr: 'ثيس', nameKu: 'تیس', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 14.7910, longitude: -16.9359, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'SaintLouisSN', nameEn: 'Saint-Louis', nameAr: 'سانت لويس', nameKu: 'سەنت لویس', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 16.0326, longitude: -16.4818, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kaolack', nameEn: 'Kaolack', nameAr: 'كاولاك', nameKu: 'کاوڵاک', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 14.1389, longitude: -16.0750, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Ziguinchor', nameEn: 'Ziguinchor', nameAr: 'زيغينشور', nameKu: 'زیگینشۆر', countryEn: 'Senegal', countryAr: 'السنغال', countryKu: 'سەنیگال', latitude: 12.5833, longitude: -16.2719, timezoneId: 'Africa/Dakar', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Ghana
    CountryGroup(
      id: 'ghana',
      nameEn: 'Ghana',
      nameAr: 'غانا',
      nameKu: 'گانا',
      flag: '🇬🇭',
      cities: [
        WorldCity(id: 'Accra', nameEn: 'Accra', nameAr: 'أكرا', nameKu: 'ئاکرا', countryEn: 'Ghana', countryAr: 'غانا', countryKu: 'گانا', latitude: 5.6037, longitude: -0.1870, timezoneId: 'Africa/Accra', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kumasi', nameEn: 'Kumasi', nameAr: 'كوماسي', nameKu: 'کۆماسی', countryEn: 'Ghana', countryAr: 'غانا', countryKu: 'گانا', latitude: 6.6885, longitude: -1.6244, timezoneId: 'Africa/Accra', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tamale', nameEn: 'Tamale', nameAr: 'تامالي', nameKu: 'تامالی', countryEn: 'Ghana', countryAr: 'غانا', countryKu: 'گانا', latitude: 9.4008, longitude: -0.8393, timezoneId: 'Africa/Accra', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'SekondiTakoradi', nameEn: 'Sekondi-Takoradi', nameAr: 'سيكوندی تاكورادي', nameKu: 'سیکۆندی', countryEn: 'Ghana', countryAr: 'غانا', countryKu: 'گانا', latitude: 4.9340, longitude: -1.7706, timezoneId: 'Africa/Accra', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: West & Central Africa
    CountryGroup(
      id: 'west_central_africa',
      nameEn: 'West & Central Africa',
      nameAr: 'غرب ووسط إفريقيا',
      nameKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا',
      flag: '🌍',
      cities: [
        WorldCity(id: 'Abidjan', nameEn: 'Abidjan (Ivory Coast)', nameAr: 'أبيدجان (ساحل العاج)', nameKu: 'ئابیدجان', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 5.3600, longitude: -4.0083, timezoneId: 'Africa/Abidjan', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Bamako', nameEn: 'Bamako (Mali)', nameAr: 'باماكو (مالي)', nameKu: 'باماکۆ', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 12.6392, longitude: -8.0029, timezoneId: 'Africa/Bamako', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Timbuktu', nameEn: 'Timbuktu (Mali)', nameAr: 'تمبكتو', nameKu: 'تیمبۆکتوو', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 16.7666, longitude: -3.0026, timezoneId: 'Africa/Bamako', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Niamey', nameEn: 'Niamey (Niger)', nameAr: 'نيامي (النيجر)', nameKu: 'نیامی', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 13.5116, longitude: 2.1254, timezoneId: 'Africa/Niamey', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Kampala', nameEn: 'Kampala (Uganda)', nameAr: 'كمبالا (أوغندا)', nameKu: 'کەمپالا', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 0.3476, longitude: 32.5825, timezoneId: 'Africa/Kampala', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'NDjamena', nameEn: 'N\'Djamena (Chad)', nameAr: 'انجمينا (تشاد)', nameKu: 'ئەنجامینا', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 12.1348, longitude: 15.0557, timezoneId: 'Africa/Ndjamena', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Yaounde', nameEn: 'Yaoundé (Cameroon)', nameAr: 'ياوندي (الكاميرون)', nameKu: 'یاوندێ', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 3.8480, longitude: 11.5021, timezoneId: 'Africa/Douala', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Douala', nameEn: 'Douala (Cameroon)', nameAr: 'دوالا', nameKu: 'دۆالا', countryEn: 'West & Central Africa', countryAr: 'غرب ووسط إفريقيا', countryKu: 'ڕۆژاوا و ناوەڕاستی ئەفریقا', latitude: 4.0511, longitude: 9.7679, timezoneId: 'Africa/Douala', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Brazil
    CountryGroup(
      id: 'brazil',
      nameEn: 'Brazil',
      nameAr: 'البرازيل',
      nameKu: 'بەڕازیل',
      flag: '🇧🇷',
      cities: [
        WorldCity(id: 'SaoPaulo', nameEn: 'São Paulo', nameAr: 'ساو باولو', nameKu: 'ساو پاولۆ', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -23.5505, longitude: -46.6333, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'RioDeJaneiro', nameEn: 'Rio de Janeiro', nameAr: 'ريو دي جانيرو', nameKu: 'ریۆ دی جانیرۆ', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -22.9068, longitude: -43.1729, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Curitiba', nameEn: 'Curitiba', nameAr: 'كوريتيبا', nameKu: 'کۆریتیبا', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -25.4284, longitude: -49.2733, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'FozDoIguacu', nameEn: 'Foz do Iguaçu', nameAr: 'فوز دو إيغواسو', nameKu: 'فۆز دو ئیگواسو', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -25.5163, longitude: -54.5854, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Brasilia', nameEn: 'Brasília', nameAr: 'برازيليا', nameKu: 'برازیلیا', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -15.7975, longitude: -47.8919, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'SalvadorBR', nameEn: 'Salvador', nameAr: 'سلفادور', nameKu: 'سالڤادۆر', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -12.9777, longitude: -38.5016, timezoneId: 'America/Bahia', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'BeloHorizonte', nameEn: 'Belo Horizonte', nameAr: 'بيلو هوريزونتي', nameKu: 'بێلۆ هۆریزۆنتی', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -19.9167, longitude: -43.9345, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'PortoAlegre', nameEn: 'Porto Alegre', nameAr: 'بورتو أليغري', nameKu: 'پۆرتۆ ئالێگری', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -30.0346, longitude: -51.2177, timezoneId: 'America/Sao_Paulo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Manaus', nameEn: 'Manaus', nameAr: 'ماناوس', nameKu: 'ماناوس', countryEn: 'Brazil', countryAr: 'البرازيل', countryKu: 'بەڕازیل', latitude: -3.1190, longitude: -60.0217, timezoneId: 'America/Manaus', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Argentina
    CountryGroup(
      id: 'argentina',
      nameEn: 'Argentina',
      nameAr: 'الأرجنتين',
      nameKu: 'ئەرجەنتین',
      flag: '🇦🇷',
      cities: [
        WorldCity(id: 'BuenosAires', nameEn: 'Buenos Aires', nameAr: 'بوينس آيرس', nameKu: 'بوێنس ئایریس', countryEn: 'Argentina', countryAr: 'الأرجنتين', countryKu: 'ئەرجەنتین', latitude: -34.6037, longitude: -58.3816, timezoneId: 'America/Argentina/Buenos_Aires', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'CordobaAR', nameEn: 'Córdoba', nameAr: 'قرطبة', nameKu: 'کۆردۆبا', countryEn: 'Argentina', countryAr: 'الأرجنتين', countryKu: 'ئەرجەنتین', latitude: -31.4201, longitude: -64.1888, timezoneId: 'America/Argentina/Cordoba', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rosario', nameEn: 'Rosario', nameAr: 'روزاريو', nameKu: 'رۆزاریۆ', countryEn: 'Argentina', countryAr: 'الأرجنتين', countryKu: 'ئەرجەنتین', latitude: -32.9468, longitude: -60.6393, timezoneId: 'America/Argentina/Buenos_Aires', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mendoza', nameEn: 'Mendoza', nameAr: 'ميندوزا', nameKu: 'مێندۆزا', countryEn: 'Argentina', countryAr: 'الأرجنتين', countryKu: 'ئەرجەنتین', latitude: -32.8895, longitude: -68.8458, timezoneId: 'America/Argentina/Mendoza', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Mexico
    CountryGroup(
      id: 'mexico',
      nameEn: 'Mexico',
      nameAr: 'المكسيك',
      nameKu: 'مەکسیک',
      flag: '🇲🇽',
      cities: [
        WorldCity(id: 'MexicoCity', nameEn: 'Mexico City', nameAr: 'مكسيكو سيتي', nameKu: 'مەکسیکۆ سیتی', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 19.4326, longitude: -99.1332, timezoneId: 'America/Mexico_City', utcOffsetStandard: -6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Guadalajara', nameEn: 'Guadalajara', nameAr: 'غوادالاخارا', nameKu: 'گوادالاخارا', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 20.6597, longitude: -103.3496, timezoneId: 'America/Mexico_City', utcOffsetStandard: -6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Monterrey', nameEn: 'Monterrey', nameAr: 'مونتيري', nameKu: 'مۆنتێرێی', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 25.6866, longitude: -100.3161, timezoneId: 'America/Monterrey', utcOffsetStandard: -6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Puebla', nameEn: 'Puebla', nameAr: 'بويبلا', nameKu: 'پوێبلا', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 19.0414, longitude: -98.2063, timezoneId: 'America/Mexico_City', utcOffsetStandard: -6.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tijuana', nameEn: 'Tijuana', nameAr: 'تيخوانا', nameKu: 'تیخوانا', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 32.5149, longitude: -117.0382, timezoneId: 'America/Tijuana', utcOffsetStandard: -8.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cancun', nameEn: 'Cancún', nameAr: 'كانكون', nameKu: 'کانکون', countryEn: 'Mexico', countryAr: 'المكسيك', countryKu: 'مەکسیک', latitude: 21.1619, longitude: -86.8515, timezoneId: 'America/Cancun', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Colombia & Venezuela
    CountryGroup(
      id: 'colombia_venezuela',
      nameEn: 'Colombia & Venezuela',
      nameAr: 'كولومبيا وفنزويلا',
      nameKu: 'کۆلۆمبیا و ڤەنزوێلا',
      flag: '🇨🇴',
      cities: [
        WorldCity(id: 'Bogota', nameEn: 'Bogotá', nameAr: 'بوغوتا', nameKu: 'بۆگۆتا', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 4.7110, longitude: -74.0721, timezoneId: 'America/Bogota', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Medellin', nameEn: 'Medellín', nameAr: 'ميديلين', nameKu: 'مێدێلین', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 6.2442, longitude: -75.5812, timezoneId: 'America/Bogota', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Cali', nameEn: 'Cali', nameAr: 'كالي', nameKu: 'کالی', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 3.4516, longitude: -76.5320, timezoneId: 'America/Bogota', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Maicao', nameEn: 'Maicao (La Guajira)', nameAr: 'مايكاو', nameKu: 'مایکاو', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 11.3783, longitude: -72.2411, timezoneId: 'America/Bogota', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Caracas', nameEn: 'Caracas', nameAr: 'كاراكاس', nameKu: 'کاراکاس', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 10.4806, longitude: -66.9036, timezoneId: 'America/Caracas', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Maracaibo', nameEn: 'Maracaibo', nameAr: 'ماراكايبو', nameKu: 'ماراکایبۆ', countryEn: 'Colombia & Venezuela', countryAr: 'كولومبيا وفنزويلا', countryKu: 'کۆلۆمبیا و ڤەنزوێلا', latitude: 10.6544, longitude: -71.6441, timezoneId: 'America/Caracas', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // Global Country/Region: Chile, Peru & South America
    CountryGroup(
      id: 'chile_peru_latam',
      nameEn: 'Chile, Peru & South America',
      nameAr: 'تشيلي وبيرو ودول أمريكا الجنوبية',
      nameKu: 'چیلی و پیرۆ و ئەمریکای باشوور',
      flag: '🇨🇱',
      cities: [
        WorldCity(id: 'Santiago', nameEn: 'Santiago', nameAr: 'سانتياغو', nameKu: 'سانتیاگۆ', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -33.4489, longitude: -70.6693, timezoneId: 'America/Santiago', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Valparaiso', nameEn: 'Valparaíso', nameAr: 'فالبارايسو', nameKu: 'ڤاڵپارایسۆ', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -33.0472, longitude: -71.6127, timezoneId: 'America/Santiago', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Lima', nameEn: 'Lima', nameAr: 'ليما', nameKu: 'لیما', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -12.0464, longitude: -77.0428, timezoneId: 'America/Lima', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'PanamaCity', nameEn: 'Panama City', nameAr: 'مدينة بنما', nameKu: 'پەنەما سیتی', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: 8.9824, longitude: -79.5199, timezoneId: 'America/Panama', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Quito', nameEn: 'Quito', nameAr: 'كيتو', nameKu: 'کیتۆ', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -0.1807, longitude: -78.4678, timezoneId: 'America/Guayaquil', utcOffsetStandard: -5.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Asuncion', nameEn: 'Asunción', nameAr: 'أسونسيون', nameKu: 'ئاسونسیۆن', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -25.2637, longitude: -57.5759, timezoneId: 'America/Asuncion', utcOffsetStandard: -4.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Montevideo', nameEn: 'Montevideo', nameAr: 'مونتيفيديو', nameKu: 'مۆنتێڤیدیۆ', countryEn: 'Chile, Peru & South America', countryAr: 'تشيلي وبيرو ودول أمريكا الجنوبية', countryKu: 'چیلی و پیرۆ و ئەمریکای باشوور', latitude: -34.9011, longitude: -56.1645, timezoneId: 'America/Montevideo', utcOffsetStandard: -3.0, recommendedMethodId: 'mwl'),
      ],
    ),

  ];

  /// Flattened list of all cities across all country groups.
  static List<WorldCity> get allCities {
    final list = <WorldCity>[];
    for (final group in countryGroups) {
      list.addAll(group.cities);
    }
    return list;
  }

  static WorldCity byId(String id) {
    final lower = id.trim().toLowerCase();
    return allCities.firstWhere(
      (c) =>
          c.id.toLowerCase() == lower ||
          c.nameEn.toLowerCase() == lower ||
          c.nameKu.toLowerCase() == lower ||
          c.nameAr.toLowerCase() == lower ||
          (lower == 'erbil' && c.id == 'Hawler') ||
          (lower == 'saidsadiq' && c.id == 'SaidSadiq') ||
          (lower == 'said sadiq' && c.id == 'SaidSadiq') ||
          (lower == 'سەیدسادق' && c.id == 'SaidSadiq') ||
          (lower == 'سەید سادق' && c.id == 'SaidSadiq'),
      orElse: () => allCities.first,
    );
  }

  static WorldCity nearestCity(double latitude, double longitude) {
    WorldCity nearest = allCities.first;
    double shortestDistance = double.infinity;
    for (final city in allCities) {
      final latDiff = latitude - city.latitude;
      final lonDiff = longitude - city.longitude;
      final dist = latDiff * latDiff + lonDiff * lonDiff;
      if (dist < shortestDistance) {
        shortestDistance = dist;
        nearest = city;
      }
    }
    return nearest;
  }
}

/// Unified Prayer Times Schedule Item
class PrayerTimeItem {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final DateTime time;
  final bool isPassed;
  final bool isNext;

  const PrayerTimeItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });

  String localizedName(String locale) {
    if (locale == 'kmr') {
      switch (id) {
        case 'fajr':
          return 'سپێدە';
        case 'sunrise':
          return 'ڕۆژهەلات';
        case 'dhuhr':
          return 'نیڤڕۆ';
        case 'asr':
          return 'ئێڤاری';
        case 'maghrib':
          return 'مەغریب';
        case 'isha':
          return 'عەشا';
        default:
          return nameKu;
      }
    }
    if (locale == 'ku') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }

  String formattedTime() {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Hijri Date Model
class HijriDateInfo {
  final int day;
  final int month;
  final int year;
  final String monthNameAr;
  final String monthNameEn;
  final String monthNameKu;

  const HijriDateInfo({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameAr,
    required this.monthNameEn,
    required this.monthNameKu,
  });

  String formatted(String locale) {
    final monthStr = (locale == 'ku' || locale == 'kmr')
        ? monthNameKu
        : (locale == 'ar' ? monthNameAr : monthNameEn);
    return '$day $monthStr $year AH';
  }

  /// Approximate Gregorian to Hijri conversion using Ku-calendar algorithm with optional day offset
  static HijriDateInfo fromGregorian(DateTime date, {int offsetDays = 0}) {
    final effectiveDate = offsetDays == 0 ? date : date.add(Duration(days: offsetDays));
    final jd = _gregorianToJulianDay(effectiveDate.year, effectiveDate.month, effectiveDate.day);
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l1 = l - 10631 * n + 354;
    final j = (((10985 - l1) / 5316).floor()) * (((50 * l1) / 17719).floor()) +
        (((l1 / 5670).floor()) * (((43 * l1) / 15238).floor()));
    final l2 = l1 - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 30).floor()) * (((15238 * j) / 43).floor()) + 29;
    final month = ((24 * l2) / 709).floor();
    final day = l2 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    const monthsAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    const monthsEn = [
      'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani', 'Jumada al-Ula', 'Jumada al-Akhirah',
      'Rajab', 'Sha\'ban', 'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    const monthsKu = [
      'مۆحەرەم', 'سەفەر', 'ڕەبیعی ئەوەل', 'ڕەبیعی دووەم', 'جومادەل ئوولا', 'جومادەل ئاخیرە',
      'ڕەجەب', 'شەعبان', 'ڕەمەزان', 'شەووال', 'زولقەعدە', 'زولحیججە'
    ];

    final clampedMonth = month.clamp(1, 12) - 1;
    return HijriDateInfo(
      day: day.clamp(1, 30),
      month: clampedMonth + 1,
      year: year,
      monthNameAr: monthsAr[clampedMonth],
      monthNameEn: monthsEn[clampedMonth],
      monthNameKu: monthsKu[clampedMonth],
    );
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    if (month < 3) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524;
  }
}

/// Unified Prayer Times Repository
class PrayerRepository {
  static PrayerTimesCatalog? _cachedCatalog;

  /// Preload official dataset into memory at app launch
  static Future<void> preload() => _getOfficialCatalog();

  static Future<PrayerTimesCatalog?> _getOfficialCatalog() async {
    if (_cachedCatalog != null) return _cachedCatalog;
    try {
      _cachedCatalog = await PrayerTimesService.load();
      return _cachedCatalog;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getPrayerScheduleForDate({
    required DateTime date,
    bool forceGps = false,
  }) async {
    final methodId = StorageService.getPrayerMethod();
    final asrSchoolStr = StorageService.getPrayerAsrSchool();
    final highLatStr = StorageService.getPrayerHighLatRule();
    final locationMode = StorageService.getPrayerLocationMode();
    final cityId = StorageService.getPrayerSelectedCity();
    final customCoords = StorageService.getPrayerCustomCoordinates();
    final offsets = StorageService.getPrayerMinuteOffsets();

    final asrSchool = asrSchoolStr == 'hanafi' ? AsrSchool.hanafi : AsrSchool.shafi;
    HighLatitudeRule highLatRule;
    switch (highLatStr) {
      case 'one_seventh':
        highLatRule = HighLatitudeRule.oneSeventh;
        break;
      case 'angle_based':
        highLatRule = HighLatitudeRule.angleBased;
        break;
      default:
        highLatRule = HighLatitudeRule.nightMiddle;
    }

    double lat = 36.1911; // Default Erbil
    double lng = 44.0092;
    String locationNameKu = 'هەولێر';
    String locationNameAr = 'أربيل';
    String locationNameEn = 'Hewlêr / Erbil';
    String locationName = 'Hewlêr / Erbil';
    WorldCity? currentCity;

    if (locationMode == 'gps') {
      final locRes = await LocationService.getCurrentLocation(forceGps: forceGps);
      lat = locRes.latitude;
      lng = locRes.longitude;
      currentCity = locRes.nearestCity;
      final gpsSuffixKu = locRes.isGpsSuccess ? " (GPS)" : "";
      final gpsSuffixAr = locRes.isGpsSuccess ? " (GPS)" : "";
      final gpsSuffixEn = locRes.isGpsSuccess ? " (GPS)" : " (GPS Fallback)";
      locationNameKu = '${currentCity.nameKu}$gpsSuffixKu';
      locationNameAr = '${currentCity.nameAr}$gpsSuffixAr';
      locationNameEn = '${currentCity.nameEn}$gpsSuffixEn';
      locationName = locationNameEn;
    } else if (locationMode == 'custom' && customCoords != null && customCoords.length >= 2) {
      lat = customCoords[0];
      lng = customCoords[1];
      currentCity = WorldCitiesCatalog.nearestCity(lat, lng);
      locationNameKu = 'دیاریکراو (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationNameAr = 'مخصص (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationNameEn = 'Custom (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationName = locationNameEn;
    } else {
      currentCity = WorldCitiesCatalog.byId(cityId);
      lat = currentCity.latitude;
      lng = currentCity.longitude;
      locationNameKu = currentCity.nameKu;
      locationNameAr = currentCity.nameAr;
      locationNameEn = currentCity.nameEn;
      locationName = locationNameEn;
    }

    final targetUtcOffset = currentCity.resolveUtcOffset(date);
    final timezoneAbbr = currentCity.timezoneAbbreviation(date);

    // Dynamic adaptation for international cities:
    // If the user's method is 'auto' OR is 'kurdistan_endowments' but the city is outside Kurdistan / Iraq,
    // automatically adapt to that city's recommended authentic method (e.g. MWL, ISNA, Diyanet, etc.)
    final isKurdistanOrIraq = currentCity.countryEn == 'Kurdistan' || currentCity.countryEn == 'Iraq';
    final effectiveMethodId = (methodId == 'auto' || (!isKurdistanOrIraq && methodId == 'kurdistan_endowments'))
        ? currentCity.recommendedMethodId
        : methodId;
    final method = CalculationMethod.byId(effectiveMethodId);

    // Official timetables represent the Kurdistan Endowments profile (only for cities within Kurdistan & Iraq with datasetKey)
    Map<String, DateTime>? officialTimesMap;
    final isKurdistanAwqaf = effectiveMethodId == 'kurdistan_endowments' && isKurdistanOrIraq;
    bool isOfficial = false;
    String dataSourceLabel = '✓ ${method.nameEn} ($timezoneAbbr)';
    String dataSourceLabelKu = '✓ ${method.nameKu} ($timezoneAbbr)';
    String dataSourceLabelAr = '✓ ${method.nameAr} ($timezoneAbbr)';
    String dataSourceLabelEn = '✓ ${method.nameEn} ($timezoneAbbr)';

    if (isKurdistanAwqaf && currentCity.datasetKey != null) {
      final catalog = await _getOfficialCatalog();
      if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
        final dayRecord = catalog.forDate(currentCity.datasetKey!, date);
        officialTimesMap = _parseOfficialDayTimes(date, dayRecord, offsets);
        isOfficial = true;
        dataSourceLabel = '✓ Authentic Official Awqaf Timetable';
        dataSourceLabelKu = '✓ کاتەکانی فەرمی وەزارەتی ئەوقاف';
        dataSourceLabelAr = '✓ المواقيت الرسمية المعتمدة لوزارة الأوقاف';
        dataSourceLabelEn = '✓ Authentic Official Awqaf Timetable';

        // When Hanafi Asr is selected, preserve authentic Awqaf Fajr/Sunrise/Dhuhr/Maghrib/Isha
        // and adjust Asr by the precise astronomical offset between Shafi and Hanafi for this day
        if (asrSchool == AsrSchool.hanafi) {
          final shafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.shafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetUtcOffset,
          );
          final hanafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.hanafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetUtcOffset,
          );
          final delay = hanafiCalc.asr.difference(shafiCalc.asr);
          officialTimesMap['asr'] = officialTimesMap['asr']!.add(delay);
          dataSourceLabel = '✓ Authentic Timetable (Hanafi Asr)';
          dataSourceLabelKu = '✓ کاتەکانی فەرمی ئەوقاف (عەسری حەنەفی)';
          dataSourceLabelAr = '✓ المواقيت الرسمية (عصر حنفي)';
          dataSourceLabelEn = '✓ Authentic Timetable (Hanafi Asr)';
        }
      }
    }

    // Fallback to 100% offline astronomical calculation using the target city's real timezone offset
    final timesMap = officialTimesMap ?? OfflinePrayerCalculator.calculate(
      latitude: lat,
      longitude: lng,
      date: date,
      method: method,
      asrSchool: asrSchool,
      highLatRule: highLatRule,
      targetUtcOffsetHours: targetUtcOffset,
      minuteOffsets: offsets,
    ).toMap();

    // Current wall-clock time in the target city's timezone.
    // Construct a local DateTime holding target city's wall-clock components
    // so comparisons with [timesMap] (which holds wall-clock DateTime) are 100% consistent.
    final targetCityUtc = DateTime.now().toUtc().add(Duration(minutes: (targetUtcOffset * 60).round()));
    final targetCityNow = DateTime(
      targetCityUtc.year,
      targetCityUtc.month,
      targetCityUtc.day,
      targetCityUtc.hour,
      targetCityUtc.minute,
      targetCityUtc.second,
      targetCityUtc.millisecond,
    );

    const prayerNames = [
      {'id': 'fajr', 'en': 'Fajr', 'ar': 'الفجر', 'ku': 'بەیانی'},
      {'id': 'sunrise', 'en': 'Sunrise', 'ar': 'الشروق', 'ku': 'هەڵاتنی خۆر'},
      {'id': 'dhuhr', 'en': 'Dhuhr', 'ar': 'الظهر', 'ku': 'نیوەڕۆ'},
      {'id': 'asr', 'en': 'Asr', 'ar': 'العصر', 'ku': 'عەسر'},
      {'id': 'maghrib', 'en': 'Maghrib', 'ar': 'المغرب', 'ku': 'مەغریب'},
      {'id': 'isha', 'en': 'Isha', 'ar': 'العشاء', 'ku': 'عیشا'},
    ];

    // Find next prayer relative to the target city's current local time
    String nextId = 'fajr';
    DateTime? nextTime;
    for (final p in prayerNames) {
      final pTime = timesMap[p['id']]!;
      if (pTime.isAfter(targetCityNow)) {
        nextId = p['id']!;
        nextTime = pTime;
        break;
      }
    }
    if (nextTime == null) {
      // All prayers passed for today, next is tomorrow's Fajr
      final tomorrowDate = date.add(const Duration(days: 1));
      final tomorrowTargetOffset = currentCity.resolveUtcOffset(tomorrowDate);
      Map<String, DateTime>? tomorrowOfficialMap;
      if (isKurdistanAwqaf && currentCity.datasetKey != null) {
        final catalog = await _getOfficialCatalog();
        if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
          final dayRecord = catalog.forDate(currentCity.datasetKey!, tomorrowDate);
          tomorrowOfficialMap = _parseOfficialDayTimes(tomorrowDate, dayRecord, offsets);
          if (asrSchool == AsrSchool.hanafi) {
            final shafiCalc = OfflinePrayerCalculator.calculate(
              latitude: lat,
              longitude: lng,
              date: tomorrowDate,
              method: method,
              asrSchool: AsrSchool.shafi,
              highLatRule: highLatRule,
              targetUtcOffsetHours: tomorrowTargetOffset,
            );
            final hanafiCalc = OfflinePrayerCalculator.calculate(
              latitude: lat,
              longitude: lng,
              date: tomorrowDate,
              method: method,
              asrSchool: AsrSchool.hanafi,
              highLatRule: highLatRule,
              targetUtcOffsetHours: tomorrowTargetOffset,
            );
            final delay = hanafiCalc.asr.difference(shafiCalc.asr);
            tomorrowOfficialMap['asr'] = tomorrowOfficialMap['asr']!.add(delay);
          }
        }
      }
      final tomorrowTimes = tomorrowOfficialMap ?? OfflinePrayerCalculator.calculate(
        latitude: lat,
        longitude: lng,
        date: tomorrowDate,
        method: method,
        asrSchool: asrSchool,
        highLatRule: highLatRule,
        targetUtcOffsetHours: tomorrowTargetOffset,
        minuteOffsets: offsets,
      ).toMap();

      nextId = 'fajr';
      nextTime = tomorrowTimes['fajr'];
    }

    final items = prayerNames.map((p) {
      final id = p['id']!;
      final pTime = timesMap[id]!;
      return PrayerTimeItem(
        id: id,
        nameEn: p['en']!,
        nameAr: p['ar']!,
        nameKu: p['ku']!,
        time: pTime,
        isPassed: targetCityNow.isAfter(pTime),
        isNext: id == nextId && (nextTime?.day == date.day),
      );
    }).toList();

    final hijriOffset = StorageService.getPrayerHijriOffset();
    final hijri = HijriDateInfo.fromGregorian(date, offsetDays: hijriOffset);

    return {
      'latitude': lat,
      'longitude': lng,
      'locationName': locationName,
      'locationNameKu': locationNameKu,
      'locationNameAr': locationNameAr,
      'locationNameEn': locationNameEn,
      'city': currentCity,
      'timezoneId': currentCity.timezoneId,
      'timezoneAbbr': timezoneAbbr,
      'targetUtcOffset': targetUtcOffset,
      'dataSource': dataSourceLabel,
      'dataSourceKu': dataSourceLabelKu,
      'dataSourceAr': dataSourceLabelAr,
      'dataSourceEn': dataSourceLabelEn,
      'isOfficialTimetable': isOfficial,
      'items': items,
      'nextId': nextId,
      'nextTime': nextTime,
      'hijriDate': hijri,
      'method': method,
      'asrSchool': asrSchool,
    };
  }

  /// Previews prayer times dynamically for any given configuration without saving to storage.
  static Future<Map<String, dynamic>> previewPrayerDayTimes({
    required DateTime date,
    required String methodId,
    required String asrSchoolStr,
    required String highLatStr,
    required Map<String, int> offsets,
    int hijriOffset = 0,
    WorldCity? city,
  }) async {
    final currentCity = city ?? WorldCitiesCatalog.byId(StorageService.getPrayerSelectedCity());
    final lat = currentCity.latitude;
    final lng = currentCity.longitude;
    final targetOffset = currentCity.resolveUtcOffset(date);
    final timezoneAbbr = currentCity.timezoneAbbreviation(date);

    final isKurdistanOrIraq = currentCity.countryEn == 'Kurdistan' || currentCity.countryEn == 'Iraq';
    final effectiveMethodId = (methodId == 'auto' || (!isKurdistanOrIraq && methodId == 'kurdistan_endowments'))
        ? currentCity.recommendedMethodId
        : methodId;
    final method = CalculationMethod.byId(effectiveMethodId);
    final asrSchool = asrSchoolStr == 'hanafi' ? AsrSchool.hanafi : AsrSchool.shafi;
    final highLatRule = highLatStr == 'one_seventh'
        ? HighLatitudeRule.oneSeventh
        : (highLatStr == 'angle_based' ? HighLatitudeRule.angleBased : HighLatitudeRule.nightMiddle);

    final isKurdistanAwqaf = effectiveMethodId == 'kurdistan_endowments' && isKurdistanOrIraq;
    Map<String, DateTime>? officialTimesMap;
    bool isOfficial = false;

    if (isKurdistanAwqaf && currentCity.datasetKey != null) {
      final catalog = await _getOfficialCatalog();
      if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
        final dayRecord = catalog.forDate(currentCity.datasetKey!, date);
        officialTimesMap = _parseOfficialDayTimes(date, dayRecord, offsets);
        isOfficial = true;

        if (asrSchool == AsrSchool.hanafi) {
          final shafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.shafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetOffset,
          );
          final hanafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.hanafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetOffset,
          );
          final delay = hanafiCalc.asr.difference(shafiCalc.asr);
          officialTimesMap['asr'] = officialTimesMap['asr']!.add(delay);
        }
      }
    }

    final timesMap = officialTimesMap ??
        OfflinePrayerCalculator.calculate(
          latitude: lat,
          longitude: lng,
          date: date,
          method: method,
          asrSchool: asrSchool,
          highLatRule: highLatRule,
          targetUtcOffsetHours: targetOffset,
          minuteOffsets: offsets,
        ).toMap();

    final hijri = HijriDateInfo.fromGregorian(date, offsetDays: hijriOffset);

    return {
      'times': timesMap,
      'isOfficialTimetable': isOfficial,
      'hijriDate': hijri,
      'timezoneAbbr': timezoneAbbr,
      'targetUtcOffset': targetOffset,
      'city': currentCity,
    };
  }

  static Map<String, DateTime> _parseOfficialDayTimes(
    DateTime date,
    PrayerDay day,
    Map<String, int> offsets,
  ) {
    DateTime parseTime(String hhmm, int offsetMinutes) {
      final parts = hhmm.split(':');
      final hour = int.tryParse(parts[0]) ?? 12;
      final minute = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(date.year, date.month, date.day, hour, minute);
      return dt.add(Duration(minutes: offsetMinutes));
    }

    return {
      'fajr': parseTime(day.fajr, offsets['fajr'] ?? 0),
      'sunrise': parseTime(day.sunrise, offsets['sunrise'] ?? 0),
      'dhuhr': parseTime(day.dhuhr, offsets['dhuhr'] ?? 0),
      'asr': parseTime(day.asr, offsets['asr'] ?? 0),
      'maghrib': parseTime(day.maghrib, offsets['maghrib'] ?? 0),
      'isha': parseTime(day.isha, offsets['isha'] ?? 0),
    };
  }
}
