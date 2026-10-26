import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';

enum ShareCardStyle {
  gradient,
  minimal,
  elegant,
  colorful,
}

class QuoteShareCard extends StatelessWidget {
  final Quote quote;
  final ShareCardStyle style;
  final GlobalKey? repaintKey;
  final AppThemeMode themeMode;

  const QuoteShareCard({
    super.key,
    required this.quote,
    this.style = ShareCardStyle.gradient,
    this.repaintKey,
    this.themeMode = AppThemeMode.ocean,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: _buildCardForStyle(),
    );
  }

  Widget _buildCardForStyle() {
    switch (style) {
      case ShareCardStyle.gradient:
        return _buildGradientCard();
      case ShareCardStyle.minimal:
        return _buildMinimalCard();
      case ShareCardStyle.elegant:
        return _buildElegantCard();
      case ShareCardStyle.colorful:
        return _buildColorfulCard();
    }
  }

  Widget _buildGradientCard() {
    final gradient = AppTheme.getPrimaryGradientForMode(themeMode);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote,
            size: 48,
            color: Colors.white70,
          ),
          const SizedBox(height: 24),
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '— ${quote.author}',
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Wisdomly MOP',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCard() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.6,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            quote.author,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildElegantCard() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '"${quote.text}"',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.6,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            width: 100,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            quote.author.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Poppins',
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulCard() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFECA57),
            Color(0xFF48DBFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✨',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              quote.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                height: 1.5,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFECA57)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                quote.author,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteShareHelper {
  static Future<void> shareQuote(
    BuildContext context,
    Quote quote, {
    ShareCardStyle style = ShareCardStyle.gradient,
    AppThemeMode themeMode = AppThemeMode.ocean,
  }) async {
    final globalKey = GlobalKey();

    // Show preview dialog
    final shouldShare = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Quote',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              QuoteShareCard(
                quote: quote,
                style: style,
                repaintKey: globalKey,
                themeMode: themeMode,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldShare != true) return;

    try {
      // Capture the widget as an image
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        _shareAsText(quote);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        _shareAsText(quote);
        return;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '"${quote.text}" — ${quote.author}',
      );
    } catch (e) {
      // Fallback to text sharing
      _shareAsText(quote);
    }
  }

  static void _shareAsText(Quote quote) {
    Share.share(
      '"${quote.text}"\n\n— ${quote.author}\n\nShared from Wisdomly MOP',
    );
  }

  static Future<void> showStyleSelector(
    BuildContext context,
    Quote quote, {
    AppThemeMode themeMode = AppThemeMode.ocean,
  }) async {
    final style = await showModalBottomSheet<ShareCardStyle>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a Style',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            _buildStyleOption(
              context,
              'Gradient',
              'Modern and vibrant',
              Icons.gradient,
              ShareCardStyle.gradient,
            ),
            _buildStyleOption(
              context,
              'Minimal',
              'Clean and simple',
              Icons.crop_square,
              ShareCardStyle.minimal,
            ),
            _buildStyleOption(
              context,
              'Elegant',
              'Sophisticated and classy',
              Icons.auto_awesome,
              ShareCardStyle.elegant,
            ),
            _buildStyleOption(
              context,
              'Colorful',
              'Bold and energetic',
              Icons.color_lens,
              ShareCardStyle.colorful,
            ),
          ],
        ),
      ),
    );

    if (style != null && context.mounted) {
      await shareQuote(context, quote, style: style, themeMode: themeMode);
    }
  }

  static Widget _buildStyleOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ShareCardStyle style,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryOcean),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).pop(style),
    );
  }
}
