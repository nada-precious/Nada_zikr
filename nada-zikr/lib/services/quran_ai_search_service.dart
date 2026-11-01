import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'quran_service.dart';

class QuranAiSearchResult {
  final int surahNumber;
  final int ayahNumber;
  final String surahArabicName;
  final String surahKurdishName;
  final String? surahKurmanjiName;
  final String surahEnglishName;
  final String ayahArabicText;
  final int pageNumber;
  final int juzNumber;
  final String reasonKu;
  final String? reasonKmr;
  final String reasonAr;
  final String reasonEn;

  const QuranAiSearchResult({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahArabicName,
    required this.surahKurdishName,
    this.surahKurmanjiName,
    required this.surahEnglishName,
    required this.ayahArabicText,
    required this.pageNumber,
    required this.juzNumber,
    required this.reasonKu,
    this.reasonKmr,
    required this.reasonAr,
    required this.reasonEn,
  });

  String getReason(String language) {
    if (language == 'kmr' && reasonKmr != null && reasonKmr!.isNotEmpty) return reasonKmr!;
    if ((language == 'ku' || language == 'kmr') && reasonKu.isNotEmpty) return reasonKu;
    if (language == 'ar' && reasonAr.isNotEmpty) return reasonAr;
    if (reasonEn.isNotEmpty) return reasonEn;
    return reasonKu.isNotEmpty ? reasonKu : reasonAr;
  }
}

class QuranAiSearchResponse {
  final String query;
  final String topicSummary;
  final List<QuranAiSearchResult> results;
  final bool isOfflineFallback;

  const QuranAiSearchResponse({
    required this.query,
    required this.topicSummary,
    required this.results,
    this.isOfflineFallback = false,
  });
}

class QuranAiSearchService {
  QuranAiSearchService._();
  static final QuranAiSearchService instance = QuranAiSearchService._();

  // Gemini API key: pass at compile-time via --dart-define=GEMINI_API_KEY=your_key
  // or leave empty to use built-in offline semantic search.
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// In-memory cache for fast instant query results
  final Map<String, QuranAiSearchResponse> _cache = {};

  /// Cached parsed Kurdish Tafsir for lightning-fast keyword search
  Map<int, Map<int, String>>? _kurdishTafsirCache;

  /// Arabic and Kurdish text normalizer (removes Tashkeel, diacritics, unifies Kurdish/Arabic letter forms)
  static String normalizeSearchText(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0610-\u061A\u0640]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ي', 'ی')
        .replaceAll('ە', 'ه')
        .replaceAll('ھ', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ۆ', 'و')
        .replaceAll('ێ', 'ی')
        .replaceAll('ڕ', 'ر')
        .replaceAll('ڵ', 'ل')
        .replaceAll(RegExp(r'[\s\u00A0\u200C\.,،!؟\?]+'), ' ')
        .toLowerCase()
        .trim();
  }

  /// Performs an AI & Semantic Search across the Quran
  Future<QuranAiSearchResponse> search(String query, {String language = 'ku'}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const QuranAiSearchResponse(query: '', topicSummary: '', results: []);
    }

    final cacheKey = '${cleanQuery.toLowerCase()}_$language';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 1. If Gemini API key is configured, query live Gemini LLM
    if (_geminiApiKey.isNotEmpty) {
      try {
        final response = await _callGeminiApi(cleanQuery, _geminiApiKey);
        final enriched = await _enrichResults(cleanQuery, response);
        if (enriched.results.isNotEmpty) {
          _cache[cacheKey] = enriched;
          return enriched;
        }
      } catch (e) {
        debugPrint('Gemini Search Live API error: $e');
      }
    }

    // 2. Comprehensive Thematic & Topic Search (Prophets, Concepts, Stories, Illness & Healing)
    final semanticResult = await _comprehensiveSemanticSearch(cleanQuery, language);
    if (semanticResult.results.isNotEmpty) {
      _cache[cacheKey] = semanticResult;
      return semanticResult;
    }

