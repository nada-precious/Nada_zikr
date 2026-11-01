import 'package:flutter/material.dart';

class ZikrTextItem {
  final String id;
  final String titleEn;
  final String titleKu;
  final String titleKmr;
  final String titleAr;
  final int target;

  const ZikrTextItem({
    required this.id,
    required this.titleEn,
    required this.titleKu,
    String? titleKmr,
    required this.titleAr,
    this.target = 33,
  }) : titleKmr = titleKmr ?? titleKu;

  String title(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return titleAr;
      case 'kmr':
        return titleKmr;
      case 'ku':
        return titleKu;
      default:
        return titleEn;
    }
  }
}

