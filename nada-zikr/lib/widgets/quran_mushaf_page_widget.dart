import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import 'app_theme.dart';

/// Helper to convert standard integers to Eastern Arabic numerals (٠, ١, ٢, ٣...)
String toArabicDigits(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((c) {
    final idx = int.tryParse(c);
    return idx != null ? digits[idx] : c;
  }).join('');
}

/// Traditional Arabic Juz names for authentic Mushaf header
const List<String> kArabicJuzNames = [
  'الجُزْءُ الأَوَّلُ',
  'الجُزْءُ الثَّانِي',
  'الجُزْءُ الثَّالِثُ',
  'الجُزْءُ الرَّابِعُ',
  'الجُزْءُ الخَامِسُ',
  'الجُزْءُ السَّادِسُ',
  'الجُزْءُ السَّابِعُ',
  'الجُزْءُ الثَّامِنُ',
  'الجُزْءُ التَّاسِعُ',
  'الجُزْءُ العَاشِرُ',
  'الجُزْءُ الحَادِي عَشَرَ',
  'الجُزْءُ الثَّانِي عَشَرَ',
  'الجُزْءُ الثَّالِثَ عَشَرَ',
  'الجُزْءُ الرَّابِعَ عَشَرَ',
  'الجُزْءُ الخَامِسَ عَشَرَ',
  'الجُزْءُ السَّادِسَ عَشَرَ',
  'الجُزْءُ السَّابِعَ عَشَرَ',
  'الجُزْءُ الثَّامِنَ عَشَرَ',
  'الجُزْءُ التَّاسِعَ عَشَرَ',
  'الجُزْءُ العِشْرُونَ',
  'الجُزْءُ الحَادِي وَالعِشْرُونَ',
  'الجُزْءُ الثَّانِي وَالعِشْرُونَ',
  'الجُزْءُ الثَّالِثُ وَالعِشْرُونَ',
  'الجُزْءُ الرَّابِعُ وَالعِشْرُونَ',
  'الجُزْءُ الخَامِسُ وَالعِشْرُونَ',
  'الجُزْءُ السَّادِسُ وَالعِشْرُونَ',
  'الجُزْءُ السَّابِعُ وَالعِشْرُونَ',
  'الجُزْءُ الثَّامِنُ وَالعِشْرُونَ',
  'الجُزْءُ التَّاسِعُ وَالعِشْرُونَ',
  'الجُزْءُ الثَّلَاثُونَ',
];

String getArabicJuzTitle(int juz) {
  if (juz >= 1 && juz <= kArabicJuzNames.length) {
    return kArabicJuzNames[juz - 1];
  }
  return 'الجُزْءُ ${toArabicDigits(juz)}';
}

/// Authentic Islamic border frame painter for Real Madani Mushaf pages
class MushafFramePainter extends CustomPainter {
  final Color goldColor;
  final Color borderColor;

  MushafFramePainter({
    required this.goldColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Outer Border
    final outerPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, w - 8, h - 8),
      const Radius.circular(8),
    );
    canvas.drawRRect(outerRect, outerPaint);

    // 2. Inner Border
    final innerPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(9, 9, w - 18, h - 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(innerRect, innerPaint);

    // 3. Header separator line (at y = 38)
    final headerSepPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(9, 38), Offset(w - 9, 38), headerSepPaint);

    // 4. Footer separator line (at y = h - 38)
    canvas.drawLine(Offset(9, h - 38), Offset(w - 9, h - 38), headerSepPaint);

    // 5. Four Corner Geometric Star Ornaments
    _drawCornerOrnament(canvas, 9, 9, goldColor);
    _drawCornerOrnament(canvas, w - 9, 9, goldColor);
    _drawCornerOrnament(canvas, 9, h - 9, goldColor);
    _drawCornerOrnament(canvas, w - 9, h - 9, goldColor);
  }

  void _drawCornerOrnament(Canvas canvas, double x, double y, Color color) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 2.2, dotPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), linePaint);
    canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), linePaint);
  }

  @override
  bool shouldRepaint(covariant MushafFramePainter oldDelegate) {
    return oldDelegate.goldColor != goldColor ||
        oldDelegate.borderColor != borderColor;
  }
}

/// A single authentic Madani Mushaf Page widget (1 to 604)
class QuranMushafPageWidget extends StatefulWidget {
  final int pageNumber;
  final List<QuranAyah> ayahs;
  final QuranSurahMeta? Function(int surahNumber) getSurahMeta;
  final int? highlightedSurahNumber;
  final int? highlightedAyahNumber;
  final Set<String> bookmarkedAyahs;
  final Function(QuranAyah) onAyahTap;
  final bool isRtl;
  final String language;

