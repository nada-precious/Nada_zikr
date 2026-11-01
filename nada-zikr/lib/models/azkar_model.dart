import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String label; // Arabic
  final String english;
  final String kurdish;
  final String emoji;

  Mood({
    required this.id,
    required this.label,
    required this.english,
    required this.kurdish,
    required this.emoji,
  });

  IconData get iconData {
    switch (id) {
      case 'grateful':
        return Icons.spa_rounded;
      case 'anxious':
        return Icons.cloud_rounded;
      case 'hopeful':
        return Icons.auto_awesome_rounded;
      case 'tired':
        return Icons.bedtime_rounded;
      case 'joyful':
        return Icons.sentiment_very_satisfied_rounded;
      case 'sad':
        return Icons.water_drop_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  String getDisplay(String lang) {
    if (lang == 'kmr') {
      switch (id) {
        case 'grateful':
          return 'سوپاسدار';
        case 'anxious':
          return 'نەئارام';
        case 'hopeful':
          return 'ب هێڤی';
        case 'tired':
          return 'مەندی';
        case 'joyful':
          return 'دلخۆش';
        case 'sad':
          return 'خەمگین';
        default:
          return kurdish;
      }
    }
    if (lang == 'ku') return kurdish;
    if (lang == 'en') return english;
    return label;
  }
}

class AzkarCategory {
  final String id;
  final String label; // Arabic
  final String english;
  final String kurdish;
  final String icon;
  final int count;
  final String color;

  AzkarCategory({
    required this.id,
    required this.label,
    required this.english,
    required this.kurdish,
    required this.icon,
    required this.count,
    required this.color,
  });

  IconData get iconData {
    switch (id) {
      case 'morning':
        return Icons.wb_sunny_rounded;
      case 'evening':
        return Icons.nights_stay_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'wakeup':
        return Icons.wb_twilight_rounded;
      case 'prayer':
        return Icons.mosque_rounded;
      case 'quran':
        return Icons.menu_book_rounded;
      case 'ayat_kursi':
        return Icons.verified_user_rounded;
      case 'surah_mulk':
        return Icons.stars_rounded;
      case 'surah_kahf':
        return Icons.auto_stories_rounded;
      case 'hadith':
        return Icons.format_quote_rounded;
      case 'general':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  String getTitle(String lang) {
    if (lang == 'kmr') {
      switch (id) {
        case 'morning':
          return 'زکرێن سپێدێ';
        case 'evening':
          return 'زکرێن ئێڤاری';
        case 'sleep':
          return 'زکرێن پێش نڤستنێ';
        case 'wakeup':
          return 'زکرێن ژ خەو ڕابوونێ';
        case 'prayer':
          return 'زکرێن پشتی نڤێژێ';
        case 'quran':
          return 'دوعایێن قورئانا پیرۆز';
        case 'ayat_kursi':
          return 'ئایەتا کورسی';
        case 'surah_mulk':
          return 'سوورەتا مولک';
        case 'surah_kahf':
          return 'سوورەتا کەهف';
        case 'hadith':
          return 'فەرموودەیێن پێغەمبەری ﷺ';
        case 'general':
          return 'دوعایێن گشتی و ڕۆژانە';
        default:
          return kurdish;
      }
    }
    if (lang == 'ku') return kurdish;
    if (lang == 'en') return english;
    return label;
  }
}

class Azkar {
  final int? id;
  final String arabic;
  final String translation; // English translation
  final String kurdishTranslation;
  final int repeat;
  final String source;

  Azkar({
    this.id,
    required this.arabic,
    required this.translation,
    required this.kurdishTranslation,
    required this.repeat,
    required this.source,
  });

  String get displayArabic {
    final sanitized = _stripRepeatSuffix(arabic);
    return sanitized.trim();
  }

  String get repeatLabel => repeat.toString();

  String getTranslation(String lang) {
    if (lang == 'ku' || lang == 'kmr') return kurdishTranslation;
    if (lang == 'ar') return kurdishTranslation;
    return translation.isNotEmpty ? translation : kurdishTranslation;
  }

  /// Returns true when this Azkar is a Quranic Ayah or Surah
  bool get isQuranAyah {
    final sOrig = source;
    final s = sOrig.toLowerCase();
    if (sOrig.contains('البقرة') ||
        sOrig.contains('الإخلاص') ||
        sOrig.contains('الاخلاص') ||
        sOrig.contains('الفلق') ||
        sOrig.contains('الناس') ||
        sOrig.contains('الملك') ||
        sOrig.contains('الملک') ||
        sOrig.contains('الكهف') ||
        sOrig.contains('عمران') ||
        sOrig.contains('سوورەت') ||
        sOrig.contains('سورة') ||
        sOrig.contains('ئایەت') ||
        sOrig.contains('آية') ||
        sOrig.contains('قورئان') ||
        sOrig.contains('القرآن') ||
        s.contains('quran') ||
        s.contains('surah') ||
        s.contains('ayah') ||
        s.contains('baqarah') ||
        s.contains('ikhlas') ||
        s.contains('falaq') ||
        s.contains('nas') ||
        s.contains('mulk') ||
        s.contains('kahf') ||
        s.contains('kursi')) {
      return true;
    }

    final ar = arabic;
    if (ar.contains('۝') || ar.contains('۞') || ar.contains('﴿')) {
      return true;
    }
    if (ar.contains('الْحَيُّ الْقَيُّومُ') ||
        ar.contains('لا اله الا هو الحي القيوم') ||
        ar.contains('لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ')) {
      return true;
    }
    if (ar.contains('قُلْ هُوَ اللَّهُ أَحَدٌ') ||
        ar.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ') ||
        ar.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ')) {
      return true;
    }
    if (ar.contains('آمَنَ الرَّسُولُ') || ar.contains('امَنَ الرَّسُولُ')) {
      return true;
    }
    if (ar.contains('إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ')) {
      return true;
    }
    if (ar.contains('تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ') ||
        ar.contains('تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلۡمُلۡكُ')) {
      return true;
    }

    return false;
  }

  /// Returns a clean header title for Quran verses/surahs
  String? getQuranTitle(String lang) {
    if (!isQuranAyah) return null;
    final ar = arabic;
    final sOrig = source;

    final isKurdish = lang == 'ku' || lang == 'kmr';
    final isEnglish = lang == 'en';

    // 1. Ayat Al-Kursi
    if (ar.contains('الْحَيُّ الْقَيُّومُ') || sOrig.contains('کورسی') || sOrig.contains('الكرسي') || sOrig.contains('kursi')) {
      if (isKurdish) return 'ئایەتی کورسی • [البقرة: 255]';
      if (isEnglish) return 'Ayat Al-Kursi • [Al-Baqarah: 255]';
      return 'آيَةُ الكُرْسِيّ • [البقرة: 255]';
    }

    // 2. Amanar-Rasul (Al-Baqarah 285-286)
    if (ar.contains('آمَنَ الرَّسُولُ') || sOrig.contains('285')) {
      if (isKurdish) return 'کۆتایی سوورەتی بەقەرە • [285-286]';
      if (isEnglish) return 'End of Surah Al-Baqarah • [285-286]';
      return 'خَوَاتِيمُ سُورَةِ البَقَرَة • [285-286]';
    }

    // 3. Surah Al-Ikhlas
    if (ar.contains('قُلْ هُوَ اللَّهُ أَحَدٌ') || sOrig.contains('ئیخڵاس') || sOrig.contains('الإخلاص')) {
      if (isKurdish) return 'سوورەتی ئیخڵاس';
      if (isEnglish) return 'Surah Al-Ikhlas';
      return 'سُورَةُ الإِخْلَاص';
    }

    // 4. Surah Al-Falaq
    if (ar.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ') || sOrig.contains('فەلەق') || sOrig.contains('الفلق')) {
      if (isKurdish) return 'سوورەتی فەلەق';
      if (isEnglish) return 'Surah Al-Falaq';
      return 'سُورَةُ الفَلَق';
    }

    // 5. Surah An-Nas
    if (ar.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ') || sOrig.contains('ناس') || sOrig.contains('الناس')) {
      if (isKurdish) return 'سوورەتی ناس';
      if (isEnglish) return 'Surah An-Nas';
      return 'سُورَةُ النَّاس';
    }

    // 6. Surah Al-Mulk
    if (ar.contains('تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ') || ar.contains('تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلۡمُلۡكُ') || sOrig.contains('الملك') || sOrig.contains('الملک')) {
      if (isKurdish) return 'سوورەتی الملوک';
      if (isEnglish) return 'Surah Al-Mulk';
      return 'سُورَةُ المُلْك';
    }

    // 7. Ali 'Imran 190-200
    if (ar.contains('إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ') || sOrig.contains('عمران')) {
      if (isKurdish) return 'دە ئایەتی کۆتایی ئالی عیمران • [190-200]';
      if (isEnglish) return 'End of Surah Ali \'Imran • [190-200]';
      return 'سُورَةُ آلِ عِمْرَان • [190-200]';
    }

    // 8. If source specifies a Surah name
    if (sOrig.contains('سوورەت') || sOrig.contains('سورة') || sOrig.contains('Surah')) {
      return sOrig;
    }

    if (isKurdish) return 'ئایەتی پیرۆزی قورئان';
    if (isEnglish) return 'Noble Quran Verse';
    return 'آيَةٌ مِنَ القُرْآنِ الكَرِيمِ';
  }

  static String _stripRepeatSuffix(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;

    final suffixPattern = RegExp(
      r'\s*\((?:[\p{L}\p{N}\s]+(?:\s+(?:مَرَّة|مرات|مرة|مرات|times|time|times\s*or|مرة واحدة|ثلاث|أربع|سبع|عشر|مائة|واحدة|مرتين|مرات\s*أو|مرة\s*واحدة|ثلاثة|أربعة|سبعة|عشرة|مائة|مئه|مئة|العدد))?)\)\s*$',
      unicode: true,
    );

    return normalized.replaceFirst(suffixPattern, '').trim();
  }
}

class NameOfAllah {
  final int id;
  final String arabic;
  final String transliteration;
  final String english;
  final String kurdish;

  NameOfAllah({
    required this.id,
    required this.arabic,
    this.transliteration = '',
    required this.english,
    required this.kurdish,
  });

  String getMeaning(String lang) {
    if (lang == 'ku' || lang == 'kmr') return kurdish;
    if (lang == 'ar') return arabic;
    return english;
  }
}

class UserProfile {
  final String name;
  final int dailyGoal;
  final int currentStreak;
  final int bestStreak;
  final int totalSessions;
  final DateTime lastSessionDate;
  final String? profilePicturePath;

  UserProfile({
    required this.name,
    required this.dailyGoal,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSessions,
    required this.lastSessionDate,
    this.profilePicturePath,
  });

  UserProfile copyWith({
    String? name,
    int? dailyGoal,
    int? currentStreak,
    int? bestStreak,
    int? totalSessions,
    DateTime? lastSessionDate,
    String? profilePicturePath,
    bool clearProfilePicture = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      profilePicturePath: clearProfilePicture
          ? null
          : (profilePicturePath ?? this.profilePicturePath),
    );
  }
}

class AppStatistics {
  final int currentStreak;
  final int bestStreak;
  final int totalSessions;
  final List<int> heatmapData;

  AppStatistics({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSessions,
    required this.heatmapData,
  });

  factory AppStatistics.initial() {
    return AppStatistics(
      currentStreak: 0,
      bestStreak: 0,
      totalSessions: 0,
      heatmapData: List.generate(84, (i) {
        final seed = (i * 7 + 13) % 17;
        return seed < 5
            ? 0
            : seed < 9
                ? 1
                : seed < 13
                    ? 2
                    : seed < 16
                        ? 3
                        : 4;
      }),
    );
  }
}
