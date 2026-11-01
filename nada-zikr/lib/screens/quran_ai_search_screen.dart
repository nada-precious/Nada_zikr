import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../services/app_haptics.dart';
import '../services/app_share_service.dart';
import '../services/quran_service.dart';
import '../services/quran_ai_search_service.dart';
import '../widgets/app_theme.dart';
import 'quran_screen.dart';

class QuranAiSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const QuranAiSearchScreen({super.key, this.initialQuery});

  @override
  State<QuranAiSearchScreen> createState() => _QuranAiSearchScreenState();
}

class _QuranAiSearchScreenState extends State<QuranAiSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  QuranAiSearchResponse? _searchResponse;

  final List<Map<String, String>> _suggestedChips = const [
    {
      'kmr': 'نامەیا سلێمانی بۆ بەلقیسێ',
      'ku': 'نامەی سولەیمان بۆ بەلقیس',
      'ar': 'رسالة سليمان إلى بلقيس',
      'en': 'Solomon message to Bilqis',
    },
    {
      'kmr': 'قورەیش و گەشتێن زڤستان و هاڤینێ',
      'ku': 'قوڕەیش و سەفەری زستان و هاوین',
      'ar': 'قريش ورحلة الشتاء والصيف',
      'en': 'Quraysh winter & summer',
    },
    {
      'kmr': 'بێهنفرەهی و هەدار د دەمێ نەخۆشیێ دا',
      'ku': 'ئارامگری لە کاتی ناخۆشیدا',
      'ar': 'الصبر عند الشدائد',
      'en': 'Patience during hardship',
    },
    {
      'kmr': 'ترس و ئارامیا دلێ مروڤی',
      'ku': 'ترس و دڵەڕاوکێ و ئارامی دڵ',
      'ar': 'الخوف وطمأنينة القلب',
      'en': 'Fear & peace of heart',
    },
    {
      'kmr': 'گەنجێن ئەسحابول کەهف',
      'ku': 'لاوانی ئەسحابی کەهف',
      'ar': 'قصة أصحاب الكهف',
      'en': 'Companions of the cave',
    },
    {
      'kmr': 'ڕێزگرتنا دایک و بابان',
      'ku': 'ڕێزی دایک و باوک',
      'ar': 'بر الوالدين',
      'en': 'Honoring parents',
    },
    {
      'kmr': 'ئاخفتنا مێروویێ دگەل پێغەمبەر سلێمانی',
      'ku': 'قسەکردنی مێروولە لەگەڵ سولەیمان',
      'ar': 'قصة النملة مع سليمان',
      'en': 'The ant with Solomon',
    },
    {
      'kmr': 'خەونا پێغەمبەر یوسف',
      'ku': 'خەوەکەی پێغەمبەر یوسف',
      'ar': 'رؤيا يوسف عليه السلام',
      'en': 'Prophet Yusuf dream',
    },
    {
      'kmr': 'پێغەمبەر مووسا و خدر',
      'ku': 'پێغەمبەر موسا و خدر',
      'ar': 'موسى والخضر',
      'en': 'Moses and Khidr',
    },
    {
      'kmr': 'موعجیزەیا مێش و هنگڤینی',
      'ku': 'موعجیزەی هەنگوین و هەنگ',
      'ar': 'النحل والعسل',
      'en': 'The bee and honey',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!.trim());
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    FocusScope.of(context).unfocus();
    AppHaptics.selectionClick();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final language = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';

    try {
      final res = await QuranAiSearchService.instance.search(clean, language: language);
      if (!mounted) return;
      setState(() {
        _searchResponse = res;
        _isLoading = false;
        if (res.results.isEmpty) {
          _errorMessage = language == 'kmr'
              ? 'چ ئایەت نەهاتنە دیتن بۆ ڤێ لێگەڕیانێ. هیڤییە ب پەیڤەکا دی بگەڕە.'
              : (language == 'ku'
                  ? 'هیچ ئایەتێک نەدۆزرایەوە بۆ ئەم گەڕانە. تکایە بە وشەیەکی تر بگەڕێ.'
                  : (language == 'ar'
                      ? 'لم يتم العثور على آيات مطابقة. يرجى تجربة كلمات بحث أخرى.'
                      : 'No matching ayahs found. Please try different keywords.'));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openAyahInQuran(QuranAiSearchResult item) async {
    AppHaptics.selectionClick();
    final surahs = await QuranService.instance.loadSurahs();
    final targetSurah = surahs.firstWhere(
      (s) => s.number == item.surahNumber,
      orElse: () => surahs.first,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahReadingScreen(
          surah: targetSurah,
          initialAyah: item.ayahNumber,
        ),
      ),
    );
  }

  void _copyAyah(QuranAiSearchResult item, String language) {
    AppHaptics.selectionClick();
    final textToCopy = '''
﴿ ${item.ayahArabicText} ﴾
[${item.surahArabicName}: ${item.ayahNumber}]
${item.getReason(language)}
''';
    Clipboard.setData(ClipboardData(text: textToCopy.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkPanel,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text(
              language == 'kmr'
                  ? 'ئایەت هاتە کۆپیکرن'
                  : (language == 'ku'
                      ? 'ئایەتەکە لەبەرگیرایەوە'
                      : (language == 'ar' ? 'تم نسخ الآية' : 'Ayah copied to clipboard')),
              style: TextStyle(color: AppColors.cream, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAyah(QuranAiSearchResult item, String language) {
    AppHaptics.selectionClick();
    final shareText = '''
﴿ ${item.ayahArabicText} ﴾
سورة ${item.surahArabicName} (${item.surahKurdishName}) - الآية ${item.ayahNumber}

${item.getReason(language)}

ـ Nada Zikr (نەدا زیکر)
''';
    AppShareService.share(context, shareText.trim());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = loc?.locale.languageCode ?? 'ku';
    final isRtl = language != 'en';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
              color: AppColors.cream,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.3),
                      AppColors.accent1.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                language == 'kmr'
                    ? 'لێگەڕیانا ژیر یا قورئانێ'
                    : (language == 'ku'
                        ? 'گەڕانی زیرەکی قورئان'
                        : (language == 'ar' ? 'البحث القرآني الذكي' : 'Quran AI Smart Search')),
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Input Container
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkPanel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.gold
                      : AppColors.gold.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: TextStyle(color: AppColors.cream, fontSize: 15),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: language == 'kmr'
                            ? 'بۆ نموونە: نامەیا سلێمانی، قورەیش، ترس، هەدار و سەبر...'
                            : (language == 'ku'
                                ? 'بۆ نموونە: نامەی سولەیمان، قوڕەیش، ترس، ئارامگری...'
                                : (language == 'ar'
                                    ? 'مثال: رسالة سليمان، قريش، الخوف، الصبر، أصحاب الكهف...'
                                    : 'e.g., Solomon message, Quraysh, Fear, Patience...')),
                        hintStyle: TextStyle(
                          color: AppColors.faintText.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppColors.faintText, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResponse = null;
                          _errorMessage = null;
                        });
                      },
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ),
                ],
              ),
            ),

            // Suggested Queries Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _suggestedChips.map((chip) {
                  final title = chip[language] ?? chip['kmr'] ?? chip['ku']!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6, bottom: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.darkPanel,
                      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      avatar: Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                      label: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        _searchController.text = title;
                        _performSearch(title);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Content Area
            Expanded(
              child: _buildBody(context, language, isRtl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String language, bool isRtl) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              language == 'kmr'
                  ? 'ژیرییا دەستکرد د قورئانێ دا لێدگەڕیت...'
                  : (language == 'ku'
                      ? 'ژیری دەستکرد لە قورئاندا دەگەڕێت...'
                      : (language == 'ar'
                          ? 'الذكاء الاصطناعي يبحث في القرآن الكريم...'
                          : 'AI is searching the Quran...')),
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              language == 'kmr'
                  ? 'دیتنا ئایەتێن گرێدای ب مانا و چیرۆکان ڤە'
                  : (language == 'ku'
                      ? 'دۆزینەوەی ئایەتی پەیوەندیدار بەپێی واتا و چیرۆک'
                      : (language == 'ar'
                          ? 'مطابقة المعاني والقصص والمفاهيم القرآنية'
                          : 'Matching stories, meanings, and Islamic themes')),
              style: TextStyle(color: AppColors.faintText, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.cream, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResponse == null || _searchResponse!.results.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPanel,
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                language == 'kmr'
                    ? 'ب زمانێ سادە د قورئانێ دا بگەڕە'
                    : (language == 'ku'
                        ? 'بە زمانی سادە لە قورئاندا بگەڕێ'
                        : (language == 'ar'
                            ? 'ابحث في القرآن بالكلمات اليومية'
                            : 'Search the Quran with everyday words')),
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                language == 'kmr'
                    ? 'دشێی ب کوردی، عەرەبی، یان ئینگلیزی دەربارەی چیرۆک، هەست، حوکم، یان ڕووداوان بنڤیسی و ژیرییا دەستکرد دێ ئایەتێن دروست بۆ تە ئینیت.'
                    : (language == 'ku'
                        ? 'دەتوانیت بە کوردی، عەرەبی، یان ئینگلیزی دەربارەی چیرۆکەکان، هەستەکان، حوکمەکان، یان ڕووداوەکان بنووسیت و ژیری دەستکرد ئایەتە دروستەکانت بۆ دەهێنێت.'
                        : (language == 'ar'
                            ? 'اكتب بالعربية أو الكردية أو الإنجليزية عن القصص أو المشاعر أو الأحكام وسيستخرج الذكاء الاصطناعي الآيات الدقيقة فوراً.'
                            : 'Type in English, Kurdish, or Arabic about stories, emotions, rulings, or history and AI will extract the exact Ayahs.')),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.faintText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = _searchResponse!.results;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildAyahResultCard(item, language, isRtl);
      },
    );
  }

  Widget _buildAyahResultCard(
    QuranAiSearchResult item,
    String language,
    bool isRtl,
  ) {
    final surahDisplayName = isRtl
        ? ((language == 'ku' || language == 'kmr') ? item.surahKurdishName : item.surahArabicName)
        : item.surahEnglishName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Surah Name & Badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${item.surahNumber}:${item.ayahNumber}',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'سورة ${item.surahArabicName} ($surahDisplayName)',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  language == 'kmr'
                      ? 'لاپەڕێ ${item.pageNumber}'
                      : (language == 'ku'
                          ? 'لاپەڕە ${item.pageNumber}'
                          : (language == 'ar' ? 'صفحة ${item.pageNumber}' : 'Page ${item.pageNumber}')),
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),

          // AI Context / Explanation Badge
          if (item.getReason(language).isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkBgAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.getReason(language),
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Ayah Quranic Calligraphy Text with authentic typography & ayah number ornament
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.ayahArabicText,
                    style: AppTheme.quranAyahText(
                      fontSize: 24,
                      color: AppColors.cream,
                      height: 2.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: ' ﴿${item.ayahNumber}﴾',
                    style: AppTheme.quranAyahText(
                      fontSize: 18,
                      color: AppColors.gold,
                      height: 2.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Open in Quran Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 17),
                    label: Text(
                      language == 'kmr'
                          ? 'دەقێ قورئانێ'
                          : (language == 'ku'
                              ? 'دەقی قورئان'
                              : (language == 'ar' ? 'عرض بالقرآن' : 'Open in Quran')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _openAyahInQuran(item),
                  ),
                ),
                const SizedBox(width: 8),

                // Copy Button
                IconButton(
                  tooltip: language == 'kmr'
                      ? 'کۆپیکرن'
                      : (language == 'ku'
                          ? 'کۆپیکردن'
                          : (language == 'ar' ? 'نسخ' : 'Copy')),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkBgAlt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.copy_rounded, color: AppColors.cream, size: 18),
                  onPressed: () => _copyAyah(item, language),
                ),

                // Share Button
                IconButton(
                  tooltip: language == 'kmr'
                      ? 'پارڤەکرن'
                      : (language == 'ku'
                          ? 'هاوبەشکردن'
                          : (language == 'ar' ? 'مشاركة' : 'Share')),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkBgAlt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.share_rounded, color: AppColors.cream, size: 18),
                  onPressed: () => _shareAyah(item, language),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