  const QuranMushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.ayahs,
    required this.getSurahMeta,
    required this.highlightedSurahNumber,
    required this.highlightedAyahNumber,
    required this.bookmarkedAyahs,
    required this.onAyahTap,
    required this.isRtl,
    required this.language,
  });

  @override
  State<QuranMushafPageWidget> createState() => _QuranMushafPageWidgetState();
}

class _QuranMushafPageWidgetState extends State<QuranMushafPageWidget> {
  final List<TapGestureRecognizer> _tapRecognizers = [];

  @override
  void dispose() {
    for (final r in _tapRecognizers) {
      r.dispose();
    }
    _tapRecognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _tapRecognizers) {
      r.dispose();
    }
    _tapRecognizers.clear();

    if (widget.ayahs.isEmpty) {
      return Center(
        child: Text(
          'لاپەڕە ${toArabicDigits(widget.pageNumber)}',
          style: AppTheme.quranAyahText(fontSize: 18, color: AppColors.gold),
        ),
      );
    }

    final firstAyah = widget.ayahs.first;
    final primarySurah = widget.getSurahMeta(firstAyah.surah);
    final juzNumber = firstAyah.juz;
    final juzTitle = getArabicJuzTitle(juzNumber);
    final surahTitle = primarySurah != null
        ? 'سُورَةُ ${primarySurah.arabicName}'
        : 'سُورَةُ';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive typography to ensure authentic Madani Mushaf page fit
        final isSmallScreen = constraints.maxHeight < 640;
        final hasSurahHeader = widget.ayahs.any((a) => a.ayah == 1);
        final ayahCount = widget.ayahs.length;

