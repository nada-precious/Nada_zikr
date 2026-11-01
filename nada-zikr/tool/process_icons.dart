// ignore_for_file: avoid_print, prefer_const_declarations
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final fgPath = r'C:\Users\zanay\.gemini\antigravity-ide\brain\993b4dfe-58a1-41a7-b355-c7db039e965c\app_icon_fg_1791933982896.jpg';
  final bgPath = r'C:\Users\zanay\.gemini\antigravity-ide\brain\993b4dfe-58a1-41a7-b355-c7db039e965c\app_icon_bg_1791933958649.jpg';
  final fullPath = r'C:\Users\zanay\.gemini\antigravity-ide\brain\993b4dfe-58a1-41a7-b355-c7db039e965c\app_icon_fullbleed_1791933929943.jpg';

  final fgBytes = File(fgPath).readAsBytesSync();
  final bgBytes = File(bgPath).readAsBytesSync();
  final fullBytes = File(fullPath).readAsBytesSync();

  final fgImg = img.decodeJpg(fgBytes)!;
  final bgImg = img.decodeJpg(bgBytes)!;
  final fullImg = img.decodeJpg(fullBytes)!;

  print('Loaded images successfully: ${fgImg.width}x${fgImg.height}');

  // 1. Generate full-bleed 1024x1024 app_icon.png
  final fullPng = img.encodePng(fullImg);
  File('assets/icon/app_icon.png').writeAsBytesSync(fullPng);
  print('Saved assets/icon/app_icon.png (1024x1024)');

  // 2. Generate 512x512 play_store_512.png for Google Play Console
  final playStoreImg = img.copyResize(fullImg, width: 512, height: 512, interpolation: img.Interpolation.linear);
  File('assets/icon/play_store_512.png').writeAsBytesSync(img.encodePng(playStoreImg));
  print('Saved assets/icon/play_store_512.png (512x512)');

  // 3. Generate background PNG for Android adaptive icon
  final bgPng = img.encodePng(bgImg);
  File('assets/icon/app_icon_background.png').writeAsBytesSync(bgPng);
  print('Saved assets/icon/app_icon_background.png (1024x1024)');

  // 4. Generate foreground PNG with transparency
  // For each pixel in fgImg, if it's black/near-black, make it transparent
  // We can use luminance threshold with soft edge
  final fgWithAlpha = img.Image(width: fgImg.width, height: fgImg.height, numChannels: 4);
  
  for (int y = 0; y < fgImg.height; y++) {
    for (int x = 0; x < fgImg.width; x++) {
      final p = fgImg.getPixel(x, y);
      final r = p.r;
      final g = p.g;
      final b = p.b;
      
      // Calculate max channel / brightness
      final maxVal = [r, g, b].reduce((curr, next) => curr > next ? curr : next);
      
      if (maxVal < 8) {
        // Pure black background -> transparent
        fgWithAlpha.setPixelRgba(x, y, 0, 0, 0, 0);
      } else if (maxVal < 35) {
        // Soft transition edge to prevent jagged borders
        final alpha = ((maxVal - 8) / (35 - 8) * 255).clamp(0, 255).toInt();
        fgWithAlpha.setPixelRgba(x, y, r, g, b, alpha);
      } else {
        // Full opacity foreground element
        fgWithAlpha.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  // Find bounding box of foreground
  int minX = fgImg.width, maxX = 0, minY = fgImg.height, maxY = 0;
  for (int y = 0; y < fgImg.height; y++) {
    for (int x = 0; x < fgImg.width; x++) {
      if (fgWithAlpha.getPixel(x, y).a > 10) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  final cropW = maxX - minX + 1;
  final cropH = maxY - minY + 1;
  final croppedFg = img.copyCrop(fgWithAlpha, x: minX, y: minY, width: cropW, height: cropH);

  // Android adaptive icon inset is 16% per side (foreground is viewed at 68%).
  // To occupy the standard ~60% diameter safe zone without being tiny or cut off:
  // Target scaled size should be ~820px.
  const targetDimension = 820;
  final double scale = targetDimension / (cropW > cropH ? cropW : cropH);
  final newW = (cropW * scale).round();
  final newH = (cropH * scale).round();
  final scaledCropped = img.copyResize(croppedFg, width: newW, height: newH, interpolation: img.Interpolation.linear);

  final centeredFg = img.Image(width: 1024, height: 1024, numChannels: 4);
  final dstX = (1024 - newW) ~/ 2;
  final dstY = (1024 - newH) ~/ 2;
  img.compositeImage(centeredFg, scaledCropped, dstX: dstX, dstY: dstY);

  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(img.encodePng(centeredFg));
  print('Saved assets/icon/app_icon_foreground.png (1024x1024 with scaled & centered alpha)');

  // 5. Generate nada_app_icon_squircle.png for in-app UI (with proper rounded corners, no empty padding)
  final squircleImg = img.Image(width: 1024, height: 1024, numChannels: 4);
  const double radius = 220.0;
  for (int y = 0; y < 1024; y++) {
    for (int x = 0; x < 1024; x++) {
      final p = fullImg.getPixel(x, y);
      // Compute distance to corner rounding
      double alphaMult = 1.0;
      final dx = x < radius ? radius - x : (x > 1024 - radius ? x - (1024 - radius) : 0.0);
      final dy = y < radius ? radius - y : (y > 1024 - radius ? y - (1024 - radius) : 0.0);
      if (dx > 0 && dy > 0) {
        final dist = (dx * dx + dy * dy);
        final rSq = radius * radius;
        if (dist > rSq) {
          alphaMult = 0.0;
        } else if (dist > (radius - 1.5) * (radius - 1.5)) {
          // Anti-aliasing
          final d = (radius - (dx * dx + dy * dy) / radius).clamp(0.0, 1.0);
          alphaMult = d;
        }
      }
      final a = (p.a * alphaMult).toInt();
      squircleImg.setPixelRgba(x, y, p.r, p.g, p.b, a);
    }
  }
  File('assets/icon/nada_app_icon_squircle.png').writeAsBytesSync(img.encodePng(squircleImg));
  print('Saved assets/icon/nada_app_icon_squircle.png (1024x1024 squircle)');

  print('All icons generated successfully!');
}
