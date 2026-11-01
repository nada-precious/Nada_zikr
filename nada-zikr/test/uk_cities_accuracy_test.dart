import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/offline_prayer_calculator.dart';
import 'package:nada_zikrakanm/services/qibla_calculator.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
  });

  test('Analyze all 45 UK cities against official UK geography and prayer calculations', () {
    final ukGroup = WorldCitiesCatalog.countryGroups.firstWhere((g) => g.id == 'uk');
    expect(ukGroup.cities.length, 45);

    final realUkRef = <String, Map<String, dynamic>>{
      'London': {'nation': 'England', 'region': 'Greater London', 'lat': 51.5074, 'lng': -0.1278},
      'Birmingham': {'nation': 'England', 'region': 'West Midlands', 'lat': 52.4862, 'lng': -1.8904},
      'Manchester': {'nation': 'England', 'region': 'North West', 'lat': 53.4808, 'lng': -2.2426},
      'Glasgow': {'nation': 'Scotland', 'region': 'Scotland', 'lat': 55.8642, 'lng': -4.2518},
      'Liverpool': {'nation': 'England', 'region': 'North West', 'lat': 53.4084, 'lng': -2.9916},
      'Leeds': {'nation': 'England', 'region': 'Yorkshire and the Humber', 'lat': 53.8008, 'lng': -1.5491},
      'Sheffield': {'nation': 'England', 'region': 'Yorkshire and the Humber', 'lat': 53.3811, 'lng': -1.4701},
      'Edinburgh': {'nation': 'Scotland', 'region': 'Scotland', 'lat': 55.9533, 'lng': -3.1883},
      'Bristol': {'nation': 'England', 'region': 'South West', 'lat': 51.4545, 'lng': -2.5879},
      'Cardiff': {'nation': 'Wales', 'region': 'Wales', 'lat': 51.4816, 'lng': -3.1791},
      'Leicester': {'nation': 'England', 'region': 'East Midlands', 'lat': 52.6369, 'lng': -1.1398},
      'Coventry': {'nation': 'England', 'region': 'West Midlands', 'lat': 52.4068, 'lng': -1.5197},
      'Bradford': {'nation': 'England', 'region': 'Yorkshire and the Humber', 'lat': 53.7960, 'lng': -1.7594},
      'Belfast': {'nation': 'Northern Ireland', 'region': 'Northern Ireland', 'lat': 54.5973, 'lng': -5.9301},
      'Nottingham': {'nation': 'England', 'region': 'East Midlands', 'lat': 52.9548, 'lng': -1.1581},
      'Newcastle': {'nation': 'England', 'region': 'North East', 'lat': 54.9783, 'lng': -1.6178},
      'Hull': {'nation': 'England', 'region': 'Yorkshire and the Humber', 'lat': 53.7676, 'lng': -0.3274},
      'Plymouth': {'nation': 'England', 'region': 'South West', 'lat': 50.3755, 'lng': -4.1427},
      'Stoke': {'nation': 'England', 'region': 'West Midlands', 'lat': 53.0027, 'lng': -2.1794},
      'Wolverhampton': {'nation': 'England', 'region': 'West Midlands', 'lat': 52.5862, 'lng': -2.1288},
      'Derby': {'nation': 'England', 'region': 'East Midlands', 'lat': 52.9225, 'lng': -1.4746},
      'Swansea': {'nation': 'Wales', 'region': 'Wales', 'lat': 51.6214, 'lng': -3.9436},
      'Southampton': {'nation': 'England', 'region': 'South East', 'lat': 50.9097, 'lng': -1.4044},
      'Luton': {'nation': 'England', 'region': 'East of England', 'lat': 51.8787, 'lng': -0.4200},
      'MiltonKeynes': {'nation': 'England', 'region': 'South East', 'lat': 52.0406, 'lng': -0.7594},
      'Brighton': {'nation': 'England', 'region': 'South East', 'lat': 50.8225, 'lng': -0.1372},
      'Aberdeen': {'nation': 'Scotland', 'region': 'Scotland', 'lat': 57.1497, 'lng': -2.0943},
      'Dundee': {'nation': 'Scotland', 'region': 'Scotland', 'lat': 56.4620, 'lng': -2.9707},
      'Cambridge': {'nation': 'England', 'region': 'East of England', 'lat': 52.2053, 'lng': 0.1218},
      'Oxford': {'nation': 'England', 'region': 'South East', 'lat': 51.7520, 'lng': -1.2577},
      'Reading': {'nation': 'England', 'region': 'South East', 'lat': 51.4543, 'lng': -0.9781},
      'Portsmouth': {'nation': 'England', 'region': 'South East', 'lat': 50.8198, 'lng': -1.0880},
      'Preston': {'nation': 'England', 'region': 'North West', 'lat': 53.7632, 'lng': -2.7031},
      'Blackburn': {'nation': 'England', 'region': 'North West', 'lat': 53.7488, 'lng': -2.4818},
      'Bolton': {'nation': 'England', 'region': 'North West', 'lat': 53.5769, 'lng': -2.4282},
      'Oldham': {'nation': 'England', 'region': 'North West', 'lat': 53.5409, 'lng': -2.1114},
      'Rochdale': {'nation': 'England', 'region': 'North West', 'lat': 53.6178, 'lng': -2.1557},
      'Huddersfield': {'nation': 'England', 'region': 'Yorkshire and the Humber', 'lat': 53.6458, 'lng': -1.7850},
      'Slough': {'nation': 'England', 'region': 'South East', 'lat': 51.5105, 'lng': -0.5950},
      'Peterborough': {'nation': 'England', 'region': 'East of England', 'lat': 52.5739, 'lng': -0.2440},
      'Newport': {'nation': 'Wales', 'region': 'Wales', 'lat': 51.5842, 'lng': -2.9977},
      'Middlesbrough': {'nation': 'England', 'region': 'North East', 'lat': 54.5742, 'lng': -1.2350},
      'Sunderland': {'nation': 'England', 'region': 'North East', 'lat': 54.9069, 'lng': -1.3838},
      'Bournemouth': {'nation': 'England', 'region': 'South West', 'lat': 50.7192, 'lng': -1.8808},
      'Derry': {'nation': 'Northern Ireland', 'region': 'Northern Ireland', 'lat': 54.9966, 'lng': -7.3086},
    };

    final testDate = DateTime(2026, 10, 23);
    final summerSolstice = DateTime(2026, 6, 21);

    print('\n================================================================================');
    print('VERIFIED ALL 45 UK CITIES: GEOGRAPHY, NATION, TIMEZONE, QIBLA & PRAYER TIMES');
    print('================================================================================');

    for (final city in ukGroup.cities) {
      final ref = realUkRef[city.id];
      expect(ref, isNotNull, reason: 'City ${city.id} must be in official UK reference list');

      // Verify coordinate authenticity (tolerance < 0.05 degrees, approx < 4 km)
      final latDiff = (city.latitude - (ref!['lat'] as double)).abs();
      final lngDiff = (city.longitude - (ref['lng'] as double)).abs();
      expect(latDiff < 0.05, isTrue, reason: '${city.id} latitude must be genuine UK coordinate');
      expect(lngDiff < 0.05, isTrue, reason: '${city.id} longitude must be genuine UK coordinate');

      // Verify timezone
      expect(city.timezoneId, 'Europe/London');
      expect(city.utcOffsetStandard, 0.0);
      expect(city.recommendedMethodId, 'london_unified');

      // Verify Qibla direction (UK Qibla is consistently between 113° and 123°)
      final qibla = QiblaCalculator.calculateQiblaDirection(city.latitude, city.longitude);
      expect(qibla >= 113.0 && qibla <= 123.0, isTrue,
          reason: 'UK Qibla for ${city.id} ($qibla°) must point accurately toward Makkah');

      // Verify calculation for today
      final method = CalculationMethod.byId(city.recommendedMethodId);
      final offsetToday = city.resolveUtcOffset(testDate);
      final timesToday = OfflinePrayerCalculator.calculate(
        latitude: city.latitude,
        longitude: city.longitude,
        date: testDate,
        method: method,
        asrSchool: AsrSchool.shafi,
        highLatRule: HighLatitudeRule.nightMiddle,
        targetUtcOffsetHours: offsetToday,
      );
      expect(timesToday.fajr.isBefore(timesToday.sunrise), isTrue);
      expect(timesToday.sunrise.isBefore(timesToday.dhuhr), isTrue);
      expect(timesToday.dhuhr.isBefore(timesToday.asr), isTrue);
      expect(timesToday.asr.isBefore(timesToday.maghrib), isTrue);
      expect(timesToday.maghrib.isBefore(timesToday.isha), isTrue);

      // Verify calculation for summer solstice (must never produce error or reversed order)
      final offsetSolstice = city.resolveUtcOffset(summerSolstice);
      final timesSolstice = OfflinePrayerCalculator.calculate(
        latitude: city.latitude,
        longitude: city.longitude,
        date: summerSolstice,
        method: method,
        asrSchool: AsrSchool.shafi,
        highLatRule: HighLatitudeRule.nightMiddle,
        targetUtcOffsetHours: offsetSolstice,
      );
      expect(timesSolstice.fajr.isBefore(timesSolstice.sunrise), isTrue);
      expect(timesSolstice.sunrise.isBefore(timesSolstice.dhuhr), isTrue);
      expect(timesSolstice.dhuhr.isBefore(timesSolstice.asr), isTrue);
      expect(timesSolstice.asr.isBefore(timesSolstice.maghrib), isTrue);
      expect(timesSolstice.maghrib.isBefore(timesSolstice.isha), isTrue);

      final fajrStr = '${timesToday.fajr.hour.toString().padLeft(2, '0')}:${timesToday.fajr.minute.toString().padLeft(2, '0')}';
      final maghribStr = '${timesToday.maghrib.hour.toString().padLeft(2, '0')}:${timesToday.maghrib.minute.toString().padLeft(2, '0')}';

    }

    // Exact times for Derby
    final derby = WorldCitiesCatalog.byId('Derby');
    final offset = derby.resolveUtcOffset(testDate);
    final derbyTimes = OfflinePrayerCalculator.calculate(
      latitude: derby.latitude,
      longitude: derby.longitude,
      date: testDate,
      method: CalculationMethod.londonUnified,
      asrSchool: AsrSchool.shafi,
      highLatRule: HighLatitudeRule.nightMiddle,
      targetUtcOffsetHours: offset,
    );

    print('\n================ DERBY UK TODAY ================');
    print('Current Time in Derby: 01:51 AM BST (UTC+1)');
    print('Fajr:    ${derbyTimes.fajr.hour.toString().padLeft(2, '0')}:${derbyTimes.fajr.minute.toString().padLeft(2, '0')}');
    print('Sunrise: ${derbyTimes.sunrise.hour.toString().padLeft(2, '0')}:${derbyTimes.sunrise.minute.toString().padLeft(2, '0')}');
    print('Dhuhr:   ${derbyTimes.dhuhr.hour.toString().padLeft(2, '0')}:${derbyTimes.dhuhr.minute.toString().padLeft(2, '0')}');
    print('Asr (Shafi):  ${derbyTimes.asr.hour.toString().padLeft(2, '0')}:${derbyTimes.asr.minute.toString().padLeft(2, '0')}');
    print('Maghrib: ${derbyTimes.maghrib.hour.toString().padLeft(2, '0')}:${derbyTimes.maghrib.minute.toString().padLeft(2, '0')}');
    print('Isha:    ${derbyTimes.isha.hour.toString().padLeft(2, '0')}:${derbyTimes.isha.minute.toString().padLeft(2, '0')}');
    print('Qibla:   ${QiblaCalculator.calculateQiblaDirection(derby.latitude, derby.longitude).toStringAsFixed(1)}°');
    print('=================================================\n');

    final hull = WorldCitiesCatalog.byId('Hull');
    final offsetHull = hull.resolveUtcOffset(testDate);
    final hullTimes = OfflinePrayerCalculator.calculate(
      latitude: hull.latitude,
      longitude: hull.longitude,
      date: testDate,
      method: CalculationMethod.londonUnified,
      asrSchool: AsrSchool.shafi,
      highLatRule: HighLatitudeRule.nightMiddle,
      targetUtcOffsetHours: offsetHull,
    );
    final hullTimesHanafi = OfflinePrayerCalculator.calculate(
      latitude: hull.latitude,
      longitude: hull.longitude,
      date: testDate,
      method: CalculationMethod.londonUnified,
      asrSchool: AsrSchool.hanafi,
      highLatRule: HighLatitudeRule.nightMiddle,
      targetUtcOffsetHours: offsetHull,
    );

    print('\n================ HULL UK TODAY ================');
    print('Fajr:        ${hullTimes.fajr.hour.toString().padLeft(2, '0')}:${hullTimes.fajr.minute.toString().padLeft(2, '0')}');
    print('Sunrise:     ${hullTimes.sunrise.hour.toString().padLeft(2, '0')}:${hullTimes.sunrise.minute.toString().padLeft(2, '0')}');
    print('Dhuhr:       ${hullTimes.dhuhr.hour.toString().padLeft(2, '0')}:${hullTimes.dhuhr.minute.toString().padLeft(2, '0')}');
    print('Asr (Shafi): ${hullTimes.asr.hour.toString().padLeft(2, '0')}:${hullTimes.asr.minute.toString().padLeft(2, '0')}');
    print('Asr (Hanafi):${hullTimesHanafi.asr.hour.toString().padLeft(2, '0')}:${hullTimesHanafi.asr.minute.toString().padLeft(2, '0')}');
    print('Maghrib:     ${hullTimes.maghrib.hour.toString().padLeft(2, '0')}:${hullTimes.maghrib.minute.toString().padLeft(2, '0')}');
    print('Isha:        ${hullTimes.isha.hour.toString().padLeft(2, '0')}:${hullTimes.isha.minute.toString().padLeft(2, '0')}');
    print('Qibla:       ${QiblaCalculator.calculateQiblaDirection(hull.latitude, hull.longitude).toStringAsFixed(1)}°');
    print('=================================================\n');
  });
}
