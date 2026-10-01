import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/quran_reciter.dart';
import '../services/app_haptics.dart';
import '../services/app_share_service.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_download_service.dart';
import '../services/quran_service.dart';
import '../services/quran_timing_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/downloaded_surahs_sheet.dart';
import '../widgets/quran_audio_player_widget.dart';
import '../widgets/reciter_selector_sheet.dart';
import '../widgets/sign_language_text_widget.dart';

const String _bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<QuranSurahMeta>> _surahsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _surahsFuture = QuranService.instance.loadSurahs();
  }

  Future<void> _onRefresh() async {
    AppHaptics.selectionClick();
    setState(() {
      _surahsFuture = QuranService.instance.loadSurahs();
    });
    await _surahsFuture;
  }

  List<QuranSurahMeta> _filter(List<QuranSurahMeta> surahs) {
    final q = _query.trim();
    if (q.isEmpty) return surahs;

    return surahs.where((s) {
      return s.kurdishName.contains(q) ||
          s.arabicName.contains(q) ||
          s.englishName.toLowerCase().contains(q.toLowerCase()) ||
          s.number.toString() == q;
    }).toList();
  }

  Widget _buildResumeCard(bool isRtl, String language) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: StorageService.getLastReadSurah(),
      builder: (context, snapshot) {
        final lastRead = snapshot.data;
        if (lastRead == null) return const SizedBox.shrink();

        final surahNum = lastRead['surahNumber'] ?? 1;
        final ayahNum = lastRead['ayahNumber'] as int?;
        final name = isRtl
            ? (language == 'ku'
                ? lastRead['surahNameKu']
                : lastRead['surahNameAr'])
            : lastRead['surahNameEn'];

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: GestureDetector(
            onTap: () async {
              final surahs = await QuranService.instance.loadSurahs();
              final target = surahs.firstWhere((s) => s.number == surahNum,
                  orElse: () => surahs.first);
              if (!context.mounted) return;
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                        builder: (_) => SurahReadingScreen(
                              surah: target,
                              initialAyah: ayahNum,
                            )),
                  )
                  .then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.22),
                    AppColors.panelColor,
                  ],
                ),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.bookmark_added_rounded,
                      color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            language == 'ku'
                              ? 'بەردەوامبە لە خوێندنەوە'
                              : language == 'ar'
                                ? 'متابعة القراءة'
                                : 'Resume Reading',
                          style: AppTheme.labelText(color: AppColors.gold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                            '$name (${language == 'ku'
                              ? 'سۆرەتی'
                              : language == 'ar'
                                ? 'السورة'
                                : 'Surah'} $surahNum)',
                          style: isRtl
                              ? AppTheme.kurdishText(
                                  fontSize: 14,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.bold)
                              : AppTheme.englishText(
                                  fontSize: 14,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.gold, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedAyahsTopButton(bool isRtl, String language) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: StorageService.getQuranAyahBookmarks(),
      builder: (context, snapshot) {
        final bookmarks = snapshot.data ?? const [];
        final count = bookmarks.length;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => _showSavedAyahsSheet(context, isRtl, language),
              tooltip: language == 'ku'
                  ? 'ئایەتە پاشەکەوتکراوەکان ($count)'
                  : language == 'ar'
                      ? 'الآيات المحفوظة ($count)'
                      : 'Saved Ayahs ($count)',
              icon: Icon(
                count > 0 ? Icons.bookmarks_rounded : Icons.bookmarks_outlined,
                color: AppColors.gold,
                size: 22,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: isRtl ? null : 6,
                left: isRtl ? 6 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDownloadedSurahsTopButton(bool isRtl, String language) {
    return ValueListenableBuilder<QuranReciter>(
      valueListenable: QuranAudioService.instance.reciterNotifier,
      builder: (context, activeReciter, _) {
        return ValueListenableBuilder<int>(
          valueListenable:
              QuranDownloadService.instance.downloadsRevisionNotifier,
          builder: (context, _, __) {
            return FutureBuilder<Map<String, int>>(
              future: QuranDownloadService.instance
                  .getAllRecitersDownloadCounts(),
              builder: (context, snapshot) {
                final allCounts = snapshot.data ?? {};
                final activeCount = allCounts[activeReciter.id] ?? 0;
                final totalCount =
                    allCounts.values.fold<int>(0, (sum, val) => sum + val);
                final hasDownloads = totalCount > 0;
                final count = activeCount > 0 ? activeCount : totalCount;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => DownloadedSurahsSheet.show(context),
                      tooltip: activeCount > 0
                          ? (language == 'ku'
                              ? 'سوورەتە داگیراوەکانی ${activeReciter.nameKu} ($activeCount)'
                              : language == 'ar'
                                  ? 'السور المحملة للشيخ ${activeReciter.nameAr} ($activeCount)'
                                  : 'Downloaded Surahs - ${activeReciter.nameEn} ($activeCount)')
                          : (totalCount > 0
                              ? (language == 'ku'
                                  ? 'سوورەتە داگیراوەکان ($totalCount داگیراو)'
                                  : language == 'ar'
                                      ? 'السور المحملة ($totalCount سورة)'
                                      : 'Downloaded Surahs ($totalCount total)')
                              : (language == 'ku'
                                  ? 'سوورەتە داگیراوەکان (0)'
                                  : language == 'ar'
                                      ? 'السور المحملة (0)'
                                      : 'Downloaded Surahs (0)')),
                      icon: Icon(
                        hasDownloads
                            ? Icons.offline_pin_rounded
                            : Icons.file_download_outlined,
                        color: hasDownloads
                            ? const Color(0xFF10B981)
                            : AppColors.gold,
                        size: 22,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 6,
                        right: isRtl ? null : 6,
                        left: isRtl ? 6 : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: activeCount > 0
                                ? const Color(0xFF10B981)
                                : AppColors.gold,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                              minWidth: 16, minHeight: 16),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSavedAyahsSheet(BuildContext context, bool isRtl, String language) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.panelColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                  // Top Drag Handle
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.bookmarks_rounded, color: AppColors.gold, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language == 'ku'
                                  ? 'ئایەتە پاشەکەوتکراوەکان'
                                  : language == 'ar'
                                      ? 'الآيات المحفوظة'
                                      : 'Saved Ayahs',
                              style: isRtl
                                  ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.cream)
                                  : AppTheme.englishText(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              language == 'ku'
                                  ? 'هەموو ئەو ئایەتانەی پاشەکەوتت کردوون'
                                  : language == 'ar'
                                      ? 'جميع الآيات التي قمت بحفظها للرجوع إليها'
                                      : 'All your bookmarked ayahs for quick access',
                              style: AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close_rounded, color: AppColors.faintText, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: AppColors.panelBorderColor),
                  const SizedBox(height: 8),

                  // Bookmarks List
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: StorageService.getQuranAyahBookmarks(),
                      builder: (context, snapshot) {
                        final bookmarks = snapshot.data ?? const [];

                        if (bookmarks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.faintText),
                                const SizedBox(height: 12),
                                Text(
                                  language == 'ku'
                                      ? 'هیچ ئایەتێک پاشەکەوت نەکراوە'
                                      : language == 'ar'
                                          ? 'لا توجد آيات محفوظة بعد'
                                          : 'No saved ayahs yet',
                                  style: isRtl
                                      ? AppTheme.kurdishText(fontSize: 14, color: AppColors.cream)
                                      : AppTheme.englishText(fontSize: 14, color: AppColors.cream),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  language == 'ku'
                                      ? 'لە کاتی خوێندنەوەدا بە ئایکۆنی بووکمارک ئایەت پاشەکەوت بکە'
                                      : language == 'ar'
                                          ? 'يمكنك حفظ أي آية أثناء القراءة بالضغط على علامة الحفظ'
                                          : 'Bookmark any ayah while reading to see it here',
                                  style: AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: bookmarks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bookmark = bookmarks[index];
                            final surahNumber = bookmark['surahNumber'] as int? ?? 1;
                            final ayahNumber = bookmark['ayahNumber'] as int? ?? 1;
                            final name = language == 'ku'
                                ? bookmark['surahNameKu']
                                : language == 'ar'
                                    ? bookmark['surahNameAr']
                                    : bookmark['surahNameEn'];
                            final note = bookmark['note'] as String? ?? '';

                            return Material(
                              color: AppColors.darkBgAlt,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.panelBorderColor),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  final surahs = await QuranService.instance.loadSurahs();
                                  final target = surahs.firstWhere(
                                    (surah) => surah.number == surahNumber,
                                    orElse: () => surahs.first,
                                  );
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => SurahReadingScreen(
                                      surah: target,
                                      initialAyah: ayahNumber,
                                    ),
                                  ));
                                },
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$surahNumber',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                    language == 'ku'
                                      ? 'ئایەت $ayahNumber، $name'
                                      : language == 'ar'
                                        ? 'الآية $ayahNumber، $name'
                                        : 'Ayah $ayahNumber, $name',
                                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                                  style: isRtl
                                      ? AppTheme.kurdishText(fontSize: 13, color: AppColors.cream, fontWeight: FontWeight.w600)
                                      : AppTheme.englishText(fontSize: 13, color: AppColors.cream, fontWeight: FontWeight.w600),
                                ),
                                subtitle: note.isEmpty
                                    ? null
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          note,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                                        ),
                                      ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.bookmark_remove_rounded, color: AppColors.faintText, size: 20),
                                        tooltip: language == 'ku'
                                          ? 'سڕینەوە'
                                          : language == 'ar'
                                            ? 'حذف الإشارة المرجعية'
                                            : 'Delete bookmark',
                                      onPressed: () async {
                                        await StorageService.removeQuranAyahBookmark(
                                          surahNumber: surahNumber,
                                          ayahNumber: ayahNumber,
                                        );
                                        setModalState(() {});
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                    Icon(
                                      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                      color: AppColors.gold,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = loc?.locale.languageCode ?? 'ku';
    final isRtl = language == 'ku' || language == 'ar';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              AppColors.darkBgAlt,
              AppColors.softSurface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text(
                      loc?.translate('quran') ?? 'قورئانی پیرۆز',
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: isRtl
                          ? AppTheme.kurdishTitle(
                              fontSize: 26, color: AppColors.gold)
                          : AppTheme.englishTitle(
                              fontSize: 26, color: AppColors.gold),
                    ),
                    const Spacer(),
                    // Saved Ayahs Top Button beside Reciter Selector
                    _buildSavedAyahsTopButton(isRtl, language),
                    const SizedBox(width: 2),
                    // Downloaded Surahs Top Button
                    _buildDownloadedSurahsTopButton(isRtl, language),
                    const SizedBox(width: 2),
                    // Reciter Selector Icon Button
                    IconButton(
                      onPressed: () => ReciterSelectorSheet.show(context),
                      tooltip: language == 'ku'
                          ? 'خوێنەرانی قورئان'
                          : language == 'ar'
                              ? 'قرّاء القرآن'
                              : 'Reciters',
                      icon: Icon(Icons.record_voice_over_rounded,
                          color: AppColors.gold, size: 22),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    border: Border.all(color: AppColors.panelBorderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: AppTheme.englishText(
                              fontSize: 14, color: AppColors.cream),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            hintText: loc?.translate('searchSurah') ??
                                (language == 'ku'
                                    ? 'گەڕان بۆ سوورەت...'
                                    : language == 'ar'
                                        ? 'بحث عن سورة...'
                                        : 'Search surah...'),
                            hintStyle: isRtl
                                ? AppTheme.kurdishText(
                                    fontSize: 13, color: AppColors.faintText)
                                : AppTheme.englishText(
                                    fontSize: 13, color: AppColors.faintText),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildResumeCard(isRtl, language),
              const SizedBox(height: 4),
              Expanded(
                child: FutureBuilder<List<QuranSurahMeta>>(
                  future: _surahsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final surahs = _filter(snapshot.data!);

                    return RefreshIndicator(
                      color: AppColors.gold,
                      backgroundColor: AppColors.darkPanel,
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: surahs.length,
                        itemBuilder: (context, index) {
                          final surah = surahs[index];
                          return _SurahTile(
                            surah: surah,
                            onReturned: () {
                              if (mounted) setState(() {});
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final QuranSurahMeta surah;
  final VoidCallback onReturned;

  const _SurahTile({required this.surah, required this.onReturned});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = loc?.locale.languageCode ?? 'ku';
    final isRtl = language == 'ku' || language == 'ar';
    final name = language == 'ku'
        ? surah.kurdishName
        : language == 'ar'
            ? surah.arabicName
            : surah.englishName;

    final pageRange = surah.startPage == surah.endPage
        ? '${surah.startPage}'
        : '${surah.startPage} - ${surah.endPage}';
    final pageLabel = language == 'ku'
        ? 'لاپەڕە $pageRange'
        : language == 'ar'
            ? 'صـ $pageRange'
            : 'p. $pageRange';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                builder: (_) => SurahReadingScreen(surah: surah),
              ))
              .then((_) => onReturned());
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.panelColor,
            border: Border.all(color: AppColors.panelBorderColor),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: AppTheme.englishText(
                        fontSize: 13,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: isRtl
                          ? AppTheme.kurdishTitle(
                              fontSize: 15, color: AppColors.cream)
                          : AppTheme.englishTitle(
                              fontSize: 15, color: AppColors.cream),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          language == 'ku'
                              ? '${loc?.translate('ayahs') ?? 'ئایەت'}: ${surah.numberOfAyahs} · $pageLabel'
                              : language == 'ar'
                                  ? '${surah.numberOfAyahs} ${loc?.translate('ayahs') ?? 'آيات'} · $pageLabel'
                                  : '${surah.englishName} · ${surah.numberOfAyahs} ${loc?.translate('ayahs') ?? 'ayahs'} · $pageLabel',
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: isRtl
                              ? AppTheme.kurdishText(
                                  fontSize: 11, color: AppColors.faintText)
                              : AppTheme.englishText(
                                  fontSize: 11, color: AppColors.faintText),
                        ),
                        ValueListenableBuilder<QuranReciter>(
                          valueListenable:
                              QuranAudioService.instance.reciterNotifier,
                          builder: (context, activeReciter, _) {
                            return ValueListenableBuilder<int>(
                              valueListenable: QuranDownloadService
                                  .instance.downloadsRevisionNotifier,
                              builder: (context, _, __) {
                                return FutureBuilder<bool>(
                                  future: QuranDownloadService.instance
                                      .isSurahDownloaded(
                                    surah.number,
                                    activeReciter.id,
                                  ),
                                  builder: (context, snap) {
                                    if (snap.data != true) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.4),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.offline_pin_rounded,
                                              size: 10,
                                              color: Color(0xFF10B981)),
                                          const SizedBox(width: 3),
                                          Text(
                                            language == 'ku'
                                                ? 'ئۆفلاین'
                                                : (language == 'ar'
                                                    ? 'دون إنترنت'
                                                    : 'Offline'),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play Audio Quick Button (Starts audio and opens reading screen with player visible)
              GestureDetector(
                onTap: () {
                  QuranAudioService.instance.playSurah(
                    surah.number,
                    name,
                    totalAyahs: surah.numberOfAyahs,
                  );
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => SurahReadingScreen(
                          surah: surah,
                          autoPlayAudio: true,
                        ),
                      ))
                      .then((_) => onReturned());
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicText(fontSize: 18, color: AppColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SURAH READING SCREEN — Per-Ayah Interactive Experience
// ═══════════════════════════════════════════════════════════════════════════════

class SurahReadingScreen extends StatefulWidget {
  final QuranSurahMeta surah;
  final int? initialAyah;
  final bool openInitialTafsir;
  final String initialTafsirId;
  final bool autoPlayAudio;

  const SurahReadingScreen({
    super.key,
    required this.surah,
    this.initialAyah,
    this.openInitialTafsir = false,
    this.initialTafsirId = 'asan',
    this.autoPlayAudio = false,
  });

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen> {
  bool _loading = true;
  bool _showPlayerBar = false;
  bool _useAyahList = false;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _quranFontSize = 24;

  List<QuranSurahMeta> _surahs = const [];
  late int _activeSurahNumber;
  final List<int> _loadedSurahNumbers = [];
  final Map<int, List<QuranAyah>> _surahAyahs = {};

  final ScrollController _scrollController = ScrollController();
  late String _selectedTafsirId;

  /// Currently highlighted (playing) surah & ayah number
  int? _highlightedSurahNumber;
  int? _highlightedAyahNumber;

  /// Saved position in seconds from previous session
  double? _resumePositionSeconds;

  /// Whether the user has manually scrolled (disables auto-scroll)
  bool _userScrollOverride = false;
  Timer? _scrollOverrideTimer;
  StreamSubscription<int?>? _ayahStreamSub;

  /// Scoped GlobalKeys for each ayah widget ('$surah:$ayah')
  final Map<String, GlobalKey> _ayahKeys = {};
  final Map<String, GlobalKey> _bookAyahKeys = {};
  final Map<int, GlobalKey> _surahHeaderKeys = {};
  final List<TapGestureRecognizer> _bookTapRecognizers = [];
  final Set<String> _bookmarkedAyahs = {};

  bool _isLoadingPrevious = false;
  bool _isLoadingNext = false;

  QuranSurahMeta? _getSurahMeta(int number) {
    if (_surahs.isEmpty) return widget.surah;
    for (final s in _surahs) {
      if (s.number == number) return s;
    }
    return widget.surah;
  }

  QuranSurahMeta get _activeSurah =>
      _getSurahMeta(_activeSurahNumber) ?? widget.surah;

  List<QuranAyah> get _activeAyahs =>
      _surahAyahs[_activeSurahNumber] ?? const [];

  @override
  void initState() {
    super.initState();
    _activeSurahNumber = widget.surah.number;
    _selectedTafsirId = widget.initialTafsirId == 'asan'
        ? StorageService.getPreferredTafsir()
        : widget.initialTafsirId;
    _showPlayerBar = widget.autoPlayAudio ||
        (QuranAudioService.instance.currentSurahNumber == widget.surah.number);

    if (QuranAudioService.instance.currentSurahNumber == widget.surah.number &&
        QuranAudioService.instance.hasExactTimingSupport) {
      _highlightedSurahNumber = widget.surah.number;
      _highlightedAyahNumber = QuranAudioService.instance.currentAyahNumber;
    } else {
      _highlightedSurahNumber = null;
      _highlightedAyahNumber = null;
    }

    StorageService.saveLastReadSurah(
      surahNumber: widget.surah.number,
      surahNameAr: widget.surah.arabicName,
      surahNameKu: widget.surah.kurdishName,
      surahNameEn: widget.surah.englishName,
      ayahNumber: widget.initialAyah ?? 1,
    );

    // Check if there's a saved audio position for this surah
    QuranAudioService.instance
        .getSavedPosition(widget.surah.number)
        .then((pos) {
      if (mounted && pos != null && pos > 0) {
        setState(() => _resumePositionSeconds = pos);
      }
    });

    // Subscribe to live ayah tracking
    _ayahStreamSub =
        QuranAudioService.instance.currentAyahStream.listen(_onAyahChanged);

    StorageService.getQuranAyahBookmarks().then((bookmarks) {
      if (!mounted) return;
      final set = <String>{};
      for (final b in bookmarks) {
        final s = b['surahNumber'];
        final a = b['ayahNumber'];
        if (s is int && a is int) {
          set.add('$s:$a');
        }
      }
      setState(() => _bookmarkedAyahs.addAll(set));
    });

    StorageService.readSetting('quran_reading_layout', defaultValue: 'book')
        .then((layout) {
      if (mounted) setState(() => _useAyahList = layout == 'list');
    });

    StorageService.readSetting('quran_font_size', defaultValue: 24)
        .then((size) {
      if (mounted && size is num) {
        setState(() => _quranFontSize = size.toDouble().clamp(18, 34));
      }
    });

    _load();
  }

  Future<void> _setReadingLayout(bool useAyahList) async {
    setState(() => _useAyahList = useAyahList);
    await StorageService.saveSetting(
      'quran_reading_layout',
      useAyahList ? 'list' : 'book',
    );
    final ayahNumber =
        _highlightedAyahNumber ?? QuranAudioService.instance.currentAyahNumber;
    final surahNumber =
        _highlightedSurahNumber ?? _activeSurahNumber;
    if (ayahNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(surahNumber, ayahNumber, animated: false);
      });
    }
  }

  Future<void> _setQuranFontSize(double size) async {
    final ayahNumber =
        _highlightedAyahNumber ?? QuranAudioService.instance.currentAyahNumber;
    final surahNumber =
        _highlightedSurahNumber ?? _activeSurahNumber;
    setState(() => _quranFontSize = size);
    await StorageService.saveSetting('quran_font_size', size);
    if (ayahNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(surahNumber, ayahNumber, animated: false);
      });
    }
  }

  Future<void> _load() async {
    final results = await Future.wait([
      QuranService.instance.loadAyahsForSurah(widget.surah.number),
      QuranService.instance.loadSurahs(),
    ]);
    final ayahs = results[0] as List<QuranAyah>;
    final surahs = results[1] as List<QuranSurahMeta>;

    final currentNum = widget.surah.number;
    _surahHeaderKeys[currentNum] = GlobalKey();
    for (final ayah in ayahs) {
      final keyId = '$currentNum:${ayah.ayah}';
      _ayahKeys[keyId] = GlobalKey();
      _bookAyahKeys[keyId] = GlobalKey();
    }

    _loadedSurahNumbers.clear();
    _loadedSurahNumbers.add(currentNum);
    _surahAyahs[currentNum] = ayahs;
    _surahs = surahs;
    _activeSurahNumber = currentNum;

    // Immediately pre-load next surah in position if available
    if (currentNum < 114) {
      final nextNum = currentNum + 1;
      final nextAyahs = await QuranService.instance.loadAyahsForSurah(nextNum);
      _surahHeaderKeys[nextNum] = GlobalKey();
      for (final ayah in nextAyahs) {
        final keyId = '$nextNum:${ayah.ayah}';
        _ayahKeys[keyId] = GlobalKey();
        _bookAyahKeys[keyId] = GlobalKey();
      }
      _loadedSurahNumbers.add(nextNum);
      _surahAyahs[nextNum] = nextAyahs;
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (widget.initialAyah != null) {
      _highlightedSurahNumber = currentNum;
      _highlightedAyahNumber = widget.initialAyah;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(currentNum, widget.initialAyah!, animated: false);
      });
    }

    if (widget.openInitialTafsir && widget.initialAyah != null) {
      final targetAyah = ayahs.firstWhere(
          (ayah) => ayah.ayah == widget.initialAyah,
          orElse: () => ayahs.first);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openTafsir(targetAyah);
      });
    }

    // Background-prefetch all ayah timings for instant seeks later
    QuranTimingService.instance.prefetchSurahTimings(
      reciterId: QuranAudioService.instance.selectedReciter.id,
      surahNumber: currentNum,
      totalAyahs: ayahs.length,
    );

    if (widget.autoPlayAudio &&
        (QuranAudioService.instance.currentSurahNumber != currentNum ||
            !QuranAudioService.instance.player.playing)) {
      final loc = AppLocalizations.of(context);
      final lang = loc?.locale.languageCode ?? 'ku';
      final surahName = lang == 'ku'
          ? widget.surah.kurdishName
          : (lang == 'ar' ? widget.surah.arabicName : widget.surah.englishName);
      QuranAudioService.instance.playSurah(
        currentNum,
        surahName,
        totalAyahs: ayahs.length,
      );
    }
  }

  Future<void> _loadNextSurah() async {
    if (_isLoadingNext || _loadedSurahNumbers.isEmpty) return;
    final lastNum = _loadedSurahNumbers.last;
    if (lastNum >= 114) return;

    _isLoadingNext = true;
    final nextNum = lastNum + 1;
    final nextAyahs = await QuranService.instance.loadAyahsForSurah(nextNum);

    _surahHeaderKeys[nextNum] = GlobalKey();
    for (final ayah in nextAyahs) {
      final keyId = '$nextNum:${ayah.ayah}';
      _ayahKeys[keyId] = GlobalKey();
      _bookAyahKeys[keyId] = GlobalKey();
    }

    if (mounted) {
      setState(() {
        _loadedSurahNumbers.add(nextNum);
        _surahAyahs[nextNum] = nextAyahs;
        _isLoadingNext = false;
      });
    }
  }

  Future<void> _loadPreviousSurah() async {
    if (_isLoadingPrevious || _loadedSurahNumbers.isEmpty) return;
    final firstNum = _loadedSurahNumbers.first;
    if (firstNum <= 1) return;

    _isLoadingPrevious = true;
    final prevNum = firstNum - 1;
    final prevAyahs = await QuranService.instance.loadAyahsForSurah(prevNum);

    _surahHeaderKeys[prevNum] = GlobalKey();
    for (final ayah in prevAyahs) {
      final keyId = '$prevNum:${ayah.ayah}';
      _ayahKeys[keyId] = GlobalKey();
      _bookAyahKeys[keyId] = GlobalKey();
    }

    final anchorKey = _surahHeaderKeys[firstNum];

    setState(() {
      _loadedSurahNumbers.insert(0, prevNum);
      _surahAyahs[prevNum] = prevAyahs;
    });

    // Pin the scroll position so it stays anchored at the current surah header
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (anchorKey?.currentContext != null) {
        Scrollable.ensureVisible(
          anchorKey!.currentContext!,
          alignment: 0.0,
          duration: Duration.zero,
        );
      }
      _isLoadingPrevious = false;
    });
  }

  void _updateActiveSurahOnScroll() {
    if (_loadedSurahNumbers.length <= 1) return;
    int? candidate;
    for (final sNum in _loadedSurahNumbers) {
      final ctx = _surahHeaderKeys[sNum]?.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final top = box.localToGlobal(Offset.zero).dy;
          if (top <= 260) {
            candidate = sNum;
          }
        }
      }
    }
    if (candidate != null && candidate != _activeSurahNumber) {
      setState(() {
        _activeSurahNumber = candidate!;
      });
      final meta = _getSurahMeta(candidate);
      if (meta != null) {
        StorageService.saveLastReadSurah(
          surahNumber: meta.number,
          surahNameAr: meta.arabicName,
          surahNameKu: meta.kurdishName,
          surahNameEn: meta.englishName,
          ayahNumber: 1,
        );
      }
    }
  }

  Future<void> _toggleAyahBookmark(QuranAyah ayah) async {
    final keyId = '${ayah.surah}:${ayah.ayah}';
    final isSaved = _bookmarkedAyahs.contains(keyId);
    final surahMeta = _getSurahMeta(ayah.surah) ?? widget.surah;
    if (isSaved) {
      await StorageService.removeQuranAyahBookmark(
        surahNumber: ayah.surah,
        ayahNumber: ayah.ayah,
      );
    } else {
      await StorageService.saveQuranAyahBookmark(
        surahNumber: ayah.surah,
        ayahNumber: ayah.ayah,
        surahNameAr: surahMeta.arabicName,
        surahNameKu: surahMeta.kurdishName,
        surahNameEn: surahMeta.englishName,
      );
    }
    if (mounted) {
      setState(() {
        if (isSaved) {
          _bookmarkedAyahs.remove(keyId);
        } else {
          _bookmarkedAyahs.add(keyId);
        }
      });
    }
  }

  Future<bool> _saveAyahWithNote(QuranAyah ayah) async {
    final keyId = '${ayah.surah}:${ayah.ayah}';
    if (_bookmarkedAyahs.contains(keyId)) {
      await _toggleAyahBookmark(ayah);
      return true;
    }

    final language = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _BookmarkNoteDialog(language: language),
    );
    if (note == null) return false;

    final surahMeta = _getSurahMeta(ayah.surah) ?? widget.surah;
    await StorageService.saveQuranAyahBookmark(
      surahNumber: ayah.surah,
      ayahNumber: ayah.ayah,
      surahNameAr: surahMeta.arabicName,
      surahNameKu: surahMeta.kurdishName,
      surahNameEn: surahMeta.englishName,
      note: note.trim(),
    );
    if (mounted) setState(() => _bookmarkedAyahs.add(keyId));
    return true;
  }

  /// Called when the audio service reports a new current ayah
  void _onAyahChanged(int? ayahNumber) {
    if (!mounted) return;
    final playingSurah = QuranAudioService.instance.currentSurahNumber;
    if (playingSurah == null ||
        !QuranAudioService.instance.hasExactTimingSupport) {
      if (_highlightedAyahNumber != null) {
        setState(() {
          _highlightedSurahNumber = null;
          _highlightedAyahNumber = null;
        });
      }
      return;
    }

    setState(() {
      _highlightedSurahNumber = playingSurah;
      _highlightedAyahNumber = ayahNumber;
    });

    // Auto-scroll to the current ayah (unless user is manually scrolling)
    if (ayahNumber != null && !_userScrollOverride) {
      _scrollToAyah(playingSurah, ayahNumber, animated: true);
    }
  }

  /// Scrolls the view so the given ayah is visible
  void _scrollToAyah(int surahNumber, int ayahNumber, {bool animated = true}) {
    final keyId = '$surahNumber:$ayahNumber';
    final key = (_useAyahList ? _ayahKeys : _bookAyahKeys)[keyId];
    if (key?.currentContext != null) {
      final renderObject = key!.currentContext!.findRenderObject();
      if (renderObject == null) return;
      final viewport = RenderAbstractViewport.of(renderObject);
      final targetBox = renderObject as RenderBox;
      final viewportBox = viewport as RenderBox;
      final targetTop = targetBox.localToGlobal(Offset.zero).dy;
      final targetBottom = targetBox
          .localToGlobal(
            Offset(0, targetBox.size.height),
          )
          .dy;
      final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
      final viewportBottom = viewportTop + viewportBox.size.height;
      if (targetTop >= viewportTop + 12 &&
          targetBottom <= viewportBottom - 12) {
        return;
      }
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.25,
        duration: animated ? const Duration(milliseconds: 500) : Duration.zero,
        curve: Curves.easeInOut,
      );
      return;
    }
  }

  /// Shows the per-ayah action menu (Play / Tafsir / Copy)
  void _showAyahActionMenu(QuranAyah ayah) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    String localized(String kurdish, String arabic, String english) {
      return lang == 'ku' ? kurdish : lang == 'ar' ? arabic : english;
    }
    final isRtl = lang == 'ku' || lang == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkBgAlt,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.panelBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.panelBorderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Ayah preview
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      ayah.text.length > 120
                          ? '${ayah.text.substring(0, 120)}...'
                          : ayah.text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.quranAyahText(
                          fontSize: 18, color: AppColors.gold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      localized(
                        'ئایەت ${ayah.ayah} · لاپەڕە ${ayah.page} · جوزء ${ayah.juz}',
                        'الآية ${ayah.ayah} · صفحة ${ayah.page} · الجزء ${ayah.juz}',
                        'Ayah ${ayah.ayah} · Page ${ayah.page} · Juz ${ayah.juz}',
                      ),
                      style: AppTheme.englishText(
                          fontSize: 12, color: AppColors.faintText),
                    ),
                  ),
                  Divider(color: AppColors.panelBorderColor, height: 1),

                  _AyahActionButton(
                    icon: _bookmarkedAyahs.contains('${ayah.surah}:${ayah.ayah}')
                        ? Icons.bookmark_remove_rounded
                        : Icons.bookmark_add_rounded,
                    iconColor: AppColors.gold,
                    label: _bookmarkedAyahs.contains('${ayah.surah}:${ayah.ayah}')
                        ? localized('لابردنی پاشەکەوت', 'إلغاء حفظ هذه الآية',
                          'Unsave This Ayah')
                        : localized('پاشەکەوتکردنی ئەم ئایەتە', 'حفظ هذه الآية',
                          'Save This Ayah'),
                    labelStyle: isRtl
                        ? AppTheme.kurdishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600)
                        : AppTheme.englishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600),
                    onTap: () async {
                      final keyId = '${ayah.surah}:${ayah.ayah}';
                      final wasSaved = _bookmarkedAyahs.contains(keyId);
                      final changed = await _saveAyahWithNote(ayah);
                      if (!changed) return;
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(wasSaved
                                ? localized('پاشەکەوتەکە لابرا', 'تم إلغاء حفظ الآية',
                                  'Ayah unsaved')
                                : localized('ئایەتەکە پاشەکەوت کرا', 'تم حفظ الآية',
                                  'Ayah saved')),
                          backgroundColor: AppColors.softSurface,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  // ▶ Play
                  _AyahActionButton(
                    icon: Icons.play_arrow_rounded,
                    iconColor: AppColors.gold,
                    label: lang == 'ku'
                        ? 'گوێگرتن'
                        : (lang == 'ar' ? 'تشغيل' : 'Play'),
                    labelStyle: isRtl
                        ? AppTheme.kurdishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600)
                        : AppTheme.englishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      final totalAyahs = _surahAyahs[ayah.surah]?.length ??
                          _getSurahMeta(ayah.surah)?.numberOfAyahs ??
                          ayah.ayah;
                      _playFromAyah(ayah, totalAyahs);
                    },
                  ),

                  // 📖 Tafsir
                  _AyahActionButton(
                    icon: Icons.auto_stories_rounded,
                    iconColor: AppColors.accent1,
                    label: localized(
                      'تەفسیری ئەم ئایەتە', 'تفسير هذه الآية', 'Open Tafsir'),
                    labelStyle: isRtl
                        ? AppTheme.kurdishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600)
                        : AppTheme.englishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openTafsir(ayah);
                    },
                  ),

                  // 📋 Copy
                  _AyahActionButton(
                    icon: Icons.copy_rounded,
                    iconColor: AppColors.accent3,
                    label: localized(
                      'کۆپیکردنی ئایەتەکە', 'نسخ نص الآية', 'Copy Ayah Text'),
                    labelStyle: isRtl
                        ? AppTheme.kurdishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600)
                        : AppTheme.englishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: ayah.text));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                              localized('ئایەتەکە کۆپی کرا', 'تم نسخ الآية',
                                'Ayah copied')),
                          backgroundColor: AppColors.softSurface,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  // 📤 Share Ayah
                  _AyahActionButton(
                    icon: Icons.share_rounded,
                    iconColor: AppColors.gold,
                    label: localized(
                      'بڵاوکردنەوەی ئەم ئایەتە', 'مشاركة هذه الآية', 'Share This Ayah'),
                    labelStyle: isRtl
                        ? AppTheme.kurdishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600)
                        : AppTheme.englishText(
                            fontSize: 14,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      final buffer = StringBuffer();
                      buffer.writeln('﴿ ${ayah.text} ﴾');
                      buffer.writeln();
                      final surahMeta = _getSurahMeta(ayah.surah) ?? widget.surah;
                      final surahName = lang == 'ku'
                          ? surahMeta.kurdishName
                          : lang == 'ar'
                              ? surahMeta.arabicName
                              : surahMeta.englishName;
                      buffer.writeln(
                        '$surahName - ${localized('ئایەت', 'الآية', 'Ayah')} ${ayah.ayah}');
                      buffer.writeln(localized('نەدا', 'ندا', 'Nada Quran'));
                      AppShareService.share(context, buffer.toString());
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Starts audio playback from the given ayah
  void _playFromAyah(QuranAyah ayah, int totalAyahs) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final surahMeta = _getSurahMeta(ayah.surah) ?? widget.surah;
    final surahName = lang == 'ku'
        ? surahMeta.kurdishName
        : lang == 'ar'
            ? surahMeta.arabicName
            : surahMeta.englishName;
    final hasExact = QuranAudioService.instance.hasExactTimingSupport;

    setState(() {
      _showPlayerBar = true;
      _highlightedSurahNumber = hasExact ? ayah.surah : null;
      _highlightedAyahNumber = hasExact ? ayah.ayah : null;
      _resumePositionSeconds = null;
      _userScrollOverride = false;
    });

    if (hasExact) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(ayah.surah, ayah.ayah, animated: false);
      });
    }

    QuranAudioService.instance.playFromAyah(
      surahNumber: ayah.surah,
      surahName: surahName,
      ayahNumber: ayah.ayah,
      totalAyahs: totalAyahs,
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              hasExact ? Icons.my_location_rounded : Icons.music_note_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasExact
                    ? (lang == 'ku'
                        ? 'گوێگرتن لە ئایەت ${ayah.ayah}'
                        : lang == 'ar'
                            ? 'الاستماع من الآية ${ayah.ayah}'
                            : 'Playing from Ayah ${ayah.ayah}')
                    : (lang == 'ku'
                        ? 'پەخشکردنی دەنگی سوورەتەکە'
                        : lang == 'ar'
                            ? 'تشغيل صوت السورة كاملة'
                            : 'Playing Surah audio'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.softSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      ),
    );
  }

  @override
  void dispose() {
    for (final recognizer in _bookTapRecognizers) {
      recognizer.dispose();
    }
    _bookTapRecognizers.clear();
    _searchController.dispose();
    _scrollController.dispose();
    _scrollOverrideTimer?.cancel();
    _ayahStreamSub?.cancel();
    super.dispose();
  }

  void _jumpToAyah(int ayahNumber) {
    final ayahs = _activeAyahs;
    if (ayahNumber < 1 || ayahNumber > ayahs.length) return;
    AppHaptics.selectionClick();
    setState(() {
      _highlightedSurahNumber = _activeSurahNumber;
      _highlightedAyahNumber = ayahNumber;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToAyah(_activeSurahNumber, ayahNumber, animated: true);
    });
  }

  void _jumpToPage(int pageNumber) {
    AppHaptics.selectionClick();
    final ayahs = _activeAyahs;
    final match = ayahs.firstWhere(
      (a) => a.page == pageNumber,
      orElse: () => ayahs.firstWhere(
        (a) => a.page >= pageNumber,
        orElse: () => ayahs.isNotEmpty ? ayahs.first : QuranAyah(surah: _activeSurahNumber, ayah: 1, text: '', page: 1, juz: 1),
      ),
    );
    _jumpToAyah(match.ayah);
  }

  Widget _buildPageMarker(int page, int juz, String language, bool isRtl) {
    final pageLabel = language == 'ku'
        ? 'لاپەڕە $page'
        : language == 'ar'
            ? 'صفحة $page'
            : 'Page $page';
    final juzLabel = language == 'ku'
        ? 'جوزء $juz'
        : language == 'ar'
            ? 'الجزء $juz'
            : 'Juz $juz';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.panelBorderColor.withValues(alpha: 0.35),
              height: 1,
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$pageLabel · $juzLabel',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.faintText.withValues(alpha: 0.75),
                letterSpacing: 0.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.panelBorderColor.withValues(alpha: 0.35),
              height: 1,
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndJumpBar(BuildContext context, String language, bool isRtl) {
    final query = _searchQuery.trim();
    final parsedNumber = int.tryParse(query);
    final activeAyahs = _activeAyahs;
    final activeSurah = _activeSurah;

    // Find ayah match in current surah
    QuranAyah? matchedAyah;
    if (parsedNumber != null && parsedNumber >= 1 && parsedNumber <= activeAyahs.length) {
      matchedAyah = activeAyahs[parsedNumber - 1];
    }

    // Find page match in current surah
    QuranAyah? matchedPageAyah;
    if (parsedNumber != null &&
        parsedNumber >= activeSurah.startPage &&
        parsedNumber <= activeSurah.endPage) {
      matchedPageAyah = activeAyahs.firstWhere(
        (a) => a.page == parsedNumber,
        orElse: () => activeAyahs.isNotEmpty ? activeAyahs.first : QuranAyah(surah: _activeSurahNumber, ayah: 1, text: '', page: 1, juz: 1),
      );
    }

    final textMatches = (query.isNotEmpty && parsedNumber == null)
        ? activeAyahs.where((a) => a.text.contains(query)).take(8).toList()
        : <QuranAyah>[];

    final quickAyahs = <int>[1];
    if (activeAyahs.length > 20) {
      final step = (activeAyahs.length / 5).round();
      for (int i = step; i < activeAyahs.length; i += step) {
        if (!quickAyahs.contains(i)) quickAyahs.add(i);
      }
    }
    if (activeAyahs.isNotEmpty && !quickAyahs.contains(activeAyahs.length)) {
      quickAyahs.add(activeAyahs.length);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBgAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkPanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.panelBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          onSubmitted: (_) {
                            if (matchedAyah != null) {
                              _jumpToAyah(matchedAyah.ayah);
                            } else if (matchedPageAyah != null) {
                              _jumpToPage(parsedNumber!);
                            } else if (textMatches.isNotEmpty) {
                              _jumpToAyah(textMatches.first.ayah);
                            }
                          },
                          style: AppTheme.englishText(
                            fontSize: 13,
                            color: AppColors.cream,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            hintText: language == 'ku'
                                ? 'ئایەت (١ - ${activeAyahs.length}) یان لاپەڕە'
                                : language == 'ar'
                                    ? 'الآية (١ - ${activeAyahs.length}) أو الصفحة'
                                    : 'Ayah (1 - ${activeAyahs.length}) or Page',
                            hintStyle: isRtl
                                ? AppTheme.kurdishText(
                                    fontSize: 12, color: AppColors.faintText)
                                : AppTheme.englishText(
                                    fontSize: 12, color: AppColors.faintText),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(Icons.close_rounded,
                              size: 16, color: AppColors.faintText),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (matchedAyah != null) {
                    _jumpToAyah(matchedAyah.ayah);
                  } else if (matchedPageAyah != null) {
                    _jumpToPage(parsedNumber!);
                  } else if (textMatches.isNotEmpty) {
                    _jumpToAyah(textMatches.first.ayah);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  language == 'ku'
                      ? 'بڕۆ'
                      : language == 'ar'
                          ? 'انتقال'
                          : 'Go',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),

          if (matchedAyah != null || matchedPageAyah != null || textMatches.isNotEmpty) ...[
            const SizedBox(height: 10),
            if (matchedAyah != null)
              GestureDetector(
                onTap: () => _jumpToAyah(matchedAyah!.ayah),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language == 'ku'
                                  ? 'ئایەت ${matchedAyah.ayah} · لاپەڕە ${matchedAyah.page}'
                                  : language == 'ar'
                                      ? 'الآية ${matchedAyah.ayah} · صفحة ${matchedAyah.page}'
                                      : 'Ayah ${matchedAyah.ayah} · Page ${matchedAyah.page}',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              matchedAyah.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                              style: AppTheme.quranAyahText(fontSize: 13, color: AppColors.cream),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (matchedPageAyah != null && (matchedAyah == null || matchedAyah.ayah != matchedPageAyah.ayah))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: () => _jumpToPage(parsedNumber!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.softSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.panelBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            language == 'ku'
                                ? 'سەرەتای لاپەڕەی $parsedNumber (ئایەت ${matchedPageAyah.ayah})'
                                : language == 'ar'
                                    ? 'بداية الصفحة $parsedNumber (الآية ${matchedPageAyah.ayah})'
                                    : 'Start of Page $parsedNumber (Ayah ${matchedPageAyah.ayah})',
                            style: AppTheme.englishText(fontSize: 12, color: AppColors.cream),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.faintText),
                      ],
                    ),
                  ),
                ),
              ),

            if (textMatches.isNotEmpty && matchedAyah == null)
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                margin: const EdgeInsets.only(top: 6),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: textMatches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, idx) {
                    final item = textMatches[idx];
                    return GestureDetector(
                      onTap: () => _jumpToAyah(item.ayah),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.softSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.ayah}',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: AppTheme.quranAyahText(fontSize: 13, color: AppColors.cream),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              language == 'ku' ? 'پـ ${item.page}' : language == 'ar' ? 'صـ ${item.page}' : 'p. ${item.page}',
                              style: TextStyle(fontSize: 10, color: AppColors.faintText),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],

          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  language == 'ku' ? 'ئایەت:' : language == 'ar' ? 'آية:' : 'Ayah:',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
                const SizedBox(width: 6),
                for (final aNum in quickAyahs)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => _jumpToAyah(aNum),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$aNum',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (activeSurah.startPage != activeSurah.endPage) ...[
                  const SizedBox(width: 6),
                  Text(
                    language == 'ku' ? 'پەڕە:' : language == 'ar' ? 'صفحة:' : 'Page:',
                    style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                  ),
                  const SizedBox(width: 6),
                  for (int p = activeSurah.startPage; p <= activeSurah.endPage; p++)
                    if (p == activeSurah.startPage ||
                        p == activeSurah.endPage ||
                        p == ((activeSurah.startPage + activeSurah.endPage) ~/ 2))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => _jumpToPage(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '$p',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openTafsir(QuranAyah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _TafsirSheet(
          surahNumber: ayah.surah,
          ayah: ayah,
          initialTafsirId: _selectedTafsirId,
          onTafsirChanged: (id) => _selectedTafsirId = id,
        );
      },
    );
  }

  String _formatResumeTime(double seconds) {
    final total = seconds.toInt();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // COMPACT SURAH HEADER (Surah Name & Bismillah Beside Each Other)
  // ═══════════════════════════════════════════════════════════════════════════════
  Widget _buildSurahHeader(QuranSurahMeta surah, String language, bool isRtl) {
    final hasBismillah = surah.number != 9 && surah.number != 1;

    return Container(
      key: _surahHeaderKeys[surah.number],
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: hasBismillah
          ? Row(
              textDirection: TextDirection.rtl,
              children: [
                // Right: Surah Name beside Bismillah
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'سُورَةُ ${surah.arabicName}',
                        textDirection: TextDirection.rtl,
                        style: AppTheme.quranAyahText(
                          fontSize: 15,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Center: Bismillah
                Expanded(
                  flex: 8,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _bismillah,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.quranAyahText(
                          fontSize: 16,
                          color: AppColors.cream,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                // Left: Decorative ornament balancing the right side
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '۞',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gold.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'سُورَةُ ${surah.arabicName}',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.quranAyahText(
                  fontSize: 18,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildKhatmQuranBanner(String language, bool isRtl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.darkPanel,
            AppColors.gold.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.gold, size: 36),
          const SizedBox(height: 12),
          Text(
            'خَتْمُ القُرْآنِ الكَرِيمِ',
            style: AppTheme.quranAyahText(
              fontSize: 26,
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'صَدَقَ اللَّهُ العَظِيمُ وَبَلَّغَ رَسُولُهُ الكَرِيمُ',
            textAlign: TextAlign.center,
            style: AppTheme.quranAyahText(
              fontSize: 18,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // BOOK LAYOUT — Continuous Flowing Quran Pages
  // ═══════════════════════════════════════════════════════════════════════════════
  Widget _buildBookLayout(
    BuildContext context,
    String language,
    bool isRtl,
    AppLocalizations? loc,
    double fontSize,
  ) {
    for (final recognizer in _bookTapRecognizers) {
      recognizer.dispose();
    }
    _bookTapRecognizers.clear();

    final contentWidgets = <Widget>[];

    for (int sIndex = 0; sIndex < _loadedSurahNumbers.length; sIndex++) {
      final sNum = _loadedSurahNumbers[sIndex];
      final surah = _getSurahMeta(sNum);
      final ayahs = _surahAyahs[sNum] ?? const [];
      if (surah == null || ayahs.isEmpty) continue;

      // 1. Compact Surah Header (Surah name & Bismillah beside each other)
      contentWidgets.add(_buildSurahHeader(surah, language, isRtl));

      // 2. Pages of this surah
      final pageMap = <int, List<QuranAyah>>{};
      for (final ayah in ayahs) {
        (pageMap[ayah.page] ??= []).add(ayah);
      }

      final sortedPages = pageMap.keys.toList()..sort();
      for (int pIdx = 0; pIdx < sortedPages.length; pIdx++) {
        final pageNum = sortedPages[pIdx];
        final pageAyahs = pageMap[pageNum]!;
        final ayahSpans = <InlineSpan>[];

        for (final ayah in pageAyahs) {
          final isHighlighted = _highlightedSurahNumber == ayah.surah &&
              _highlightedAyahNumber == ayah.ayah;
          final keyId = '${ayah.surah}:${ayah.ayah}';
          final recognizer = TapGestureRecognizer()
            ..onTap = () => _showAyahActionMenu(ayah);
          _bookTapRecognizers.add(recognizer);

          ayahSpans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                key: _bookAyahKeys[keyId],
                width: 0,
                height: 0,
              ),
            ),
          );
          ayahSpans.add(
            TextSpan(
              text: ayah.text,
              recognizer: recognizer,
              style: isHighlighted
                  ? AppTheme.quranAyahText(
                      fontSize: fontSize,
                      color: AppColors.cream,
                    ).copyWith(
                      backgroundColor: AppColors.gold.withValues(alpha: 0.22),
                    )
                  : null,
            ),
          );
          ayahSpans.add(
            TextSpan(
              text: ' ﴿${ayah.ayah}﴾ ',
              recognizer: recognizer,
              style: AppTheme.quranAyahText(
                fontSize: fontSize * 0.72,
                color: AppColors.gold,
              ).copyWith(
                backgroundColor: isHighlighted
                    ? AppColors.gold.withValues(alpha: 0.22)
                    : null,
              ),
            ),
          );
        }

        contentWidgets.add(
          Text.rich(
            TextSpan(children: ayahSpans),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: AppTheme.quranAyahText(fontSize: fontSize),
          ),
        );

        if (pIdx < sortedPages.length - 1) {
          final nextPageNum = sortedPages[pIdx + 1];
          final nextJuz = pageMap[nextPageNum]?.first.juz ?? pageAyahs.first.juz;
          contentWidgets.add(_buildPageMarker(nextPageNum, nextJuz, language, isRtl));
        }
      }

      // 3. Khatm banner if at end of Quran
      if (sNum == 114) {
        contentWidgets.add(_buildKhatmQuranBanner(language, isRtl));
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: contentWidgets,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // AYAH LIST LAYOUT — Continuous Ayah Cards
  // ═══════════════════════════════════════════════════════════════════════════════
  Widget _buildAyahListLayout(
    BuildContext context,
    String language,
    bool isRtl,
    AppLocalizations? loc,
    double fontSize,
  ) {
    final contentWidgets = <Widget>[];

    for (int sIndex = 0; sIndex < _loadedSurahNumbers.length; sIndex++) {
      final sNum = _loadedSurahNumbers[sIndex];
      final surah = _getSurahMeta(sNum);
      final ayahs = _surahAyahs[sNum] ?? const [];
      if (surah == null || ayahs.isEmpty) continue;

      // 1. Compact Surah Header (Surah name & Bismillah beside each other)
      contentWidgets.add(_buildSurahHeader(surah, language, isRtl));

      // 2. Ayahs list
      for (int aIdx = 0; aIdx < ayahs.length; aIdx++) {
        final ayah = ayahs[aIdx];
        final isHighlighted = _highlightedSurahNumber == ayah.surah &&
            _highlightedAyahNumber == ayah.ayah;
        final keyId = '${ayah.surah}:${ayah.ayah}';
        final key = _ayahKeys[keyId];
        final isNewPage = aIdx > 0 && ayahs[aIdx].page != ayahs[aIdx - 1].page;

        contentWidgets.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNewPage)
                _buildPageMarker(ayah.page, ayah.juz, language, isRtl),
              _AyahWidget(
                key: key,
                ayah: ayah,
                isHighlighted: isHighlighted,
                onTap: () => _showAyahActionMenu(ayah),
                isRtl: isRtl,
                fontSize: fontSize,
              ),
            ],
          ),
        );
      }

      // 3. Khatm banner if at end of Quran
      if (sNum == 114) {
        contentWidgets.add(_buildKhatmQuranBanner(language, isRtl));
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      child: Column(
        children: contentWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSurah = _activeSurah;
    final loc = AppLocalizations.of(context);
    final language = loc?.locale.languageCode ?? 'ku';
    final isRtl = language == 'ku' || language == 'ar';
    final name = language == 'ku'
        ? activeSurah.kurdishName
        : language == 'ar'
            ? activeSurah.arabicName
            : activeSurah.englishName;

    final pageRange = activeSurah.startPage == activeSurah.endPage
        ? '${activeSurah.startPage}'
        : '${activeSurah.startPage} - ${activeSurah.endPage}';
    final pageLabel = language == 'ku'
        ? 'لاپەڕە $pageRange'
        : language == 'ar'
            ? 'صـ $pageRange'
            : 'p. $pageRange';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              AppColors.darkBgAlt,
              AppColors.softSurface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back,
                            size: 18, color: AppColors.cream),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection:
                                isRtl ? TextDirection.rtl : TextDirection.ltr,
                            style: isRtl
                                ? AppTheme.kurdishTitle(
                                    fontSize: 18, color: AppColors.gold)
                                : AppTheme.englishTitle(
                                    fontSize: 18, color: AppColors.gold),
                          ),
                          Text(
                            language == 'ku'
                                ? '${loc?.translate('surah') ?? 'سورەت'} ${activeSurah.number} · $pageLabel'
                                : language == 'ar'
                                    ? '${loc?.translate('surah') ?? 'السورة'} ${activeSurah.number} · $pageLabel'
                                    : '${loc?.translate('surah') ?? 'Surah'} ${activeSurah.number} · $pageLabel · ${activeSurah.englishName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection:
                                isRtl ? TextDirection.rtl : TextDirection.ltr,
                            style: isRtl
                                ? AppTheme.kurdishText(
                                    fontSize: 11, color: AppColors.faintText)
                                : AppTheme.englishText(
                                    fontSize: 11, color: AppColors.faintText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Header Right Actions (Search Button, Listen Button, Layout menu, Font size menu)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showSearch = !_showSearch;
                                  if (!_showSearch) {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: _showSearch
                                      ? AppColors.gold
                                      : AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.gold),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showSearch
                                          ? Icons.close_rounded
                                          : Icons.search_rounded,
                                      color: _showSearch
                                          ? Colors.black
                                          : AppColors.gold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      language == 'ku'
                                          ? 'گەڕان'
                                          : language == 'ar'
                                              ? 'بحث'
                                              : 'Find',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _showSearch
                                            ? Colors.black
                                            : AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final wasShowing = _showPlayerBar;
                                setState(() {
                                  _showPlayerBar = !_showPlayerBar;
                                });
                                if (!wasShowing) {
                                  if (QuranAudioService.instance.currentSurahNumber !=
                                      activeSurah.number) {
                                    setState(() {
                                      _highlightedSurahNumber = null;
                                      _highlightedAyahNumber = null;
                                    });
                                    QuranAudioService.instance.playSurah(
                                      activeSurah.number,
                                      name,
                                      totalAyahs: _activeAyahs.length,
                                    );
                                  } else if (!QuranAudioService.instance.player.playing) {
                                    QuranAudioService.instance.resume();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showPlayerBar
                                      ? AppColors.gold
                                      : AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.gold),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showPlayerBar
                                          ? Icons.volume_up_rounded
                                          : Icons.play_arrow_rounded,
                                      color: _showPlayerBar
                                          ? Colors.black
                                          : AppColors.gold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      language == 'ku'
                                          ? 'گوێگرتن'
                                          : language == 'ar'
                                              ? 'استماع'
                                              : 'Listen',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _showPlayerBar
                                            ? Colors.black
                                            : AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: language == 'ku'
                                  ? 'شێوازی خوێندنەوە'
                                  : language == 'ar'
                                      ? 'نمط القراءة'
                                      : 'Reading layout',
                              icon: Icon(Icons.view_agenda_outlined,
                                  color: AppColors.gold, size: 20),
                              color: AppColors.darkPanel,
                              onSelected: (value) => _setReadingLayout(value == 'list'),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'book',
                                  child: Text(
                                    language == 'ku'
                                        ? 'شێوازی کتێب'
                                        : language == 'ar'
                                            ? 'نمط المصحف'
                                            : 'Book layout',
                                    style: isRtl
                                        ? AppTheme.kurdishText(
                                            color: AppColors.cream, fontSize: 13)
                                        : AppTheme.englishText(
                                            color: AppColors.cream, fontSize: 13),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'list',
                                  child: Text(
                                    language == 'ku'
                                        ? 'ئایەت بە ئایەت'
                                        : language == 'ar'
                                            ? 'آية بعد آية'
                                            : 'Ayah list',
                                    style: isRtl
                                        ? AppTheme.kurdishText(
                                            color: AppColors.cream, fontSize: 13)
                                        : AppTheme.englishText(
                                            color: AppColors.cream, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<double>(
                              tooltip: language == 'ku'
                                  ? 'قەبارەی دەقی قورئان'
                                  : language == 'ar'
                                      ? 'حجم نص القرآن'
                                      : 'Quran text size',
                              icon: Icon(Icons.format_size_rounded,
                                  color: AppColors.gold, size: 20),
                              color: AppColors.darkPanel,
                              onSelected: _setQuranFontSize,
                              itemBuilder: (context) => [
                                for (final size in [18.0, 22.0, 24.0, 28.0, 32.0])
                                  PopupMenuItem<double>(
                                    value: size,
                                    child: Text(
                                      '${size.toInt()} px',
                                      style: AppTheme.englishText(
                                        color: size == _quranFontSize
                                            ? AppColors.gold
                                            : AppColors.cream,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search & Quick Jump Panel
              if (_showSearch)
                _buildSearchAndJumpBar(context, language, isRtl),

              // Resume Audio Banner
              if (_resumePositionSeconds != null && !_showPlayerBar)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPlayerBar = true;
                      _highlightedSurahNumber = null;
                      _highlightedAyahNumber = null;
                    });
                    if (QuranAudioService.instance.currentSurahNumber !=
                        activeSurah.number) {
                      QuranAudioService.instance.playSurah(
                        activeSurah.number,
                        name,
                        totalAyahs: _activeAyahs.length,
                      );
                    }
                    setState(() => _resumePositionSeconds = null);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.18),
                          AppColors.darkBgAlt,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: AppColors.gold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            language == 'ku'
                                ? 'بەردەوامبوونەوەی گوێگرتن'
                                : language == 'ar'
                                    ? 'استأنف الاستماع'
                                    : 'Resume Listening',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isRtl
                                ? AppTheme.kurdishText(
                                    fontSize: 11,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold)
                                : AppTheme.englishText(
                                    fontSize: 11,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: AppColors.gold, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                _formatResumeTime(_resumePositionSeconds!),
                                style: AppTheme.englishText(
                                    fontSize: 10,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ═══════════════════════════════════════════════════════════════
              // CONTINUOUS MULTI-SURAH SCROLL VIEW
              // ═══════════════════════════════════════════════════════════════
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification &&
                              notification.dragDetails != null) {
                            _userScrollOverride = true;
                            _scrollOverrideTimer?.cancel();
                            _scrollOverrideTimer =
                                Timer(const Duration(seconds: 3), () {
                              if (mounted) _userScrollOverride = false;
                            });
                          }

                          // Auto-load next surah when scrolling near bottom
                          if (notification.metrics.extentAfter < 1600) {
                            _loadNextSurah();
                          }

                          // Auto-load previous surah purely by scrolling up towards top
                          final isUserScrollingUp =
                              (notification is ScrollUpdateNotification &&
                                      (notification.scrollDelta ?? 0) < 0) ||
                                  (notification is OverscrollNotification &&
                                      notification.overscroll < 0);

                          if (isUserScrollingUp &&
                              notification.metrics.pixels <= 160 &&
                              !_isLoadingPrevious &&
                              _loadedSurahNumbers.isNotEmpty &&
                              _loadedSurahNumbers.first > 1) {
                            _loadPreviousSurah();
                          }

                          _updateActiveSurahOnScroll();
                          return false;
                        },
                        child: _useAyahList
                            ? _buildAyahListLayout(
                                context,
                                language,
                                isRtl,
                                loc,
                                _quranFontSize,
                              )
                            : _buildBookLayout(
                                context,
                                language,
                                isRtl,
                                loc,
                                _quranFontSize,
                              ),
                      ),
              ),

              // Persistent Floating Audio Control Bar
              if (_showPlayerBar)
                QuranAudioPlayerWidget(
                  surahNumber: QuranAudioService.instance.currentSurahNumber ?? _activeSurahNumber,
                  surahName: QuranAudioService.instance.currentSurahName ?? name,
                  totalAyahs: _activeAyahs.length,
                  onClose: () {
                    setState(() {
                      _showPlayerBar = false;
                      _highlightedSurahNumber = null;
                      _highlightedAyahNumber = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INDIVIDUAL AYAH WIDGET — Tappable, Highlightable
// ═══════════════════════════════════════════════════════════════════════════════

class _AyahWidget extends StatelessWidget {
  final QuranAyah ayah;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isRtl;
  final double fontSize;

  const _AyahWidget({
    super.key,
    required this.ayah,
    required this.isHighlighted,
    required this.onTap,
    required this.isRtl,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.gold.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(
                color: AppColors.gold.withValues(alpha: 0.35), width: 1)
            : null,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // Ayah number badge
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHighlighted
                      ? AppColors.gold.withValues(alpha: 0.25)
                      : AppColors.gold.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.5),
                    width: isHighlighted ? 1.5 : 1,
                  ),
                  boxShadow: isHighlighted
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${ayah.ayah}',
                    style: AppTheme.englishText(
                      fontSize: 10,
                      color: isHighlighted
                          ? AppColors.gold
                          : AppColors.gold.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Ayah text
            Expanded(
              child: Text(
                ayah.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: AppTheme.quranAyahText(
                  fontSize: fontSize,
                  color: isHighlighted ? AppColors.gold : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkNoteDialog extends StatefulWidget {
  final String language;

  const _BookmarkNoteDialog({required this.language});

  @override
  State<_BookmarkNoteDialog> createState() => _BookmarkNoteDialogState();
}

class _BookmarkNoteDialogState extends State<_BookmarkNoteDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
        title: Text(widget.language == 'ku'
          ? 'پاشەکەوتکردنی ئایەت'
          : widget.language == 'ar'
            ? 'حفظ الآية'
            : 'Save Ayah'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: widget.language == 'ku'
              ? 'تێبینی زیاد بکە (ئارەزوومەندانەیە)'
              : widget.language == 'ar'
                  ? 'أضف ملاحظة (اختياري)'
                  : 'Add a note (optional)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.language == 'ku'
              ? 'پاشگەزبوونەوە'
              : widget.language == 'ar'
                ? 'إلغاء'
                : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
            child: Text(widget.language == 'ku'
              ? 'پاشەکەوتکردن'
              : widget.language == 'ar'
                ? 'حفظ'
                : 'Save'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AYAH ACTION BUTTON — Reusable menu item in the bottom sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _AyahActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  const _AyahActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.15),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.faintText, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAFSIR SHEET (unchanged from original)
// ═══════════════════════════════════════════════════════════════════════════════

class _TafsirSheet extends StatefulWidget {
  final int surahNumber;
  final QuranAyah ayah;
  final String initialTafsirId;
  final ValueChanged<String> onTafsirChanged;

  const _TafsirSheet({
    required this.surahNumber,
    required this.ayah,
    required this.initialTafsirId,
    required this.onTafsirChanged,
  });

  @override
  State<_TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<_TafsirSheet> {
  late String _tafsirId;
  late Future<String?> _tafsirFuture;
  late QuranAyah _currentAyah;
  List<QuranAyah> _ayahs = const [];
  bool _signShowAyah = true;
  String? _kurdishMeaning;

  @override
  void initState() {
    super.initState();
    _tafsirId = widget.initialTafsirId;
    _currentAyah = widget.ayah;
    _tafsirFuture = QuranService.instance
        .getTafsir(_tafsirId, widget.surahNumber, _currentAyah.ayah);
    _loadAyahs();
    _loadKurdishMeaning();
  }

  Future<void> _loadKurdishMeaning() async {
    final meaning = await QuranService.instance
        .getTafsir('asan', widget.surahNumber, _currentAyah.ayah);
    if (!mounted) return;
    setState(() => _kurdishMeaning = meaning);
  }

  Future<void> _loadAyahs() async {
    final ayahs =
        await QuranService.instance.loadAyahsForSurah(widget.surahNumber);
    if (!mounted) return;
    setState(() => _ayahs = ayahs);
  }

  void _moveAyah(int offset) {
    final currentIndex =
        _ayahs.indexWhere((ayah) => ayah.ayah == _currentAyah.ayah);
    final nextIndex = currentIndex + offset;
    if (currentIndex < 0 || nextIndex < 0 || nextIndex >= _ayahs.length) return;

    final nextAyah = _ayahs[nextIndex];
    setState(() {
      _currentAyah = nextAyah;
      _tafsirFuture = QuranService.instance
          .getTafsir(_tafsirId, widget.surahNumber, nextAyah.ayah);
    });
    _loadKurdishMeaning();
  }

  void _selectTafsir(String id) {
    if (id == _tafsirId) return;
    StorageService.savePreferredTafsir(id);
    setState(() {
      _tafsirId = id;
      _tafsirFuture = QuranService.instance
          .getTafsir(_tafsirId, widget.surahNumber, _currentAyah.ayah);
    });
    widget.onTafsirChanged(id);
    if (id == 'sign') _loadKurdishMeaning();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = loc?.locale.languageCode ?? 'ku';
    final isRtl = language == 'ku' || language == 'ar';
    String localized(String kurdish, String arabic, String english) {
      return language == 'ku' ? kurdish : language == 'ar' ? arabic : english;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        final currentIndex =
            _ayahs.indexWhere((ayah) => ayah.ayah == _currentAyah.ayah);
        final canGoBack = currentIndex > 0;
        final canGoNext = currentIndex >= 0 && currentIndex < _ayahs.length - 1;

        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkBgAlt,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.panelBorderColor),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.panelBorderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: canGoBack ? () => _moveAyah(-1) : null,
                    tooltip: loc?.translate('previousAyah') ?? 'ئایەتی پێشوو',
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.gold,
                  ),
                  Expanded(
                    child: Text(
                      language == 'ku'
                          ? '${loc?.translate('surah') ?? 'سورەت'} ${widget.surahNumber} · ${loc?.translate('ayah') ?? 'ئایەت'} ${_currentAyah.ayah} · لاپەڕە ${_currentAyah.page}'
                          : language == 'ar'
                              ? '${loc?.translate('surah') ?? 'السورة'} ${widget.surahNumber} · ${loc?.translate('ayah') ?? 'الآية'} ${_currentAyah.ayah} · صفحة ${_currentAyah.page}'
                              : '${loc?.translate('surah') ?? 'Surah'} ${widget.surahNumber} · ${loc?.translate('ayah') ?? 'Ayah'} ${_currentAyah.ayah} · Page ${_currentAyah.page}',
                      textAlign: TextAlign.center,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: isRtl
                          ? AppTheme.kurdishText(
                              fontSize: 12, color: AppColors.mutedText)
                          : AppTheme.englishText(
                              fontSize: 12, color: AppColors.mutedText),
                    ),
                  ),
                  IconButton(
                    onPressed: canGoNext ? () => _moveAyah(1) : null,
                    tooltip: loc?.translate('nextAyah') ?? 'ئایەتی داهاتوو',
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _currentAyah.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style:
                    AppTheme.quranAyahText(fontSize: 26, color: AppColors.gold),
              ),
              const SizedBox(height: 18),
              Text(
                loc?.translate('tafsir') ?? 'تەفسیر',
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: isRtl
                    ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold)
                    : AppTheme.englishTitle(
                        fontSize: 14, color: AppColors.gold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kQuranTafsirOptions.map((option) {
                  final selected = option.id == _tafsirId;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: selected,
                    onSelected: (_) => _selectTafsir(option.id),
                    backgroundColor: AppColors.panelColor,
                    selectedColor: AppColors.gold.withValues(alpha: 0.2),
                    labelStyle: AppTheme.kurdishText(
                      color: selected ? AppColors.gold : AppColors.cream,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                        color: selected
                            ? AppColors.gold
                            : AppColors.panelBorderColor),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.panelColor,
                  border: Border.all(color: AppColors.panelBorderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _tafsirId == 'sign'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sign_language_rounded,
                                        color: AppColors.gold, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                        localized('پیتە ئاماژەییەکان بۆ نابیستان',
                                          'تهجئة الإشارات', 'Sign Fingerspelling'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Toggle between Arabic Ayah and Kurdish Asan Tafsir
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _signShowAyah
                                      ? localized('دەقی ئایەت', 'نص الآية', 'Ayah')
                                      : localized('تەفسیر', 'التفسير', 'Tafsir'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: _signShowAyah,
                                      activeThumbColor: AppColors.gold,
                                      activeTrackColor:
                                          AppColors.gold.withValues(alpha: 0.3),
                                      onChanged: (val) {
                                        setState(() => _signShowAyah = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localized(
                              'دەست لەسەر هەر هێمایەکی دەست دابگرە بۆ بینینی وردەکاری و فێربوون',
                              'اضغط على أي إشارة باليد لعرض التفاصيل والتعلم',
                              'Tap any hand sign to view details and learn',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.faintText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SignLanguageTextWidget(
                            text: _signShowAyah
                                ? _currentAyah.text
                                : (_kurdishMeaning ?? _currentAyah.text),
                            color: AppColors.cream,
                            scale: 1.05,
                          ),
                        ],
                      )
                    : FutureBuilder<String?>(
                        future: _tafsirFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final text = snapshot.data;
                          if (text == null || text.isEmpty) {
                            return Text(
                              loc?.translate('tafsirUnavailable') ??
                                  'ئەم تەفسیرە بۆ ئەم ئایەتە هێشتا بەردەست نییە.',
                              textDirection:
                                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                              style: isRtl
                                  ? AppTheme.kurdishText(
                                      fontSize: 13, color: AppColors.faintText)
                                  : AppTheme.englishText(
                                      fontSize: 13, color: AppColors.faintText),
                            );
                          }
                          return Text(
                            text,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: AppTheme.tafsirText(
                              tafsirId: _tafsirId,
                              fontSize: 15,
                              color: AppColors.cream,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
