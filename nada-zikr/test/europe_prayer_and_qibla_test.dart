import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/offline_prayer_calculator.dart';
import 'package:nada_zikrakanm/services/qibla_calculator.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('European Islamic Prayer Times & Qibla Integrity Tests', () {
    test('All European country groups exist and contain valid cities', () {
      final expectedEuropeanGroupIds = [
        'germany', 'uk', 'sweden', 'norway', 'denmark', 'finland',
        'netherlands', 'belgium', 'france', 'italy', 'spain',
        'switzerland', 'austria', 'ireland', 'portugal', 'greece',
        'bosnia', 'albania', 'kosovo', 'north_macedonia', 'poland',
        'czech', 'hungary', 'romania', 'bulgaria', 'russia',
        'ukraine', 'croatia_slovenia', 'serbia_montenegro', 'cyprus',
        'caucasus',
      ];

      for (final groupId in expectedEuropeanGroupIds) {
        final group = WorldCitiesCatalog.countryGroups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Country group not found: $groupId'),
        );

        expect(group.nameEn.isNotEmpty, isTrue);
        expect(group.nameAr.isNotEmpty, isTrue);
        expect(group.nameKu.isNotEmpty, isTrue);
        expect(group.flag.isNotEmpty, isTrue);
        expect(group.cities.isNotEmpty, isTrue, reason: 'Group $groupId must have cities');
      }
    });

    test('All worldwide city IDs are unique and coordinates are geographically valid', () {
      final ids = <String>{};
      for (final city in WorldCitiesCatalog.allCities) {
        expect(ids.contains(city.id), isFalse, reason: 'Duplicate city id: ${city.id}');
        ids.add(city.id);

        expect(city.latitude >= -90.0 && city.latitude <= 90.0, isTrue,
            reason: '${city.nameEn} latitude out of bounds');
        expect(city.longitude >= -180.0 && city.longitude <= 180.0, isTrue,
            reason: '${city.nameEn} longitude out of bounds');

        expect(city.nameEn.isNotEmpty, isTrue);
        expect(city.nameAr.isNotEmpty, isTrue);
        expect(city.nameKu.isNotEmpty, isTrue);
        expect(city.countryEn.isNotEmpty, isTrue);
        expect(city.countryAr.isNotEmpty, isTrue);
        expect(city.countryKu.isNotEmpty, isTrue);
      }
    });

    test('Qibla angle calculation produces realistic azimuth for European capitals', () {
      final capitals = {
        'London': 118.0, // ~118° - 120° East of South
        'Paris': 119.0,  // ~119° - 120°
        'Berlin': 136.0, // ~136° - 137°
        'Stockholm': 148.0, // ~148°
        'Rome': 127.0, // ~127°
        'Madrid': 100.0, // ~100°
        'Sarajevo': 136.0, // ~136°
      };

      for (final entry in capitals.entries) {
        final city = WorldCitiesCatalog.byId(entry.key);
        final qibla = QiblaCalculator.calculateQiblaDirection(city.latitude, city.longitude);
        expect(qibla, inInclusiveRange(0.0, 360.0));
        expect((qibla - entry.value).abs(), lessThan(5.0),
            reason: 'Qibla for ${city.nameEn} unexpected ($qibla vs ${entry.value})');
      }
    });

    test('Prayer calculation succeeds for high latitude cities without NaN', () async {
      final highLatCities = ['Tromso', 'Stockholm', 'Helsinki', 'Oslo', 'Rovaniemi'];
      final summerDate = DateTime(2026, 6, 21); // Summer solstice
      final zeroOffsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };

      for (final cityId in highLatCities) {
        final city = WorldCitiesCatalog.byId(cityId);
        final timesResult = await PrayerRepository.previewPrayerDayTimes(
          date: summerDate,
          methodId: city.recommendedMethodId,
          asrSchoolStr: 'shafi',
          highLatStr: 'night_middle',
          offsets: zeroOffsets,
          city: city,
        );
        final times = timesResult['times'] as Map<String, DateTime>;

        expect(times['fajr'], isNotNull);
        expect(times['sunrise'], isNotNull);
        expect(times['dhuhr'], isNotNull);
        expect(times['asr'], isNotNull);
        expect(times['maghrib'], isNotNull);
        expect(times['isha'], isNotNull);

        // In high-latitude summer, sequential order is maintained
        expect(times['sunrise']!.isAfter(times['fajr']!), isTrue,
            reason: 'Sunrise should follow Fajr in ${city.nameEn}');
        expect(times['dhuhr']!.isAfter(times['sunrise']!), isTrue,
            reason: 'Dhuhr should follow Sunrise in ${city.nameEn}');
        expect(times['asr']!.isAfter(times['dhuhr']!), isTrue,
            reason: 'Asr should follow Dhuhr in ${city.nameEn}');
      }
    });

    test('All 45 UK cities match real geographic coordinates, timezone, and London Unified Islamic standard', () {
      final ukGroup = WorldCitiesCatalog.countryGroups.firstWhere((g) => g.id == 'uk');
      expect(ukGroup.cities.length, greaterThanOrEqualTo(45));

      final testDate = DateTime(2026, 10, 23);

      for (final city in ukGroup.cities) {
        // 1. Coordinates within UK bounds
        expect(city.latitude, inInclusiveRange(50.0, 58.0),
            reason: '${city.nameEn} latitude out of UK bounds: ${city.latitude}');
        expect(city.longitude, inInclusiveRange(-8.0, 2.0),
            reason: '${city.nameEn} longitude out of UK bounds: ${city.longitude}');

        // 2. Accurate Timezone
        expect(city.timezoneId, equals('Europe/London'));

        // 3. Recommended Method
        expect(city.recommendedMethodId, equals('london_unified'));

        // 4. Accurate Qibla (between 113° and 124° towards Makkah)
        final qibla = QiblaCalculator.calculateQiblaDirection(city.latitude, city.longitude);
        expect(qibla, inInclusiveRange(113.0, 124.0),
            reason: '${city.nameEn} Qibla bearing unexpected: $qibla');

        // 5. Valid prayer times
        final offset = city.resolveUtcOffset(testDate);
        final method = CalculationMethod.byId(city.recommendedMethodId);
        final times = OfflinePrayerCalculator.calculate(
          latitude: city.latitude,
          longitude: city.longitude,
          date: testDate,
          method: method,
          asrSchool: AsrSchool.shafi,
          highLatRule: HighLatitudeRule.nightMiddle,
          targetUtcOffsetHours: offset,
        );

        expect(times.fajr.isBefore(times.sunrise), isTrue);
        expect(times.sunrise.isBefore(times.dhuhr), isTrue);
        expect(times.dhuhr.isBefore(times.asr), isTrue);
        expect(times.asr.isBefore(times.maghrib), isTrue);
        expect(times.maghrib.isBefore(times.isha), isTrue);
      }
    });
  });
}
