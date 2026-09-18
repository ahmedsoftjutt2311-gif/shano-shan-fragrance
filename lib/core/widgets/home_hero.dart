
import 'dart:async';

import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    this.onShop,
    this.onFindScent,
  });

  final VoidCallback? onShop;
  final VoidCallback? onFindScent;

  static const Color gold = Color(0xFFD6A33A);
  static const Color brightGold = Color(0xFFE9B84A);
  static const Color cream = Color(0xFFF5E8C7);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool mobile = width < 650;
        final bool tablet = width >= 650 && width < 1050;

        final double heroHeight = mobile
            ? 760
            : tablet
                ? 720
                : 780;

        final double horizontalPadding = mobile
            ? 24
            : tablet
                ? 52
                : 72;

        return SizedBox(
          width: double.infinity,
          height: heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // BACKGROUND
              // ============================================================
              Image.asset(
                'assets/branding/shano_shan_hero_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) {
                  return const ColoredBox(
                    color: Color(0xFF020202),
                  );
                },
              ),

              // ============================================================
              // DARK LEFT OVERLAY
              // ============================================================
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: mobile
                            ? const [0.0, 0.70, 1.0]
                            : const [0.0, 0.42, 0.62, 0.82],
                        colors: mobile
                            ? const [
                                Color(0xFF020202),
                                Color(0xE9020202),
                                Color(0x00020202),
                              ]
                            : const [
                                Color(0xFF020202),
                                Color(0xF6020202),
                                Color(0xCC020202),
                                Color(0x00020202),
                              ],
                      ),
                    ),
                  ),
                ),
              ),

              // ============================================================
              // TOP / BOTTOM CINEMATIC VIGNETTE
              // ============================================================
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Color(0x45000000),
                          Color(0x00000000),
                          Color(0x55000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ============================================================
              // HERO CONTENT
              // ============================================================
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    mobile ? 70 : 88,
                    horizontalPadding,
                    40,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: mobile
                            ? width - horizontalPadding * 2
                            : tablet
                                ? 650
                                : 760,
                      ),
                      child: _HeroContent(
                        mobile: mobile,
                        tablet: tablet,
                        onShop: onShop,
                        onFindScent: onFindScent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.mobile,
    required this.tablet,
    this.onShop,
    this.onFindScent,
  });

  final bool mobile;
  final bool tablet;

  final VoidCallback? onShop;
  final VoidCallback? onFindScent;

  @override
  Widget build(BuildContext context) {
    final double titleSize = mobile
        ? 43
        : tablet
            ? 57
            : 70;

    final TextStyle mainTitleStyle = TextStyle(
      color: HomeHero.cream,
      fontFamily: 'Georgia',
      fontSize: titleSize,
      fontWeight: FontWeight.w400,
      height: 0.94,
      letterSpacing: mobile ? -1.5 : -2.4,
    );

    final TextStyle impressionStyle = TextStyle(
      color: HomeHero.brightGold,
      fontFamily: 'Georgia',
      fontSize: titleSize,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      height: 0.96,
      letterSpacing: mobile ? -2 : -3,
      shadows: const [
        Shadow(
          color: Color(0x66D99A2B),
          blurRadius: 22,
          offset: Offset(0, 3),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================================================================
        // BRAND LABEL
        // ================================================================
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: mobile ? 38 : 54,
              height: 1.2,
              color: HomeHero.gold,
            ),
            const SizedBox(width: 15),
            Text(
              'SHANO SHAN FRAGRANCE',
              style: TextStyle(
                color: HomeHero.gold,
                fontSize: mobile ? 10 : 13,
                fontWeight: FontWeight.w600,
                letterSpacing: mobile ? 2.5 : 4.2,
              ),
            ),
          ],
        ),

        SizedBox(height: mobile ? 28 : 34),

        // ================================================================
        // MAIN HEADLINE
        // LETTER-BY-LETTER ANIMATION
        // ================================================================
        _LetterRevealText(
          text: 'A FRAGRANCE',
          style: mainTitleStyle,
          characterDelay: const Duration(milliseconds: 55),
        ),

        _LetterRevealText(
          text: 'THAT LEAVES',
          style: mainTitleStyle,
          characterDelay: const Duration(milliseconds: 55),
          startDelay: const Duration(milliseconds: 650),
        ),

        // ================================================================
        // AN IMPRESSION
        // ================================================================
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _LetterRevealText(
              text: 'AN ',
              style: mainTitleStyle,
              characterDelay: const Duration(milliseconds: 55),
              startDelay: const Duration(milliseconds: 1250),
            ),
            Flexible(
              child: _LetterRevealText(
                text: 'IMPRESSION.',
                style: impressionStyle,
                characterDelay: const Duration(milliseconds: 70),
                startDelay: const Duration(milliseconds: 1400),
              ),
            ),
          ],
        ),

        SizedBox(height: mobile ? 30 : 34),

        // ================================================================
        // GOLD DIVIDER
        // ================================================================
        Container(
          width: mobile ? 42 : 56,
          height: 1.2,
          color: HomeHero.gold,
        ),

        const SizedBox(height: 20),

        // ================================================================
        // TAGLINE
        // ================================================================
        Text(
          'MORE THAN A SCENT — IT’S A SIGNATURE.',
          style: TextStyle(
            color: const Color(0xFFD8BF8B),
            fontSize: mobile ? 9 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: mobile ? 1.8 : 3.4,
          ),
        ),

        SizedBox(height: mobile ? 32 : 38),

        // ================================================================
        // WORKING BUTTONS
        // ================================================================
        Wrap(
          spacing: 20,
          runSpacing: 14,
          children: [
            _HeroButton(
              label: 'SHOP FRAGRANCES',
              filled: true,
              onPressed: onShop,
            ),
            _HeroButton(
              label: 'FIND YOUR SCENT',
              filled: false,
              onPressed: onFindScent,
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================================================
// LETTER-BY-LETTER REVEAL
// ==========================================================================

class _LetterRevealText extends StatefulWidget {
  const _LetterRevealText({
    required this.text,
    required this.style,
    this.characterDelay = const Duration(milliseconds: 60),
    this.startDelay = Duration.zero,
  });

  final String text;
  final TextStyle style;
  final Duration characterDelay;
  final Duration startDelay;

  @override
  State<_LetterRevealText> createState() => _LetterRevealTextState();
}

class _LetterRevealTextState extends State<_LetterRevealText> {
  int visibleCharacters = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer?.cancel();

    visibleCharacters = 0;

    Future.delayed(widget.startDelay, () {
      if (!mounted) return;

      _timer = Timer.periodic(
        widget.characterDelay,
        (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            visibleCharacters++;
          });

          if (visibleCharacters >= widget.text.length) {
            timer.cancel();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = visibleCharacters.clamp(0, widget.text.length);

    final String visibleText = widget.text.substring(0, count);

    return Text(
      visibleText,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: widget.style,
    );
  }
}

// ==========================================================================
// HERO BUTTON
// ==========================================================================

class _HeroButton extends StatefulWidget {
  const _HeroButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          color: widget.filled
              ? hovered
                  ? const Color(0xFFE6B64F)
                  : const Color(0xFFD6A33A)
              : hovered
                  ? const Color(0x22D6A33A)
                  : Colors.transparent,
          border: Border.all(
            color: HomeHero.gold,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            hoverColor: Colors.transparent,
            splashColor: const Color(0x22D6A33A),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.filled
                          ? const Color(0xFF090705)
                          : HomeHero.cream,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.1,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Icon(
                    Icons.arrow_forward,
                    size: 17,
                    color: widget.filled
                        ? const Color(0xFF090705)
                        : HomeHero.gold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}