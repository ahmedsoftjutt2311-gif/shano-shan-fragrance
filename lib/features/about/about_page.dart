import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE8D49A);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0B0B0B);
  static const Color line = Color(0xFF252525);

  static const String apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  bool _loading = true;

  String _aboutTitle = '';
  String _aboutStory = '';
  String _aboutPhilosophy = '';
  String _aboutFragrances = '';
  String _aboutQuote = '';

  @override
  void initState() {
    super.initState();
    _loadAboutSettings();
  }

  // ============================================================
  // LOAD ABOUT SETTINGS FROM WORKER
  // ============================================================

  Future<void> _loadAboutSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/settings/site'),
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['success'] == true) {
          final rawSettings = decoded['settings'];

          if (rawSettings is Map) {
            final settings =
                Map<String, dynamic>.from(rawSettings);

            if (!mounted) return;

            setState(() {
              _aboutTitle =
                  _value(settings['about_title']);

              _aboutStory =
                  _value(settings['about_story']);

              _aboutPhilosophy =
                  _value(settings['about_philosophy']);

              _aboutFragrances =
                  _value(settings['about_fragrances']);

              _aboutQuote =
                  _value(settings['about_quote']);

              _loading = false;
            });

            return;
          }
        }
      }
    } catch (_) {
      // Keep the page usable with fallback content.
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  String _value(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  // ============================================================
  // FALLBACK CONTENT
  // ============================================================

  String get heroTitle {
    if (_aboutTitle.isNotEmpty) {
      return _aboutTitle;
    }

    return 'MORE THAN\nA FRAGRANCE.';
  }

  String get heroDescription {
    return _firstParagraph(
      _aboutStory,
      'A fragrance can become part of a moment, a memory, '
          'and the way you express yourself.',
    );
  }

  String get storyTitle {
    return 'CRAFTED FOR\nMEMORABLE MOMENTS.';
  }

  String get storyText {
    if (_aboutStory.isNotEmpty) {
      return _aboutStory;
    }

    return 'SHANO SHAN is built around the idea that fragrance '
        'should feel personal, expressive, and memorable.\n\n'
        'From the scent itself to the experience surrounding it, '
        'every detail is designed to create a sense of elegance '
        'and individuality.';
  }

  String get philosophyText {
    if (_aboutPhilosophy.isNotEmpty) {
      return _aboutPhilosophy;
    }

    return 'A fragrance should feel distinctive and personal.\n\n'
        'Every detail matters, from presentation to experience.\n\n'
        'The best fragrance is the one that stays with you.';
  }

  String get fragranceText {
    if (_aboutFragrances.isNotEmpty) {
      return _aboutFragrances;
    }

    return 'Our fragrances are created to become part of your '
        'personal story, bringing character, elegance, and '
        'memorable moments to everyday life.';
  }

  String get quoteText {
    if (_aboutQuote.isNotEmpty) {
      return _aboutQuote;
    }

    return 'EVERY FRAGRANCE HAS A STORY.';
  }

  String _firstParagraph(
    String text,
    String fallback,
  ) {
    if (text.trim().isEmpty) {
      return fallback;
    }

    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return fallback;
    }

    return paragraphs.first;
  }

  List<String> _paragraphs(String text) {
    return text
        .split(RegExp(r'\n\s*\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (_loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(
            color: gold,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(isMobile),
            _buildStory(isMobile),
            _buildPhilosophy(isMobile),
            _buildFragrances(isMobile),
            _buildFounder(context, isMobile),
            _buildClosing(context, isMobile),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 95 : 145,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF151515),
            background,
          ],
        ),
      ),
      child: Column(
        children: [
          _eyebrow('THE WORLD OF SHANO SHAN'),

          const SizedBox(height: 28),

          Text(
            heroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 42 : 72,
              height: 1.02,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            width: 60,
            height: 1,
            color: gold,
          ),

          const SizedBox(height: 30),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
            ),
            child: Text(
              heroDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: isMobile ? 15 : 18,
                height: 1.9,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STORY
  // ============================================================

  Widget _buildStory(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 25 : 90,
        vertical: isMobile ? 80 : 125,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('OUR STORY'),
                const SizedBox(height: 30),
                _storyContent(isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _eyebrow('OUR STORY'),
                ),
                const SizedBox(width: 90),
                Expanded(
                  flex: 5,
                  child: _storyContent(isMobile),
                ),
              ],
            ),
    );
  }

  Widget _storyContent(bool isMobile) {
    final paragraphs = _paragraphs(storyText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          storyTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 30 : 42,
            height: 1.18,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 38),

        for (int i = 0; i < paragraphs.length; i++) ...[
          _bodyText(paragraphs[i]),
          if (i != paragraphs.length - 1)
            const SizedBox(height: 22),
        ],
      ],
    );
  }

  // ============================================================
  // PHILOSOPHY
  // ============================================================

  Widget _buildPhilosophy(bool isMobile) {
    final items = _philosophyItems();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 25 : 80,
        vertical: isMobile ? 75 : 110,
      ),
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          top: BorderSide(color: line),
          bottom: BorderSide(color: line),
        ),
      ),
      child: Column(
        children: [
          _eyebrow('OUR PHILOSOPHY'),

          const SizedBox(height: 22),

          Text(
            'WHAT WE BELIEVE.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 60),

          if (isMobile)
            Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _philosophyCard(items[i]),
                  if (i != items.length - 1)
                    const SizedBox(height: 45),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  Expanded(
                    child: _philosophyCard(items[i]),
                  ),
                  if (i != items.length - 1)
                    Container(
                      width: 1,
                      height: 170,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 45,
                      ),
                      color: line,
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  List<Map<String, String>> _philosophyItems() {
    final paragraphs = _paragraphs(philosophyText);

    final defaults = [
      {
        'number': '01',
        'title': 'CHARACTER',
        'description':
            'A fragrance should feel distinctive and personal.',
      },
      {
        'number': '02',
        'title': 'CRAFT',
        'description':
            'Every detail matters, from presentation to experience.',
      },
      {
        'number': '03',
        'title': 'MEMORY',
        'description':
            'The best fragrance is the one that stays with you.',
      },
    ];

    if (paragraphs.isEmpty) {
      return defaults;
    }

    final titles = [
      'CHARACTER',
      'CRAFT',
      'MEMORY',
    ];

    return List.generate(
      paragraphs.length > 3 ? 3 : paragraphs.length,
      (index) => {
        'number': '0${index + 1}',
        'title': titles[index],
        'description': paragraphs[index],
      },
    );
  }

  Widget _philosophyCard(
    Map<String, String> item,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['number'] ?? '',
          style: const TextStyle(
            color: gold,
            fontSize: 12,
            letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          item['title'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          item['description'] ?? '',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 14,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FRAGRANCES
  // ============================================================

  Widget _buildFragrances(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 25 : 90,
        vertical: isMobile ? 80 : 115,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('OUR FRAGRANCES'),
                const SizedBox(height: 28),
                _fragranceContent(isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _eyebrow('OUR FRAGRANCES'),
                ),
                const SizedBox(width: 90),
                Expanded(
                  flex: 5,
                  child: _fragranceContent(isMobile),
                ),
              ],
            ),
    );
  }

  Widget _fragranceContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SCENTS WITH\nA STORY.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 31 : 43,
            height: 1.15,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        ..._paragraphs(fragranceText).map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _bodyText(paragraph),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOUNDER
  // ============================================================

  Widget _buildFounder(
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 25 : 90,
        vertical: isMobile ? 85 : 125,
      ),
      child: isMobile
          ? Column(
              children: [
                _founderPlaceholder(isMobile),
                const SizedBox(height: 55),
                _founderContent(context, isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _founderPlaceholder(isMobile),
                ),
                const SizedBox(width: 90),
                Expanded(
                  flex: 5,
                  child: _founderContent(context, isMobile),
                ),
              ],
            ),
    );
  }

  Widget _founderPlaceholder(bool isMobile) {
    return AspectRatio(
      aspectRatio: isMobile ? 0.85 : 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(color: line),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: gold.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 22),
            Text(
              'FOUNDER PORTRAIT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _founderContent(
    BuildContext context,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow('THE MAN BEHIND SHANO SHAN'),

        const SizedBox(height: 28),

        Text(
          'THE PERSON\nBEHIND THE BRAND',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 31 : 43,
            height: 1.15,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        Container(
          width: 48,
          height: 1,
          color: gold,
        ),

        const SizedBox(height: 30),

        _bodyText(
          'Discover the story, vision, and inspiration '
          'behind SHANO SHAN.',
        ),

        const SizedBox(height: 38),

        OutlinedButton(
          onPressed: () {
            context.go('/contact');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: const BorderSide(color: gold),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 18,
            ),
          ),
          child: const Text(
            'CONNECT WITH US',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CLOSING
  // ============================================================

  Widget _buildClosing(
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 25,
        vertical: isMobile ? 95 : 135,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            background,
            Color(0xFF101010),
          ],
        ),
      ),
      child: Column(
        children: [
          _eyebrow('THE SHANO SHAN EXPERIENCE'),

          const SizedBox(height: 30),

          Text(
            quoteText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 32 : 50,
              height: 1.15,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Discover a fragrance that feels like your own.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold.withValues(alpha: 0.9),
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              context.go('/shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 21,
              ),
            ),
            child: const Text(
              'EXPLORE FRAGRANCES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL UI HELPERS
  // ============================================================

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: gold,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 4,
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 15,
        height: 1.9,
        letterSpacing: 0.15,
      ),
    );
  }
}