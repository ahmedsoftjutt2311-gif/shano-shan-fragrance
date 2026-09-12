import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE8D49A);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0B0B0B);
  static const Color line = Color(0xFF252525);

  // ============================================================
  // ADMIN-READY CONTENT
  //
  // Later these values will come from:
  //
  // Admin Panel → Worker API → D1 → AboutPage
  //
  // For now they act as safe editable defaults.
  // ============================================================

  static const String heroEyebrow = 'THE WORLD OF SHANO SHAN';
  static const String heroTitle = 'MORE THAN\nA FRAGRANCE.';
  static const String heroDescription =
      'A fragrance can become part of a moment, a memory, '
      'and the way you express yourself.';

  static const String storyEyebrow = 'OUR STORY';
  static const String storyTitle = 'CRAFTED FOR\nMEMORABLE MOMENTS.';
  static const String storyParagraphOne =
      'SHANO SHAN is built around the idea that fragrance '
      'should feel personal, expressive, and memorable.';
  static const String storyParagraphTwo =
      'From the scent itself to the experience surrounding it, '
      'every detail is designed to create a sense of elegance '
      'and individuality.';

  static const String philosophyEyebrow = 'OUR PHILOSOPHY';
  static const String philosophyTitle = 'WHAT WE BELIEVE.';

  static const List<Map<String, String>> philosophyItems = [
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

  static const String founderEyebrow = 'THE MAN BEHIND SHANO SHAN';

  // Leave these empty until the real founder information is
  // entered through the Admin Panel.
  static const String founderName = '';
  static const String founderTitle = '';
  static const String founderImageUrl = '';
  static const String founderStory = '';
  static const String founderStoryTwo = '';

  static const String closingEyebrow = 'THE SHANO SHAN EXPERIENCE';
  static const String closingTitle = 'EVERY FRAGRANCE\nHAS A STORY.';
  static const String closingDescription =
      'Discover a fragrance that feels like your own.';
  static const String closingButton = 'EXPLORE FRAGRANCES';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(isMobile),
            _buildStory(isMobile),
            _buildPhilosophy(isMobile),
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
          _eyebrow(heroEyebrow),

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
                _eyebrow(storyEyebrow),
                const SizedBox(height: 30),
                _storyContent(isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _eyebrow(storyEyebrow),
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

        _bodyText(storyParagraphOne),

        const SizedBox(height: 22),

        _bodyText(storyParagraphTwo),
      ],
    );
  }

  // ============================================================
  // PHILOSOPHY
  // ============================================================

  Widget _buildPhilosophy(bool isMobile) {
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
          _eyebrow(philosophyEyebrow),

          const SizedBox(height: 22),

          Text(
            philosophyTitle,
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
                for (int i = 0; i < philosophyItems.length; i++) ...[
                  _philosophyCard(
                    philosophyItems[i],
                  ),
                  if (i != philosophyItems.length - 1)
                    const SizedBox(height: 45),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < philosophyItems.length; i++) ...[
                  Expanded(
                    child: _philosophyCard(
                      philosophyItems[i],
                    ),
                  ),
                  if (i != philosophyItems.length - 1)
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

  Widget _philosophyCard(Map<String, String> item) {
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
  // FOUNDER
  // ============================================================

  Widget _buildFounder(
    BuildContext context,
    bool isMobile,
  ) {
    final hasImage = founderImageUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 25 : 90,
        vertical: isMobile ? 85 : 125,
      ),
      child: isMobile
          ? Column(
              children: [
                _founderImage(hasImage, isMobile),
                const SizedBox(height: 55),
                _founderContent(context, isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _founderImage(hasImage, isMobile),
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

  Widget _founderImage(
    bool hasImage,
    bool isMobile,
  ) {
    return AspectRatio(
      aspectRatio: isMobile ? 0.85 : 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(
            color: line,
          ),
        ),
        child: hasImage
            ? Image.network(
                founderImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return _founderPlaceholder();
                },
              )
            : _founderPlaceholder(),
      ),
    );
  }

  Widget _founderPlaceholder() {
    return Column(
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
    );
  }

  Widget _founderContent(
    BuildContext context,
    bool isMobile,
  ) {
    final hasFounderName = founderName.trim().isNotEmpty;
    final hasFounderTitle = founderTitle.trim().isNotEmpty;
    final hasFounderStory = founderStory.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow(founderEyebrow),

        const SizedBox(height: 28),

        Text(
          hasFounderName
              ? founderName
              : 'THE PERSON\nBEHIND THE BRAND',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 31 : 43,
            height: 1.15,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        if (hasFounderTitle) ...[
          const SizedBox(height: 14),
          Text(
            founderTitle,
            style: const TextStyle(
              color: softGold,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ],

        const SizedBox(height: 28),

        Container(
          width: 48,
          height: 1,
          color: gold,
        ),

        const SizedBox(height: 30),

        if (hasFounderStory)
          _bodyText(founderStory)
        else
          Text(
            'A dedicated space for the founder’s story, '
            'vision, and connection to SHANO SHAN.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 15,
              height: 1.9,
            ),
          ),

        if (founderStoryTwo.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          _bodyText(founderStoryTwo),
        ],

        const SizedBox(height: 38),

        OutlinedButton(
          onPressed: () {
            context.go('/contact');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: const BorderSide(
              color: gold,
            ),
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
          _eyebrow(closingEyebrow),

          const SizedBox(height: 30),

          Text(
            closingTitle,
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
            closingDescription,
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
            child: Text(
              closingButton,
              style: const TextStyle(
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
  // SHARED UI
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