import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/location_service.dart';
import 'package:nada_zikrakanm/services/qibla_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gps_prayer_test_');
    Hive.init(tempDir.path);
    await StorageService.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('GPS Nearest City, Prayer Times & Qibla Real Data Tests', () {
    final testCases = [
      // Kurdistan Locations
      {
        'location': 'Erbil Citadel (GPS fix)',
        'gpsLat': 36.1901,
        'gpsLng': 44.0091,
        'expectedNearestCityId': 'Hawler',
        'expectedQibla': 195.0, // South-Southwest towards Makkah
        'expectedTz': 'Asia/Baghdad',
      },
      {
        'location': 'Sulaymaniyah Salim St (GPS fix)',
        'gpsLat': 35.5612,
        'gpsLng': 45.4301,
        'expectedNearestCityId': 'Slemani',
        'expectedQibla': 200.6,
        'expectedTz': 'Asia/Baghdad',
      },
      {
        'location': 'Duhok KRO (GPS fix)',
        'gpsLat': 36.8650,
        'gpsLng': 42.9890,
        'expectedNearestCityId': 'Duhok',
        'expectedQibla': 191.0,
        'expectedTz': 'Asia/Baghdad',
      },

      // European Locations (Suburbs & International Airports)
      {
        'location': 'Central London / Westminster (GPS fix)',
        'gpsLat': 51.5014,
        'gpsLng': -0.1419,
        'expectedNearestCityId': 'London',
        'expectedQibla': 118.9, // East-Southeast towards Makkah
        'expectedTz': 'Europe/London',
      },
      {
        'location': 'Berlin Spandau (GPS fix)',
        'gpsLat': 52.5350,
        'gpsLng': 13.2000,
        'expectedNearestCityId': 'Berlin',
        'expectedQibla': 136.4, // Southeast towards Makkah
        'expectedTz': 'Europe/Berlin',
      },
      {
        'location': 'Paris Saint-Denis (GPS fix)',
        'gpsLat': 48.9360,
        'gpsLng': 2.3574,
        'expectedNearestCityId': 'Paris',
        'expectedQibla': 119.3,
        'expectedTz': 'Europe/Paris',
      },
      {
        'location': 'Stockholm Kista / Rinkeby (GPS fix)',
        'gpsLat': 59.4030,
        'gpsLng': 17.9440,
        'expectedNearestCityId': 'Stockholm',
        'expectedQibla': 148.1,
        'expectedTz': 'Europe/Stockholm',
      },
      {
        'location': 'Oslo Gardermoen / Alna (GPS fix)',
        'gpsLat': 59.9300,
        'gpsLng': 10.8500,
        'expectedNearestCityId': 'Oslo',
        'expectedQibla': 139.2,
        'expectedTz': 'Europe/Oslo',
      },
      {
        'location': 'Amsterdam Nieuw-West (GPS fix)',
        'gpsLat': 52.3600,
        'gpsLng': 4.8200,
        'expectedNearestCityId': 'Amsterdam',
        'expectedQibla': 125.5,
        'expectedTz': 'Europe/Amsterdam',
      },
      {
        'location': 'Brussels Schaerbeek (GPS fix)',
        'gpsLat': 50.8676,
        'gpsLng': 4.3737,
        'expectedNearestCityId': 'Brussels',
        'expectedQibla': 123.5,
        'expectedTz': 'Europe/Brussels',
      },
      {
        'location': 'Zurich Airport / Oerlikon (GPS fix)',
        'gpsLat': 47.4500,
        'gpsLng': 8.5600,
        'expectedNearestCityId': 'Zurich',
        'expectedQibla': 125.1,
        'expectedTz': 'Europe/Zurich',
      },
      {
        'location': 'Vienna Floridsdorf (GPS fix)',
        'gpsLat': 48.2560,
        'gpsLng': 16.3980,
        'expectedNearestCityId': 'Vienna',
        'expectedQibla': 136.8,
        'expectedTz': 'Europe/Vienna',
      },
      {
        'location': 'Rome Fiumicino (GPS fix)',
        'gpsLat': 41.7999,
        'gpsLng': 12.2462,
        'expectedNearestCityId': 'Rome',
        'expectedQibla': 122.8,
        'expectedTz': 'Europe/Rome',
      },
      {
        'location': 'Madrid Barajas (GPS fix)',
        'gpsLat': 40.4983,
        'gpsLng': -3.5676,
        'expectedNearestCityId': 'Madrid',
        'expectedQibla': 104.2,
        'expectedTz': 'Europe/Madrid',
      },
      {
        'location': 'Sarajevo Ilidža (GPS fix)',
        'gpsLat': 43.8300,
        'gpsLng': 18.3000,
        'expectedNearestCityId': 'Sarajevo',
        'expectedQibla': 134.5,
        'expectedTz': 'Europe/Sarajevo',
      },
    ];

    test('Haversine GPS nearest city matching is 100% accurate', () {
      for (final tc in testCases) {
        final gpsLat = tc['gpsLat'] as double;
        final gpsLng = tc['gpsLng'] as double;
        final expectedId = tc['expectedNearestCityId'] as String;

        final nearest = LocationService.findNearestCity(gpsLat, gpsLng);
        expect(nearest.id, equals(expectedId),
            reason: 'For GPS point ${tc['location']}, expected nearest city $expectedId but got ${nearest.id}');
        expect(nearest.timezoneId, equals(tc['expectedTz']),
            reason: 'Timezone mismatch for ${nearest.nameEn}');
      }
    });

    test('Qibla angle from GPS coordinates is accurate within ±0.2 degrees', () {
      for (final tc in testCases) {
        final gpsLat = tc['gpsLat'] as double;
        final gpsLng = tc['gpsLng'] as double;
        final expectedQibla = tc['expectedQibla'] as double;

        final actualQibla = QiblaCalculator.calculateQiblaDirection(gpsLat, gpsLng);
        final distanceKm = QiblaCalculator.calculateDistanceToKaabaKm(gpsLat, gpsLng);

        expect(actualQibla, inInclusiveRange(0.0, 360.0));
        expect((actualQibla - expectedQibla).abs(), lessThan(0.2),
            reason: 'Qibla bearing deviation too high for ${tc['location']}: got $actualQibla, expected $expectedQibla');
        expect(distanceKm, greaterThan(500.0), reason: 'Kaaba distance should be positive realistic number');
      }
    });

    test('Prayer calculation with GPS coordinates produces sequential non-null times', () async {
      final testDate = DateTime(2026, 10, 23);
      final zeroOffsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };

      for (final tc in testCases) {
        final gpsLat = tc['gpsLat'] as double;
        final gpsLng = tc['gpsLng'] as double;
        final nearest = LocationService.findNearestCity(gpsLat, gpsLng);

        final previewResult = await PrayerRepository.previewPrayerDayTimes(
          date: testDate,
          methodId: nearest.recommendedMethodId,
          asrSchoolStr: 'shafi',
          highLatStr: 'night_middle',
          offsets: zeroOffsets,
          city: nearest,
        );

        final times = previewResult['times'] as Map<String, DateTime>;

        expect(times['fajr'], isNotNull);
        expect(times['sunrise'], isNotNull);
        expect(times['dhuhr'], isNotNull);
        expect(times['asr'], isNotNull);
        expect(times['maghrib'], isNotNull);
        expect(times['isha'], isNotNull);

        // Verification of proper Islamic sequential order
        expect(times['sunrise']!.isAfter(times['fajr']!), isTrue,
            reason: 'Fajr must precede sunrise in ${tc['location']}');
        expect(times['dhuhr']!.isAfter(times['sunrise']!), isTrue,
            reason: 'Sunrise must precede Dhuhr in ${tc['location']}');
        expect(times['asr']!.isAfter(times['dhuhr']!), isTrue,
            reason: 'Dhuhr must precede Asr in ${tc['location']}');
        expect(times['maghrib']!.isAfter(times['asr']!), isTrue,
            reason: 'Asr must precede Maghrib in ${tc['location']}');
        expect(times['isha']!.isAfter(times['maghrib']!), isTrue,
            reason: 'Maghrib must precede Isha in ${tc['location']}');
      }
    });
  });
}
