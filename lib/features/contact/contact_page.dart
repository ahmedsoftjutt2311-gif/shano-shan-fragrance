import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const Color gold = Color(0xFFD4AF37);
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
            _buildHero(isMobile),
            _buildContactOptions(context, isMobile),
            _buildMessageSection(isMobile),
            _buildBottomCta(context, isMobile),
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
        horizontal: 24,
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
            'GET IN TOUCH',
            style: TextStyle(
              color: gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'LET’S TALK.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 42 : 64,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 25),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 620,
            ),
            child: Text(
              'Whether you have a question about a fragrance, '
              'an order, or SHANO SHAN itself, we are here to help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isMobile ? 15 : 17,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT OPTIONS
  // ============================================================

  Widget _buildContactOptions(
    BuildContext context,
    bool isMobile,
  ) {
    final options = [
      _ContactOption(
        icon: Icons.email_outlined,
        title: 'EMAIL',
        description: 'Reach us by email',
        type: 'Gmail',
      ),
      _ContactOption(
        icon: Icons.camera_alt_outlined,
        title: 'INSTAGRAM',
        description: 'Follow the SHANO SHAN journey',
        type: 'Instagram',
      ),
      _ContactOption(
        icon: Icons.music_note_outlined,
        title: 'TIKTOK',
        description: 'Discover our latest content',
        type: 'TikTok',
      ),
      _ContactOption(
        icon: Icons.facebook_outlined,
        title: 'FACEBOOK',
        description: 'Connect with SHANO SHAN',
        type: 'Facebook',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 70,
        vertical: isMobile ? 60 : 90,
      ),
      child: Column(
        children: [
          const Text(
            'CONTACT OPTIONS',
            style: TextStyle(
              color: gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 45),

          if (isMobile)
            Column(
              children: [
                for (final option in options) ...[
                  _contactCard(
                    context,
                    option,
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                return _contactCard(
                  context,
                  options[index],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _contactCard(
    BuildContext context,
    _ContactOption option,
  ) {
    return InkWell(
      onTap: () {
        _showComingSoon(context, option.type);
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border.all(
            color: const Color(0xFF262626),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                border: Border.all(
                  color: gold.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(
                option.icon,
                color: gold,
                size: 25,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    option.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _buildMessageSection(bool isMobile) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 24 : 80,
      vertical: isMobile ? 60 : 90,
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
          'PERSONAL SERVICE',
          style: TextStyle(
            color: gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),

        const SizedBox(height: 25),

        Text(
          'YOUR EXPERIENCE MATTERS.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 27 : 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          child: Text(
            'We are here to help with your fragrance journey, '
            'orders, and any questions you may have.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // BOTTOM CTA
  // ============================================================

  Widget _buildBottomCta(
    BuildContext context,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 70 : 90,
      ),
      child: Column(
        children: [
          const Text(
            'READY TO FIND YOUR SCENT?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 28),

          OutlinedButton(
            onPressed: () {
              context.go('/find-your-scent');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: gold,
              side: const BorderSide(
                color: gold,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 18,
              ),
            ),
            child: const Text(
              'FIND YOUR SCENT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String type,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF151515),
        content: Text(
          '$type contact details will be connected from the Admin Panel.',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CONTACT OPTION MODEL
// ================================================================

class _ContactOption {
  final IconData icon;
  final String title;
  final String description;
  final String type;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
  });
}