    // 3. Deep Full-Quran Search (Normalized Arabic Text + Kurdish Tafsir Meanings)
    final deepMatch = await _deepSearchFullQuran(cleanQuery, language);
    _cache[cacheKey] = deepMatch;
    return deepMatch;
  }

  Future<Map<String, dynamic>> _callGeminiApi(String query, String apiKey) async {
    final urlWithKey = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    const systemPrompt = '''
You are a master Islamic scholar and Quran multilingual semantic search engine.
Analyze user natural language search queries in ANY language (Kurdish, Arabic, English, Turkish, Persian, Urdu, French, German, Indonesian, Russian, Spanish, Somali, Bengali, Hausa, Swahili, Latin/Arabizi transliteration, or any regional dialect) and extract the most accurate, verified Ayahs from the Holy Quran (114 Surahs).

CRITICAL INSTRUCTIONS:
- Understand and parse the query regardless of the input language or spelling errors.
- Return ONLY valid JSON (no markdown code blocks, no ```json).
- Validate exact Surah number (1 to 114) and Ayah number.
- Provide concise 1-sentence explanations in reason_ku (Sorani Kurdish), reason_ar (Arabic), and reason_en (English) explaining why each Ayah was matched.
- Return ALL relevant Ayahs matching the user's intent or requested quantity (whether 1 specific Ayah, several Ayahs, or all major verses for the topic, up to 15 Ayahs).

JSON OUTPUT FORMAT:
{
  "topic": "Topic summary title",
  "ayahs": [
    {
      "surah": 33,
      "ayah": 59,
      "reason_ku": "فەرمانی پەروەردگار بە ئافرەتانی باوەڕدار تا جلباب و پۆشاکی شەرعی بەسەر خۆیاندا بدەن.",
      "reason_ar": "أمر نساء النبي والمؤمنات بارتداء الجلباب والحجاب الشرعي.",
      "reason_en": "Commanding believing women to draw their outer garments (Jalābīb) around themselves."
    }
  ]
}
''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': '$systemPrompt\n\nUser Search Query: "$query"'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final http.Response res = await http.post(
      urlWithKey,
      headers: headers,
      body: json.encode(requestBody),
    ).timeout(const Duration(seconds: 20));


    if (res.statusCode != 200) {
      String errMsg = 'Gemini API error ${res.statusCode}';
      try {
        final errData = json.decode(res.body) as Map<String, dynamic>;
        final code = (errData['error'] as Map?)??{};
        final msg = code['message'] as String? ?? '';
        if (res.statusCode == 429) { errMsg = 'Rate limit reached. Try again in a moment.'; }
        else if (res.statusCode == 400) { errMsg = 'Bad request${msg.isNotEmpty ? ": $msg" : ""}'; }
        else if (res.statusCode == 403) { errMsg = 'API key invalid or quota exceeded.'; }
        else if (msg.isNotEmpty) { errMsg = msg; }
      } catch (_) {}
      debugPrint('Gemini HTTP Error ${res.statusCode}: ${res.body}');
      throw Exception(errMsg);
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates in Gemini response');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts != null && parts.isNotEmpty ? parts[0]['text'] as String? : null;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty text from Gemini');
    }

    String cleanJson = text.trim();
    if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
    if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
    if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
    cleanJson = cleanJson.trim();

    return json.decode(cleanJson) as Map<String, dynamic>;
  }

  Future<QuranAiSearchResponse> _enrichResults(
    String query,
    Map<String, dynamic> aiJson,
  ) async {
    final topic = aiJson['topic'] as String? ?? query;
    final ayahsList = aiJson['ayahs'] as List<dynamic>? ?? [];

    final surahs = await QuranService.instance.loadSurahs();
    final surahMap = {for (var s in surahs) s.number: s};
    final List<QuranAiSearchResult> enrichedResults = [];

    for (final item in ayahsList) {
      if (item is! Map<String, dynamic>) continue;
      final surahNum = int.tryParse(item['surah'].toString()) ?? 0;
      final ayahNum = int.tryParse(item['ayah'].toString()) ?? 0;

      if (surahNum < 1 || surahNum > 114 || ayahNum < 1) continue;
      final surahMeta = surahMap[surahNum];
      if (surahMeta == null || ayahNum > surahMeta.numberOfAyahs) continue;

      final ayahObj = await QuranService.instance.getAyah(surahNum, ayahNum);
      if (ayahObj == null) continue;

      enrichedResults.add(
        QuranAiSearchResult(
          surahNumber: surahNum,
          ayahNumber: ayahNum,
          surahArabicName: surahMeta.arabicName,
          surahKurdishName: surahMeta.kurdishName,
          surahKurmanjiName: surahMeta.kurdishName,
          surahEnglishName: surahMeta.englishName,
          ayahArabicText: ayahObj.text,
          pageNumber: ayahObj.page,
          juzNumber: ayahObj.juz,
          reasonKu: item['reason_ku'] as String? ?? '',
          reasonKmr: item['reason_kmr'] as String? ?? item['reason_ku'] as String?,
          reasonAr: item['reason_ar'] as String? ?? '',
          reasonEn: item['reason_en'] as String? ?? '',
        ),
      );
    }

    return QuranAiSearchResponse(
      query: query,
      topicSummary: topic,
      results: enrichedResults,
    );
  }

  /// Extensive curated topic database covering rulings, stories, daily life, ethics
  Future<QuranAiSearchResponse> _comprehensiveSemanticSearch(String query, String language) async {
    final normQ = normalizeSearchText(query);
    final words = normQ.split(' ').where((w) => w.length > 1).toList();

    final List<Map<String, dynamic>> topicDb = [
      // 1. Women Clothing / Hijab / Modesty
      {
        'keys': [
          'women clothes', 'women clothing', 'woman clothes', 'hijab', 'modesty', 'clothing', 'veil', 'garment', 'dress',
          'حیجاب', 'پۆشاکی ئافرەتان', 'پۆشاک', 'جلوبەرگ', 'جل و بەرگ', 'پۆشینی ژنان', 'حیجابی ژنان', 'باڵاپۆشی',
          'لباس المراة', 'الحجاب', 'حجاب', 'جلابيبهن', 'جلباب', 'خمار', 'خمرهن', 'ستر', 'لباس'
        ],
        'topic': 'پۆشاکی ئافرەتانی باوەڕدار و حیجاب / Women\'s Modesty and Hijab',
        'surah': 33,
        'ayah': 59,
        'reason_ku': 'فەرمانی پەروەردگار بە پێغەمبەر ﷺ بۆ هاوسەران و کچەکانی و ئافرەتانی باوەڕدار تا جلباب و پۆشاکی شەرعی بەسەر خۆیاندا بدەن: (يُدْنِينَ عَلَيْهِنَّ مِن جَلَابِيبِهِنَّ).',
        'reason_ar': 'أمر الله تعالى لنساء النبي والمؤمنات بارتداء الجلباب والحجاب الشرعي: ﴿يَا أَيُّهَا النَّبِيُّ قُل لِّأَزْوَاجِكَ وَبَنَاتِكَ وَنِسَاءِ الْمُؤْمِنِينَ يُدْنِينَ عَلَيْهِنَّ مِن جَلَابِيبِهِنَّ﴾.',
        'reason_en': 'Commandment to the Prophet\'s wives, daughters, and believing women to draw their outer garments (Jalābīb) around themselves.',
      },
      // 2. Modesty & Headcovers (Khumur)
      {
        'keys': ['headcover', 'khimar', 'khumur', 'داپۆشینی سەر', 'خیمار', 'پۆشینی سنگ', 'لەچک', 'ولیضربن بخمرهن'],
        'topic': 'حیجاب و داپۆشینی سنگ و سەر لەلایەن ئافرەتانەوە / Lowering Gaze and Covering',
        'surah': 24,
        'ayah': 31,
        'reason_ku': 'فەرمان بە ئافرەتانی باوەڕدار بۆ چاوپاراستن و بەستنی لەچک بەسەر سنگ و سینگیاندا: (وَلْيَضْرِبْنَ بِخُمُرِهِنَّ عَلَىٰ جُيُوبِهِنَّ).',
        'reason_ar': 'أمر المؤمنات بغض البصر وحفظ الفرج وإسدال الخمار: ﴿وَلْيَضْرِبْنَ بِخُمُرِهِنَّ عَلَىٰ جُيُوبِهِنَّ﴾.',
        'reason_en': 'Commanding believing women to guard their modesty and wrap their headcovers (Khumur) over their chests.',
      },
      // 3. Clothing of Righteousness (Libas al-Taqwa)
      {
        'keys': ['libas', 'clothing', 'garments', 'پۆشاکی تەقوا', 'لباس التقوى', 'جلوبەرگی پیاوان و ژنان', 'سەتر'],
        'topic': 'نیعمەتی پۆشاک و داپۆشینی عەورەت / Clothing and Piety',
        'surah': 7,
        'ayah': 26,
        'reason_ku': 'دابەزاندنی پۆشاک بۆ داپۆشینی شەرمگاکان و جوانی، و پۆشاکی تەقوا و لەخواترسان چاکترینە.',
        'reason_ar': 'امتنان الله بإنزال اللباس لستر العورات والتجمل: ﴿يَا بَنِي آدَمَ قَدْ أَنزَلْنَا عَلَيْكُمْ لِبَاسًا يُوَارِي سَوْآتِكُمْ وَرِيشًا وَلِبَاسُ التَّقْوَىٰ ذَٰلِكَ خَيْرٌ﴾.',
        'reason_en': 'Allah bestowing clothing to cover private parts and as adornment, with the garment of righteousness being the best.',
      },
      // 4. Sulaiman Message
      {
        'keys': ['sulaiman', 'message', 'solomon', 'سليمان', 'نامەی سولەیمان', 'بەلقیس', 'bilqis', 'queen of sheba', 'هدهد', 'hudhud', 'نامه', 'سلیمان', 'بلقیس', 'سبا', 'سەبەء'],
        'topic': 'نامەی پێغەمبەر سولەیمان بۆ بەلقیس / Solomon\'s Letter',
        'surah': 27,
        'ayah': 30,
        'reason_ku': 'دەقی نامەی پێغەمبەر سولەیمان بۆ بەلقیس شاژنی سەبەء: (إِنَّهُ مِن سُلَيْمَانَ وَإِنَّهُ بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ).',
        'reason_ar': 'نص رسالة النبي سليمان إلى ملكة سبأ: ﴿إِنَّهُ مِن سُلَيْمَانَ وَإِنَّهُ بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ﴾.',
        'reason_en': 'Prophet Solomon\'s letter to Queen Bilqis: "Indeed, it is from Solomon, and it reads: In the name of Allah..."',
      },
      // 5. Sulaiman & Ant
      {
        'keys': ['ant', 'مێروولە', 'نملة', 'نمل', 'sulaiman ant', 'سولەیمان و مێروولە', 'مێروو', 'مێروولەیەک', 'میرووله'],
        'topic': 'قسەکردنی مێروولەکە لەگەڵ پێغەمبەر سولەیمان / The Ant and Sulaiman',
        'surah': 27,
        'ayah': 18,
        'reason_ku': 'ئاگادارکردنەوەی مێروولەکە بۆ مێروولەکانی تر کاتێک سولەیمان و سوپاکەی هاتن.',
        'reason_ar': 'قول النملة لقومها حين أقبل سليمان وجنوده: ﴿حَتَّىٰ إِذَا أَتَوْا عَلَىٰ وَادِ النَّمْلِ قَالَتْ نَمْلَةٌ يَا أَيُّهَا النَّمْلُ ادْخُلُوا مَسَاكِنَكُمْ﴾.',
        'reason_en': 'The ant warning other ants when Prophet Solomon and his army approached.',
      },
      // 6. Quraysh
      {
        'keys': ['quraish', 'quraysh', 'قریش', 'قوڕەیش', 'ئیلافی قوڕەیش', 'هاوین', 'زستان', 'winter', 'summer', 'قورەیش'],
        'topic': 'سوورەتی قوڕەیش و سەفەری زستان و هاوین / Surah Quraysh',
        'surah': 106,
        'ayah': 1,
        'reason_ku': 'نیعمەتی خودا لەسەر هۆزی قوڕەیش بۆ گەشتی زستانە و هاوینە و دابینکردنی ئاسایش لە ترس و برسییەتی.',
        'reason_ar': 'تذكير قريش بنعمة الله عليهم في رحلتي الشتاء والصيف والأمن من الخوف.',
        'reason_en': 'Allah\'s blessings upon the Quraysh tribe with security, sustenance, and winter/summer trade.',
      },
      // 7. Fear & Peace of Heart
      {
        'keys': ['fear', 'anxiety', 'خوف', 'ترس', 'دڵەڕاوکێ', 'ئارامی دڵ', 'peace', 'tranquility', 'lost', 'طمأنينة', 'دڵتەنگی', 'خەم', 'دلەراوکی', 'ئارام'],
        'topic': 'ئارامبوونەوەی دڵ و نەمانی ترس و دڵەڕاوکێ / Peace of Heart & Relief from Fear',
        'surah': 13,
        'ayah': 28,
        'reason_ku': 'ئارامگرتنی دڵەکان بە یادی خودا و نەمانی ترس و خەم: (أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ).',
        'reason_ar': 'طمأنينة القلوب بذكر الله تعالى ودفع الخوف والحزن: ﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾.',
        'reason_en': 'Hearts find ultimate tranquility and solace through the remembrance of Allah.',
      },
      // 8. Patience (Sabr)
      {
        'keys': ['sabr', 'patience', 'صبر', 'سەبر', 'ئارامگری', 'ئارامگرتن', 'endurance', 'hardship', 'ناخۆشی', 'تەنگانە', 'ئارام بگرن'],
        'topic': 'پاداشتی ئارامگری و سەبر / Patience in Adversity',
        'surah': 2,
        'ayah': 153,
        'reason_ku': 'داوای یارمەتی لە خودا بە سەبر و نوێژ لە کاتی ناخۆشیدا، چونکە خودا لەگەڵ ئارامگرانە.',
        'reason_ar': 'الاستعانة بالصبر والصلاة عند الشدائد وبشارة معية الله للصابرين: ﴿يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ﴾.',
        'reason_en': 'Seeking help through patience and prayer; Allah is always with the patient.',
      },
      // 9. Parents
      {
        'keys': ['parents', 'mother', 'father', 'دایک', 'باوک', 'والدين', 'دایک و باوک', 'birr', 'دایکم', 'باوکم', 'والدین'],
        'topic': 'ڕێز و چاکەکردن لەگەڵ دایک و باوک / Honoring Parents',
        'surah': 17,
        'ayah': 23,
        'reason_ku': 'فەرمانی پەروەردگار بە چاکەکردن لەگەڵ دایک و باوک و نەوتنی تەنانەت ووشەی (ئۆف).',
        'reason_ar': 'الأمر بالإحسان للوالدين والنهي عن عقوقهما: ﴿وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا﴾.',
        'reason_en': 'Commandment to treat parents with utmost kindness and avoid uttering even "uff" to them.',
      },
      // 10. Marriage & Love between Spouses
      {
        'keys': ['marriage', 'spouse', 'wife', 'husband', 'هاوسەرگیری', 'ژن و مێرد', 'خێزان', 'زواج', 'مودة ورحمة', 'خۆشەویستی هاوسەران'],
        'topic': 'ئارامی و خۆشەویستی نێوان هاوسەران / Love and Mercy in Marriage',
        'surah': 30,
        'ayah': 21,
        'reason_ku': 'دروستکردنی هاوسەران لە خودی خۆتان بۆ ئەوەی ئارام بگرن لە لایان، و دانانی خۆشەویستی و بەزەیی لە نێوانتاندا.',
        'reason_ar': 'آيات الله في خلق الأزواج والمودة والرحمة بينهم: ﴿وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً﴾.',
        'reason_en': 'Creating for you spouses from yourselves to find tranquility in them, and placing affection and mercy between you.',
      },
      // 11. Companions of the Cave
      {
        'keys': ['cave', 'kahf', 'أصحاب الكهف', 'ئەسحابی کەهف', 'companions of the cave', 'ئەشکەوت', 'فتية', 'کهف', 'ئەشکەوتەکە'],
        'topic': 'لاوانی ئەسحابی کەهف و پەنابردنیان بۆ ئەشکەوتەکە / Companions of the Cave',
        'surah': 18,
        'ayah': 10,
        'reason_ku': 'پەنابردنی لاوە باوەڕدارەکان بۆ ئەشکەوتەکە و پاڕانەوەیان بۆ بەدەستهێنانی بەزەیی و ڕێنمایی خودا.',
        'reason_ar': 'لجوء فتية أهل الكهف ودعاؤهم: ﴿إِذْ أَوَى الْفِتْيَةُ إِلَى الْكَهْفِ فَقَالُوا رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً﴾.',
        'reason_en': 'The faithful youth seeking refuge in the cave, praying for Allah\'s mercy and guidance.',
      },
      // 12. Prophet Yusuf
      {
        'keys': ['yusuf', 'dream', 'یوسف', 'خەوی یوسف', 'joseph', 'کۆشک', 'براکانی یوسف', 'زولەیخا', 'خەون'],
        'topic': 'خەوەکەی پێغەمبەر یوسف / Prophet Yusuf\'s Dream',
        'surah': 12,
        'ayah': 4,
        'reason_ku': 'یوسف خەوەکەی خۆی بۆ باوکی دەگێڕێتەوە دەربارەی یازدە ئەستێرە و خۆر و مانگ کە کڕنۆشیان بۆ بردووە.',
        'reason_ar': 'رؤيا يوسف عليه السلام للكواكب والشمس والقمر ساجدين له.',
        'reason_en': 'Prophet Joseph recounting his dream of eleven stars, the sun, and the moon prostrating to him.',
      },
      // 13. Bee & Honey
      {
        'keys': ['bee', 'honey', 'هەنگ', 'هەنگوین', 'نحل', 'عسل', 'شفا', 'شەفا', 'دەرمان', 'healing', 'هەنگەکان'],
        'topic': 'هەنگ و دروستکردنی هەنگوین کە شیفایە بۆ مرۆڤ / The Bee and Healing Honey',
        'surah': 16,
        'ayah': 69,
        'reason_ku': 'نیعمەتی دروستکردنی هەنگوین لە سکی هەنگەوە کە شیفای تێدایە بۆ نەخۆشییەکانی مرۆڤ.',
        'reason_ar': 'خروج العسل من بطون النحل وفيه شفاء للناس: ﴿يَخْرُجُ مِن بُطُونِهَا شَرَابٌ مُّخْتَلِفٌ أَلْوَانُهُ فِيهِ شِفَاءٌ لِّلنَّاسِ﴾.',
        'reason_en': 'Honey emerging from the bees as a healing drink for humankind.',
      },
      // 14. Ayah Al-Kursi
      {
        'keys': ['kursi', 'greatest ayah', 'کورسی', 'ئایەتولکورسی', 'کرسی', 'پەروەردگار', 'حی و قەیوم', 'حی قیوم', 'لا اله الا هو'],
        'topic': 'ئایەتولکورسی، گەورەترین ئایەتی قورئان / Ayah Al-Kursi',
        'surah': 2,
        'ayah': 255,
        'reason_ku': 'گەورەترین و پیرۆزترین ئایەتی قورئان دەربارەی تاقانەیی و دەسەڵاتی پەروەردگار.',
        'reason_ar': 'آية الكرسي، أعظم آية في القرآن الكريم تبيّن عظمة الله وحفظه للسماوات والأرض.',
        'reason_en': 'Ayah Al-Kursi: The Verse of the Throne, describing Allah\'s supreme majesty and eternal power.',
      },
      // 15. Usury & Interest (Riba)
      {
        'keys': ['riba', 'interest', 'usury', 'ڕیبا', 'سوو', 'سوود', 'ربا', 'حرام', 'تجارة', 'مامەڵە'],
        'topic': 'حەرامبوونی سوو (ڕیبا) و حەڵاڵبوونی بازرگانی / Prohibition of Riba (Interest)',
        'surah': 2,
        'ayah': 275,
        'reason_ku': 'حەڵاڵکردنی کڕین و فرۆشتن لەلایەن خوداوە و حەرامکردنی سووخۆری و ڕیبا.',
        'reason_ar': 'تحريم الربا وإحلال البيع والتجارة: ﴿وَأَحَلَّ اللَّهُ الْبَيْعَ وَحَرَّمَ الرِّبَا﴾.',
        'reason_en': 'Allah permitting trade and strictly prohibiting interest and usury (Riba).',
      },
      // 16. Illness, Sickness & Cure (نەخۆشی و چارەسەر / شیفا)
      {
        'keys': [
          'illness', 'sickness', 'disease', 'cure', 'healing', 'medicine', 'sick', 'heal', 'cure for illness',
          'نەخۆشی', 'نەخؤشی', 'نەخۆشی و چارەسەر', 'نەخۆش', 'چارەسەر', 'دەرمان', 'شیفا', 'تیمار', 'ئەیوب', 'ئەییووب',
          'مرض', 'شفاء', 'علاج', 'داء', 'دواء', 'المريض', 'يشفين', 'الضر', 'أيوب'
        ],
        'topic': 'شیفای نەخۆشییەکان و چارەسەر / Illness, Healing & Divine Cure',
        'entries': [
          {
            'surah': 26,
            'ayah': 80,
            'reason_ku': 'وتەی پێغەمبەر ئیبراهیم کە کاتێک نەخۆش دەکەوێت خودای گەورە شیفای دەدات: (وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ).',
            'reason_ar': 'قول النبي إبراهيم عليه السلام بأن الشفاء من الله وحده: ﴿وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ﴾.',
            'reason_en': 'Prophet Ibrahim\'s affirmation that Allah alone grants cure when he falls ill.',
          },
          {
            'surah': 21,
            'ayah': 83,
            'reason_ku': 'دوعای مەزنی پێغەمبەر ئەیوب لە کاتی نەخۆشی سەختدا کە لە خودا پاڕایەوە و خودا شیفای بەخشی: (أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ).',
            'reason_ar': 'دعاء نبي الله أيوب عليه السلام عند المرض والضر وكشف الله لما به.',
            'reason_en': 'Prophet Ayub\'s prayer during severe illness and Allah relieving his adversity.',
          },
          {
            'surah': 17,
            'ayah': 82,
            'reason_ku': 'قورئانی پیرۆز شیفایە بۆ نەخۆشییە دەروونی و جەستەییەکان و بەزەییە بۆ باوەڕداران: (وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ).',
            'reason_ar': 'إنزال القرآن شفاءً لأمراض القلوب والأبدان ورحمة للمؤمنين: ﴿وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ﴾.',
            'reason_en': 'The Quran as divine healing and mercy for believers.',
          },
        ],
      },
      // 17. Forgiveness
      {
        'keys': [
          'forgiveness', 'repentance', 'tawba', 'tawbah', 'istighfar',
          'تۆبە', 'تەوبە', 'توبه', 'تەوبه', 'تووبە', 'لێخۆشبوون',
          'توبة', 'تووبه', 'استغفار', 'ئیستیغفار', 'مەغفیرەت',
          'گوناھ', 'تاوان', 'بەزەیی', 'لێخۆشبووی خودا',
          'التوبة', 'الاستغفار', 'المغفرة', 'الرحمة',
        ],
        'topic': 'دەرگای بەزەیی و لێخۆشبوونی خودا بۆ تاوانباران / Divine Forgiveness and Mercy',
        'surah': 39,
        'ayah': 53,
        'reason_ku': 'ئومێدبەخشین بە بەندەکان کە هەرگیز لە بەزەیی خودا بێئومێد نەبن، چونکە لە هەموو تاوانەکان خۆش دەبێت.',
        'reason_ar': 'دعوة المذنبين للتوبة وعدم القنوط من رحمة الله: ﴿قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ﴾.',
        'reason_en': 'Do not despair of Allah\'s mercy; indeed, Allah forgives all sins for those who repent.',
      },
    ];

    // Find best match in topic database
    for (final item in topicDb) {
      final keys = (item['keys'] as List<String>).map(normalizeSearchText).toList();
      final isMatch = keys.any((k) {
        // Short keys (≤4 chars, e.g. 'ربا', 'سوو') must be whole words to avoid
        // false positives — e.g. 'ربا' must NOT match inside 'دەربارەی' (about).
        final bool queryContainsKey;
        if (k.length <= 4) {
          final wordBoundary = RegExp(
            '(^|[\\u0020\\u0009،,\\.!؟])${RegExp.escape(k)}([\\u0020\\u0009،,\\.!؟]|\$)',
          );
          queryContainsKey = wordBoundary.hasMatch(normQ);
        } else {
          queryContainsKey = normQ.contains(k);
        }

        if (queryContainsKey || k.contains(normQ)) { return true; }
        if (words.length >= 2) {
          final allWordsMatch = words.every((w) => k.contains(w));
          if (allWordsMatch) { return true; }
        }
        return false;
      });

      if (isMatch) {
        final surahs = await QuranService.instance.loadSurahs();
        final surahMap = {for (var s in surahs) s.number: s};
        final List<QuranAiSearchResult> matches = [];

        if (item.containsKey('entries')) {
          final entries = item['entries'] as List<Map<String, dynamic>>;
          for (final e in entries) {
            final sNum = e['surah'] as int;
            final aNum = e['ayah'] as int;
            final sMeta = surahMap[sNum];
            final aObj = await QuranService.instance.getAyah(sNum, aNum);
            if (sMeta != null && aObj != null) {
              matches.add(
                QuranAiSearchResult(
                  surahNumber: sNum,
                  ayahNumber: aNum,
                  surahArabicName: sMeta.arabicName,
                  surahKurdishName: sMeta.kurdishName,
                  surahEnglishName: sMeta.englishName,
                  ayahArabicText: aObj.text,
                  pageNumber: aObj.page,
                  juzNumber: aObj.juz,
                  reasonKu: e['reason_ku'] as String,
                  reasonAr: e['reason_ar'] as String,
                  reasonEn: e['reason_en'] as String,
                ),
              );
            }
          }
        } else {
          final surahNum = item['surah'] as int;
          final ayahNum = item['ayah'] as int;
          final surahMeta = surahMap[surahNum];
          final ayahObj = await QuranService.instance.getAyah(surahNum, ayahNum);

          if (surahMeta != null && ayahObj != null) {
            matches.add(
              QuranAiSearchResult(
                surahNumber: surahNum,
                ayahNumber: ayahNum,
                surahArabicName: surahMeta.arabicName,
                surahKurdishName: surahMeta.kurdishName,
                surahEnglishName: surahMeta.englishName,
                ayahArabicText: ayahObj.text,
                pageNumber: ayahObj.page,
                juzNumber: ayahObj.juz,
                reasonKu: item['reason_ku'] as String,
                reasonAr: item['reason_ar'] as String,
                reasonEn: item['reason_en'] as String,
              ),
            );
          }
        }

        if (matches.isNotEmpty) {
          return QuranAiSearchResponse(
            query: query,
            topicSummary: item['topic'] as String,
            isOfflineFallback: true,
            results: matches,
          );
        }
      }
    }

    return const QuranAiSearchResponse(query: '', topicSummary: '', results: []);
  }

  /// Deep Search Engine: Searches all 6,236 Ayahs (normalized Arabic) and Kurdish Tafsir
  Future<QuranAiSearchResponse> _deepSearchFullQuran(String query, String language) async {
    final normQ = normalizeSearchText(query);
    final words = normQ.split(' ').where((w) => w.length > 1).toList();
    if (words.isEmpty && normQ.isEmpty) {
      return const QuranAiSearchResponse(query: '', topicSummary: '', results: []);
    }

    final surahs = await QuranService.instance.loadSurahs();

    // Load Kurdish Tafsir if available
    if (_kurdishTafsirCache == null) {
      try {
        final raw = await rootBundle.loadString('assets/quran/tafsir/tafsir_asan.json');
        _kurdishTafsirCache = parseTafsirIndex(raw);
      } catch (_) {
        _kurdishTafsirCache = {};
      }
    }

    final List<Map<String, dynamic>> scoredAyahs = [];

    for (final s in surahs) {
      final ayahs = await QuranService.instance.loadAyahsForSurah(s.number);
      final sKurdishNorm = normalizeSearchText(s.kurdishName);
      final sArabicNorm = normalizeSearchText(s.arabicName);
      final sEnglishNorm = s.englishName.toLowerCase();

      final surahMatchesQuery = sKurdishNorm.contains(normQ) ||
          sArabicNorm.contains(normQ) ||
          sEnglishNorm.contains(normQ);

      for (final a in ayahs) {
        int score = 0;
        final aTextNorm = normalizeSearchText(a.text);
        final tafsirText = _kurdishTafsirCache?[s.number]?[a.ayah] ?? '';
        final tafsirNorm = normalizeSearchText(tafsirText);

        if (surahMatchesQuery && a.ayah == 1) {
          score += 10;
        }

        if (aTextNorm.contains(normQ)) {
          score += 20;
        } else if (tafsirNorm.contains(normQ)) {
          score += 15;
        }

        for (final w in words) {
          if (aTextNorm.contains(w)) score += 5;
          if (tafsirNorm.contains(w)) score += 3;
        }

        if (score >= 5) {
          scoredAyahs.add({
            'score': score,
            'ayah': a,
            'surah': s,
            'tafsirSnippet': tafsirText.isNotEmpty
                ? (tafsirText.length > 90 ? '${tafsirText.substring(0, 90)}...' : tafsirText)
                : '',
          });
        }
      }
    }

    // Sort by highest score first
    scoredAyahs.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final topResults = scoredAyahs.take(12).map((item) {
      final a = item['ayah'] as QuranAyah;
      final s = item['surah'] as QuranSurahMeta;
      final snippet = item['tafsirSnippet'] as String;

      return QuranAiSearchResult(
        surahNumber: s.number,
        ayahNumber: a.ayah,
        surahArabicName: s.arabicName,
        surahKurdishName: s.kurdishName,
        surahEnglishName: s.englishName,
        ayahArabicText: a.text,
        pageNumber: a.page,
        juzNumber: a.juz,
        reasonKu: snippet.isNotEmpty
            ? 'تەفسیر: $snippet'
            : 'ئەم ئایەتە لە سوورەتی (${s.kurdishName}) پەیوەستە بە گەڕانەکەت.',
        reasonAr: 'آية كريمة من سورة (${s.arabicName}) تطابق كلمات البحث.',
        reasonEn: 'Ayah from Surah (${s.englishName}) matching search keywords.',
      );
    }).toList();

    return QuranAiSearchResponse(
      query: query,
      topicSummary: query,
      isOfflineFallback: true,
      results: topResults,
    );
  }
}