        double fontSize;
        double lineHeight;
        if (widget.pageNumber <= 2) {
          // Opening pages Al-Fatiha and Al-Baqarah 1-5 have fewer ayahs, larger elegant calligraphy
          fontSize = isSmallScreen ? 22 : 25;
          lineHeight = 2.4;
        } else if (hasSurahHeader || ayahCount > 15) {
          fontSize = isSmallScreen ? 16.5 : 18.5;
          lineHeight = 2.05;
        } else {
          fontSize = isSmallScreen ? 18.0 : 20.0;
          lineHeight = 2.15;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkPanel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.panelBorderColor.withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: MushafFramePainter(
              goldColor: AppColors.gold,
              borderColor: AppColors.panelBorderColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                children: [
                  // ══════════════════════════════════════════════════════════════
                  // TOP HEADER BAR — Surah Name & Juz Title
                  // ══════════════════════════════════════════════════════════════
                  SizedBox(
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Juz badge
                        Expanded(
                          child: Text(
                            juzTitle,
                            textAlign: TextAlign.start,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.quranAyahText(
                              fontSize: 11.5,
                              color: AppColors.gold.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Center Cartouche Badge: Hizb or Page range
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            '۞ الجُزْءُ ${toArabicDigits(juzNumber)} ۞',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        // Right: Surah name
                        Expanded(
                          child: Text(
                            surahTitle,
                            textAlign: TextAlign.end,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.quranAyahText(
                              fontSize: 12.5,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ══════════════════════════════════════════════════════════════
                  // PAGE BODY — Authentic Justified Flowing Ayahs with Headers
                  // ══════════════════════════════════════════════════════════════
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildPageBody(context, fontSize, lineHeight),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ══════════════════════════════════════════════════════════════
                  // BOTTOM FOOTER BAR — Ornate Eastern Arabic Page Medallion
                  // ══════════════════════════════════════════════════════════════
                  SizedBox(
                    height: 26,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          '﴿ ${toArabicDigits(widget.pageNumber)} ﴾',
                          style: AppTheme.quranAyahText(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageBody(BuildContext context, double fontSize, double lineHeight) {
    final widgets = <Widget>[];

    // Group ayahs on this page into blocks by Surah start
    int currentSurah = -1;
    final currentBlock = <QuranAyah>[];

    void flushBlock() {
      if (currentBlock.isNotEmpty) {
        widgets.add(_buildAyahsParagraph(currentBlock, fontSize, lineHeight));
        currentBlock.clear();
      }
    }

    for (int i = 0; i < widget.ayahs.length; i++) {
      final ayah = widget.ayahs[i];

      // Detect if this is the start of a Surah on this page
      if (ayah.ayah == 1 || ayah.surah != currentSurah) {
        flushBlock();
        currentSurah = ayah.surah;
        final surahMeta = widget.getSurahMeta(ayah.surah);

        if (ayah.ayah == 1 && surahMeta != null) {
          // Render authentic golden Surah Header Banner
          widgets.add(_buildSurahTitleBanner(surahMeta));

          // Render Bismillah calligraphy banner if not Surah 9 (At-Tawbah) and not Surah 1 (where Bismillah is Ayah 1)
          if (surahMeta.number != 9 && surahMeta.number != 1) {
            widgets.add(_buildBismillahBanner());
          }
        }
      }

      currentBlock.add(ayah);
    }

    flushBlock();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  /// Authentic Islamic floral cartouche / banner for Surah Titles
  Widget _buildSurahTitleBanner(QuranSurahMeta surah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.22),
            AppColors.darkBgAlt,
            AppColors.gold.withValues(alpha: 0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
              const SizedBox(width: 8),
              Text(
                'سُورَةُ ${surah.arabicName}',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.quranAyahText(
                  fontSize: 18,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${surah.revelationType == 'Meccan' ? 'مَكِّيَّةٌ' : 'مَدَنِيَّةٌ'}  •  ${toArabicDigits(surah.numberOfAyahs)} آيَاتٍ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gold.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Calligraphic Bismillah Banner with ornamental side flourishes
  Widget _buildBismillahBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AppTheme.quranAyahText(
            fontSize: 17.5,
            color: AppColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Flowing paragraph of justified Quranic Arabic text with tap recognizers & ayah end medallions
  Widget _buildAyahsParagraph(
    List<QuranAyah> ayahs,
    double fontSize,
    double lineHeight,
  ) {
    final spans = <InlineSpan>[];

    for (final ayah in ayahs) {
      final isHighlighted = widget.highlightedSurahNumber == ayah.surah &&
          widget.highlightedAyahNumber == ayah.ayah;
      final isBookmarked =
          widget.bookmarkedAyahs.contains('${ayah.surah}:${ayah.ayah}');

      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onAyahTap(ayah);
      _tapRecognizers.add(recognizer);

      // 1. Ayah Text
      spans.add(
        TextSpan(
          text: ayah.text,
          recognizer: recognizer,
          style: isHighlighted
              ? AppTheme.quranAyahText(
                  fontSize: fontSize,
                  height: lineHeight,
                  color: AppColors.cream,
                ).copyWith(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.28),
                )
              : null,
        ),
      );

      // 2. Bookmark indicator if bookmarked
      if (isBookmarked) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.bookmark_rounded,
                size: fontSize * 0.65,
                color: AppColors.gold,
              ),
            ),
          ),
        );
      }

      // 3. Ornate Ayah End Medallion with Eastern Arabic digits
      spans.add(
        TextSpan(
          text: ' ﴿${toArabicDigits(ayah.ayah)}﴾ ',
          recognizer: recognizer,
          style: AppTheme.quranAyahText(
            fontSize: fontSize * 0.72,
            height: lineHeight,
            color: isHighlighted ? AppColors.gold : AppColors.gold.withValues(alpha: 0.95),
            fontWeight: FontWeight.bold,
          ).copyWith(
            backgroundColor: isHighlighted
                ? AppColors.gold.withValues(alpha: 0.28)
                : null,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        style: AppTheme.quranAyahText(
          fontSize: fontSize,
          height: lineHeight,
        ),
      ),
    );
  }
}

/// Floating bottom navigation bar for Real Mushaf Page Mode
class MushafBottomNavigationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onOpenJumpSheet;
  final String language;

  const MushafBottomNavigationBar({
    super.key,
    required this.currentPage,
    this.totalPages = 604,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onOpenJumpSheet,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final pageLabel = language == 'kmr'
        ? 'بەرپەر ${toArabicDigits(currentPage)} ژ ${toArabicDigits(totalPages)}'
        : language == 'ku'
            ? 'لاپەڕە ${toArabicDigits(currentPage)} لە ${toArabicDigits(totalPages)}'
            : language == 'ar'
                ? 'صفحة ${toArabicDigits(currentPage)} من ${toArabicDigits(totalPages)}'
                : 'Page $currentPage of $totalPages';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkBgAlt.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Next Page (in RTL, moving forward in Mushaf is left arrow / next)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              color: currentPage < totalPages ? AppColors.gold : AppColors.mutedText,
              tooltip: 'Next Page',
              onPressed: currentPage < totalPages ? onNextPage : null,
            ),

            // Center: Clickable Page Badge to open Jump Sheet
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onOpenJumpSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      pageLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.gold, size: 18),
                  ],
                ),
              ),
            ),

            // Previous Page (in RTL, moving backward in Mushaf is right arrow / prev)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              color: currentPage > 1 ? AppColors.gold : AppColors.mutedText,
              tooltip: 'Previous Page',
              onPressed: currentPage > 1 ? onPreviousPage : null,
            ),
          ],
        ),
      ),
    );
  }
}
