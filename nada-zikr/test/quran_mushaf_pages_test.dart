import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/services/quran_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran 604 Madani Mushaf Pages Verification', () {
    test('All 604 pages are present and mapped with ayahs', () async {
      final allPages = await QuranService.instance.loadAllAyahsByPage();

      expect(allPages.length, equals(604));

      int totalAyahs = 0;
      for (int p = 1; p <= 604; p++) {
        expect(allPages.containsKey(p), isTrue, reason: 'Page $p must exist');
        final pageAyahs = allPages[p]!;
        expect(pageAyahs.isNotEmpty, isTrue, reason: 'Page $p must have ayahs');
        totalAyahs += pageAyahs.length;
      }

      // Standard total Quran Ayahs is 6,236
      expect(totalAyahs, equals(6236));

      // Page 1 should be Surah Al-Fatiha (7 ayahs)
      final page1 = allPages[1]!;
      expect(page1.length, equals(7));
      expect(page1.first.surah, equals(1));
      expect(page1.first.ayah, equals(1));

      // Page 2 should start Surah Al-Baqarah (ayahs 1 to 5)
      final page2 = allPages[2]!;
      expect(page2.length, equals(5));
      expect(page2.first.surah, equals(2));
      expect(page2.first.ayah, equals(1));

      // Page 604 should contain Surahs 112, 113, 114
      final page604 = allPages[604]!;
      final surahsOn604 = page604.map((a) => a.surah).toSet();
      expect(surahsOn604, containsAll([112, 113, 114]));
      expect(page604.last.surah, equals(114));
      expect(page604.last.ayah, equals(6));
    });
  });
}
