import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE8D49A);
  static const Color background = Color(0xFF050505);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, isMobile),
            _buildBrandStory(context, isMobile),
            _buildPhilosophy(context, isMobile),
            _buildFounderSection(context, isMobile),
            _buildClosingSection(context, isMobile),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 70,
        vertical: isMobile ? 80 : 120,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF111111),
            background,
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'ABOUT',
            style: TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 5,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'THE WORLD OF\nSHANO SHAN',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 38 : 64,
              height: 1.05,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            width: 55,
            height: 1,
            color: gold,
          ),

          const SizedBox(height: 28),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Text(
              'A fragrance is more than a scent. '
              'It is an atmosphere, a memory, and a way of expressing who you are.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: isMobile ? 15 : 18,
                height: 1.8,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BRAND STORY
  // ============================================================

  Widget _buildBrandStory(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 70 : 110,
      ),
      child: isMobile
          ? Column(
              children: [
                _storyLabel(),
                const SizedBox(height: 25),
                _storyText(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _storyLabel(),
                ),
                const SizedBox(width: 70),
                Expanded(
                  flex: 5,
                  child: _storyText(),
                ),
              ],
            ),
    );
  }

  Widget _storyLabel() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        'THE BRAND',
        style: TextStyle(
          color: gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _storyText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CRAFTED FOR\nMEMORABLE MOMENTS.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            height: 1.25,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 30),

        Text(
          'SHANO SHAN is built around the idea that fragrance '
          'should feel personal. Every scent should have its own '
          'character and leave a lasting impression.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
            height: 1.9,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Our customer experience, presentation, and fragrances '
          'are designed around simplicity, elegance, and individuality.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
            height: 1.9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PHILOSOPHY
  // ============================================================

  Widget _buildPhilosophy(BuildContext context, bool isMobile) {
    final items = [
      (
        '01',
        'CHARACTER',
        'A fragrance should feel distinctive and personal.'
      ),
      (
        '02',
        'CRAFT',
        'Every detail matters, from presentation to experience.'
      ),
      (
        '03',
        'MEMORY',
        'The best fragrance is the one people remember.'
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 70,
        vertical: isMobile ? 65 : 100,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0B),
        border: Border(
          top: BorderSide(
            color: Color(0xFF202020),
          ),
          bottom: BorderSide(
            color: Color(0xFF202020),
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'OUR PHILOSOPHY',
            style: TextStyle(
              color: gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 55),

          if (isMobile)
            Column(
              children: [
                for (final item in items) ...[
                  _philosophyCard(
                    number: item.$1,
                    title: item.$2,
                    description: item.$3,
                  ),
                  const SizedBox(height: 35),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  Expanded(
                    child: _philosophyCard(
                      number: items[i].$1,
                      title: items[i].$2,
                      description: items[i].$3,
                    ),
                  ),
                  if (i != items.length - 1)
                    Container(
                      width: 1,
                      height: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 35),
                      color: const Color(0xFF252525),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _philosophyCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: gold,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOUNDER
  // ============================================================

  Widget _buildFounderSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 75 : 120,
      ),
      child: isMobile
          ? Column(
              children: [
                _founderPlaceholder(),
                const SizedBox(height: 45),
                _founderContent(context),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _founderPlaceholder(),
                ),
                const SizedBox(width: 80),
                Expanded(
                  flex: 5,
                  child: _founderContent(context),
                ),
              ],
            ),
    );
  }

  Widget _founderPlaceholder() {
    return AspectRatio(
      aspectRatio: 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border.all(
            color: const Color(0xFF292929),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 58,
              color: gold.withValues(alpha: 0.65),
            ),

            const SizedBox(height: 20),

            Text(
              'FOUNDER IMAGE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Managed from Admin',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _founderContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE MAN BEHIND\nSHANO SHAN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: 45,
          height: 1,
          color: gold,
        ),

        const SizedBox(height: 28),

        Text(
          'Founder story and personal details will be managed '
          'through the SHANO SHAN Admin Panel.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 15,
            height: 1.8,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'This section is intentionally prepared for dynamic '
          'brand content so it can be updated without changing '
          'the customer website.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
            height: 1.8,
          ),
        ),

        const SizedBox(height: 35),

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
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CLOSING
  // ============================================================

  Widget _buildClosingSection(
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 80 : 110,
      ),
      child: Column(
        children: [
          Text(
            'EVERY FRAGRANCE\nHAS A STORY.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 30 : 44,
              height: 1.2,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Discover yours.',
            style: TextStyle(
              color: gold.withValues(alpha: 0.9),
              fontSize: 17,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 35),

          ElevatedButton(
            onPressed: () {
              context.go('/shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 20,
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
}