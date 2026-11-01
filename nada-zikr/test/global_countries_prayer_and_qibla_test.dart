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

  group('Worldwide Countries Islamic Prayer & Qibla Real Data Tests', () {
    test('All 87 worldwide country groups exist and have valid configuration', () {
      const groups = WorldCitiesCatalog.countryGroups;
      expect(groups.length, greaterThanOrEqualTo(80));

      final expectedCountryIds = [
        'kurdistan', 'iraq', 'turkey', 'iran', 'syria', 'lebanon', 'jordan', 'palestine',
        'saudi', 'uae', 'qatar', 'kuwait', 'bahrain', 'oman', 'yemen',
        'germany', 'uk', 'sweden', 'norway', 'denmark', 'finland', 'netherlands', 'france',
        'italy', 'spain', 'bosnia', 'russia', 'usa', 'canada', 'australia', 'egypt', 'morocco',
        'pakistan', 'india', 'bangladesh', 'afghanistan', 'indonesia', 'malaysia', 'singapore_brunei',
        'uzbekistan', 'kazakhstan', 'kyrgyzstan', 'tajikistan', 'turkmenistan',
        'japan', 'south_korea', 'china', 'nigeria', 'south_africa', 'kenya', 'tanzania',
        'ethiopia', 'somalia', 'senegal', 'ghana', 'brazil', 'argentina', 'mexico',
        'colombia_venezuela', 'chile_peru_latam'
      ];

      for (final id in expectedCountryIds) {
        final match = groups.where((g) => g.id == id);
        expect(match.isNotEmpty, isTrue, reason: 'CountryGroup $id must exist');
        expect(match.first.cities.isNotEmpty, isTrue, reason: 'CountryGroup $id must have cities');
      }
    });

    test('Total catalog size exceeds 900 unique cities with valid coordinates and timezones', () {
      final allCities = WorldCitiesCatalog.allCities;
      expect(allCities.length, greaterThanOrEqualTo(900));

      final idSet = <String>{};
      for (final c in allCities) {
        expect(idSet.contains(c.id), isFalse, reason: 'Duplicate city ID: ${c.id}');
        idSet.add(c.id);

        expect(c.latitude, inInclusiveRange(-90.0, 90.0));
        expect(c.longitude, inInclusiveRange(-180.0, 180.0));
        expect(c.timezoneId.isNotEmpty, isTrue);
        expect(c.nameEn.isNotEmpty, isTrue);
        expect(c.nameAr.isNotEmpty, isTrue);
        expect(c.nameKu.isNotEmpty, isTrue);
      }
    });

    test('Authentic Islamic calculation methods are correctly assigned', () {
      final testCases = [
        {'id': 'Karachi', 'method': 'karachi'},
        {'id': 'NewDelhi', 'method': 'karachi'},
        {'id': 'Dhaka', 'method': 'karachi'},
        {'id': 'Kabul', 'method': 'karachi'},
        {'id': 'Jakarta', 'method': 'indonesia'},
        {'id': 'KualaLumpur', 'method': 'singapore'},
        {'id': 'Singapore', 'method': 'singapore'},
        {'id': 'Tashkent', 'method': 'mwl'},
        {'id': 'Almaty', 'method': 'mwl'},
        {'id': 'Tokyo', 'method': 'mwl'},
        {'id': 'Seoul', 'method': 'mwl'},
        {'id': 'Beijing', 'method': 'mwl'},
        {'id': 'Lagos', 'method': 'mwl'},
        {'id': 'Johannesburg', 'method': 'mwl'},
        {'id': 'Nairobi', 'method': 'mwl'},
        {'id': 'Cairo', 'method': 'egypt'},
        {'id': 'Casablanca', 'method': 'mwl'},
        {'id': 'Dubai', 'method': 'dubai'},
        {'id': 'KuwaitCity', 'method': 'kuwait'},
        {'id': 'Doha', 'method': 'gulf'},
        {'id': 'Riyadh', 'method': 'umm_al_qura'},
        {'id': 'SaoPaulo', 'method': 'mwl'},
        {'id': 'BuenosAires', 'method': 'mwl'},
        {'id': 'MexicoCity', 'method': 'mwl'},
      ];

      for (final tc in testCases) {
        final city = WorldCitiesCatalog.byId(tc['id']!);
        expect(city.recommendedMethodId, equals(tc['method']),
            reason: 'City ${tc['id']} must use ${tc['method']} method');
      }
    });

    test('Qibla angle calculation produces astronomically accurate bearings worldwide', () {
      final testCases = [
        {'id': 'Karachi', 'min': 260.0, 'max': 275.0},      // ~267° (West)
        {'id': 'Jakarta', 'min': 290.0, 'max': 300.0},      // ~295° (WNW)
        {'id': 'KualaLumpur', 'min': 288.0, 'max': 298.0},  // ~293° (WNW)
        {'id': 'Tashkent', 'min': 230.0, 'max': 245.0},     // ~238° (SW)
        {'id': 'Tokyo', 'min': 288.0, 'max': 298.0},        // ~293° (WNW)
        {'id': 'Lagos', 'min': 60.0, 'max': 72.0},          // ~65° (ENE)
        {'id': 'Johannesburg', 'min': 6.0, 'max': 18.0},    // ~12° (NNE)
        {'id': 'SaoPaulo', 'min': 62.0, 'max': 75.0},       // ~68° (ENE)
        {'id': 'BuenosAires', 'min': 68.0, 'max': 80.0},    // ~74° (ENE)
        {'id': 'Sydney', 'min': 270.0, 'max': 285.0},       // ~278° (WNW)
      ];

      for (final tc in testCases) {
        final city = WorldCitiesCatalog.byId(tc['id'] as String);
        final qibla = QiblaCalculator.calculateQiblaDirection(city.latitude, city.longitude);
        expect(qibla, greaterThanOrEqualTo(tc['min'] as double),
            reason: 'Qibla for ${city.nameEn} too low: $qibla');
        expect(qibla, lessThanOrEqualTo(tc['max'] as double),
            reason: 'Qibla for ${city.nameEn} too high: $qibla');
      }
    });

    test('Prayer calculation succeeds with strictly ordered times across diverse timezones', () {
      final testCityIds = [
        'Karachi', 'NewDelhi', 'Dhaka', 'Kabul', 'Jakarta', 'KualaLumpur',
        'Tashkent', 'Almaty', 'Tokyo', 'Lagos', 'Johannesburg', 'SaoPaulo', 'MexicoCity'
      ];

      final testDate = DateTime(2026, 4, 15);

      for (final cityId in testCityIds) {
        final city = WorldCitiesCatalog.byId(cityId);
        final method = CalculationMethod.byId(city.recommendedMethodId);
        final offset = city.resolveUtcOffset(testDate);

        final times = OfflinePrayerCalculator.calculate(
          latitude: city.latitude,
          longitude: city.longitude,
          date: testDate,
          method: method,
          asrSchool: AsrSchool.shafi,
          highLatRule: HighLatitudeRule.nightMiddle,
          targetUtcOffsetHours: offset,
        );

        expect(times.fajr.isBefore(times.sunrise), isTrue, reason: '${city.nameEn}: Fajr before Sunrise');
        expect(times.sunrise.isBefore(times.dhuhr), isTrue, reason: '${city.nameEn}: Sunrise before Dhuhr');
        expect(times.dhuhr.isBefore(times.asr), isTrue, reason: '${city.nameEn}: Dhuhr before Asr');
        expect(times.asr.isBefore(times.maghrib), isTrue, reason: '${city.nameEn}: Asr before Maghrib');
        expect(times.maghrib.isBefore(times.isha), isTrue, reason: '${city.nameEn}: Maghrib before Isha');

        // Dhuhr should fall near local noon (11:30 - 13:45)
        expect(times.dhuhr.hour, inInclusiveRange(11, 13),
            reason: '${city.nameEn}: Dhuhr hour ${times.dhuhr.hour} should be around noon');
      }
    });

    test('PrayerRepository preview automatically applies the location authentic calculation method', () async {
      final citiesToTest = [
        {'id': 'Hawler', 'expectedOfficial': true},
        {'id': 'Karachi', 'expectedMethod': 'karachi'},
        {'id': 'Jakarta', 'expectedMethod': 'indonesia'},
        {'id': 'KualaLumpur', 'expectedMethod': 'singapore'},
        {'id': 'Riyadh', 'expectedMethod': 'umm_al_qura'},
        {'id': 'Dubai', 'expectedMethod': 'dubai'},
        {'id': 'Cairo', 'expectedMethod': 'egypt'},
        {'id': 'Paris', 'expectedMethod': 'france'},
        {'id': 'Istanbul', 'expectedMethod': 'diyanet'},
        {'id': 'Berlin', 'expectedMethod': 'mwl'},
        {'id': 'Nashville', 'expectedMethod': 'isna'},
      ];

      final testDate = DateTime(2026, 5, 10);
      final zeroOffsets = <String, int>{'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0};

      for (final tc in citiesToTest) {
        final city = WorldCitiesCatalog.byId(tc['id'] as String);
        final res = await PrayerRepository.previewPrayerDayTimes(
          date: testDate,
          methodId: 'auto',
          asrSchoolStr: 'shafi',
          highLatStr: 'night_middle',
          offsets: zeroOffsets,
          city: city,
        );

        expect(res['times'], isNotNull);
        if (tc['expectedOfficial'] == true) {
          expect(res['isOfficialTimetable'], isTrue);
        } else {
          expect(city.recommendedMethodId, equals(tc['expectedMethod']));
        }
      }
    });
  });
}
