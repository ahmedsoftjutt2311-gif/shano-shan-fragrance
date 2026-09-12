
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../core/widgets/home_hero.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  List<Map<String, dynamic>> _featuredProducts = [];
  bool _productsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/products'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response');
      }

      final rawProducts = decoded['products'];

      if (rawProducts is! List) {
        throw Exception('Products not found');
      }

      final products = rawProducts
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _featuredProducts = products.take(4).toList();
        _productsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _productsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HomeHero(
            onShop: () => context.go('/shop'),
            onFindScent: () => context.go('/find-your-scent'),
          ),

          const SizedBox(height: 105),

          const _BrandStatement(),

          const SizedBox(height: 115),

          _FeaturedFragrancesSection(
            products: _featuredProducts,
            loading: _productsLoading,
            onViewAll: () => context.go('/shop'),
          ),

          const SizedBox(height: 125),

          _FounderSection(
            onMeetFounder: () => context.go('/about'),
          ),

          const SizedBox(height: 125),

          _ScentExperienceSection(
            onExplore: () => context.go('/shop'),
          ),

          const SizedBox(height: 120),

          const _FinalBrandSection(),

          const SizedBox(height: 1),

          const _StayConnectedSection(),

          const SizedBox(height: 1),
        ],
      ),
    );
  }
}

// ============================================================================
// BRAND STATEMENT
// ============================================================================

class _BrandStatement extends StatelessWidget {
  const _BrandStatement();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 650;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: Column(
          children: [
            const _SectionEyebrow(
              label: 'THE SHANO SHAN PHILOSOPHY',
            ),
            SizedBox(height: mobile ? 22 : 28),
            Text(
              'A fragrance is more than a scent.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 30 : 40,
                fontWeight: FontWeight.w300,
                height: 1.25,
                letterSpacing: -.4,
              ),
            ),
            SizedBox(height: mobile ? 18 : 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'It is an impression. A memory. A quiet statement '
                'that stays long after you have left the room.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .60),
                  fontSize: mobile ? 14 : 17,
                  height: 1.85,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION EYEBROW
// ============================================================================

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 1,
          color: const Color(0xFFD4AF37),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 10,
            letterSpacing: 3.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 34,
          height: 1,
          color: Color(0xFFD4AF37),
        ),
      ],
    );
  }
}

// ============================================================================
// FEATURED FRAGRANCES
// ============================================================================

class _FeaturedFragrancesSection extends StatelessWidget {
  const _FeaturedFragrancesSection({
    required this.products,
    required this.loading,
    required this.onViewAll,
  });

  final List<Map<String, dynamic>> products;
  final bool loading;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 650;
    final tablet = width >= 650 && width < 1050;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1220),
        child: Column(
          children: [
            const _SectionEyebrow(
              label: 'THE COLLECTION',
            ),

            const SizedBox(height: 20),

            Text(
              'SIGNATURE FRAGRANCES',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 28 : 34,
                fontWeight: FontWeight.w300,
                letterSpacing: mobile ? 1 : 2.5,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'Discover the fragrances that define SHANO SHAN.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: mobile ? 13 : 15,
                height: 1.5,
              ),
            ),

            SizedBox(height: mobile ? 35 : 48),

            if (loading)
              const _CollectionLoader()
            else if (products.isEmpty)
              const _EmptyCollection()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: mobile
                      ? 1
                      : tablet
                          ? 2
                          : 4,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 22,
                  childAspectRatio: mobile ? 1.05 : .73,
                ),
                itemBuilder: (context, index) {
                  return _FeaturedProductCard(
                    product: products[index],
                  );
                },
              ),

            SizedBox(height: mobile ? 35 : 45),

            _GoldOutlineButton(
              label: 'VIEW ALL FRAGRANCES',
              onPressed: onViewAll,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COLLECTION LOADER
// ============================================================================

class _CollectionLoader extends StatelessWidget {
  const _CollectionLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CURATING THE COLLECTION',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .38),
                fontSize: 9,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FEATURED PRODUCT CARD
// ============================================================================

class _FeaturedProductCard extends StatefulWidget {
  const _FeaturedProductCard({
    required this.product,
  });

  final Map<String, dynamic> product;

  @override
  State<_FeaturedProductCard> createState() =>
      _FeaturedProductCardState();
}

class _FeaturedProductCardState
    extends State<_FeaturedProductCard> {
  bool _hovering = false;

  static const Color gold = Color(0xFFD4AF37);

  String _stringValue(String key) {
    return widget.product[key]?.toString().trim() ?? '';
  }

  double _price() {
    final raw = widget.product['price'];

    if (raw is num) {
      return raw.toDouble();
    }

    return double.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final name = _stringValue('name');
    final slug = _stringValue('slug');
    final category = _stringValue('category');
    final imageUrl = _stringValue('image_url');

    final currency = _stringValue('currency').isEmpty
        ? 'PKR'
        : _stringValue('currency');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: slug.isEmpty
            ? null
            : () => context.go('/product/$slug'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _hovering ? -5 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            border: Border.all(
              color: _hovering
                  ? gold.withValues(alpha: .55)
                  : Colors.white.withValues(alpha: .09),
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: gold.withValues(alpha: .08),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ProductImage(
                      imageUrl: imageUrl,
                      name: name,
                    ),

                    Positioned(
                      top: 14,
                      left: 14,
                      child: AnimatedOpacity(
                        opacity: _hovering ? 1 : .75,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          color: const Color(0xCC050505),
                          child: const Text(
                            'SHANO SHAN',
                            style: TextStyle(
                              color: gold,
                              fontSize: 7,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 15,
                      bottom: 15,
                      child: AnimatedOpacity(
                        opacity: _hovering ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isNotEmpty)
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: gold,
                          fontSize: 8,
                          letterSpacing: 2.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 9),

                    Text(
                      name.isEmpty ? 'SHANO SHAN' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '$currency ${_formatPrice(_price())}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .55),
                        fontSize: 13,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT IMAGE
// ============================================================================

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.name,
  });

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _fallback();
        },
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF191919),
            Color(0xFF070707),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: .75,
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: .10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SS',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontFamily: 'Georgia',
                    fontSize: 38,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 30,
                  height: 1,
                  color: const Color(0x66D4AF37),
                ),
                const SizedBox(height: 14),
                Text(
                  name.isEmpty ? 'SHANO SHAN' : name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY COLLECTION
// ============================================================================

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 65,
        horizontal: 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'SS',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontFamily: 'Georgia',
              fontSize: 34,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'THE COLLECTION IS GROWING',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Discover the latest fragrances in our collection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .48),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FOUNDER SECTION
// ============================================================================

class _FounderSection extends StatelessWidget {
  const _FounderSection({
    required this.onMeetFounder,
  });

  final VoidCallback onMeetFounder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 750;

            final image = Container(
              height: mobile ? 390 : 545,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0B),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .09),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: .75,
                          colors: [
                            const Color(0xFFD4AF37).withValues(alpha: .11),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SS',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontFamily: 'Georgia',
                            fontSize: 70,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 42,
                          height: 1,
                          color: const Color(0x66D4AF37),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SHANO SHAN',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final content = Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 8 : 58,
                vertical: mobile ? 42 : 20,
              ),
              child: Column(
                crossAxisAlignment: mobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _SectionEyebrow(
                    label: 'THE MAN BEHIND SHANO SHAN',
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Every fragrance has a story.\n'
                    'This is ours.',
                    textAlign: mobile
                        ? TextAlign.center
                        : TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mobile ? 29 : 38,
                      fontWeight: FontWeight.w300,
                      height: 1.28,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'SHANO SHAN was created with a simple belief: '
                    'fragrance should feel personal. Every detail, '
                    'from the bottle to the final note, is designed '
                    'to become part of your story.',
                    textAlign: mobile
                        ? TextAlign.center
                        : TextAlign.left,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .58),
                      fontSize: 14,
                      height: 1.85,
                    ),
                  ),

                  const SizedBox(height: 32),

                  _GoldOutlineButton(
                    label: 'MEET THE FOUNDER',
                    onPressed: onMeetFounder,
                  ),
                ],
              ),
            );

            if (mobile) {
              return Column(
                children: [
                  image,
                  content,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: image),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// SCENT EXPERIENCE
// ============================================================================

class _ScentExperienceSection extends StatelessWidget {
  const _ScentExperienceSection({
    required this.onExplore,
  });

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 650;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 25 : 50,
            vertical: mobile ? 65 : 82,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            border: Border.all(
              color: Colors.white.withValues(alpha: .09),
            ),
          ),
          child: Column(
            children: [
              const _SectionEyebrow(
                label: 'DISCOVER YOUR SIGNATURE',
              ),

              const SizedBox(height: 25),

              Text(
                'Find the fragrance\nthat feels like you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: mobile ? 29 : 39,
                  fontWeight: FontWeight.w300,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Not sure where to begin? Let SHANO SHAN guide you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .56),
                  fontSize: mobile ? 13 : 15,
                ),
              ),

              const SizedBox(height: 32),

              _GoldFilledButton(
                label: 'FIND YOUR SCENT',
                onPressed: () {
                  context.go('/find-your-scent');
                },
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: onExplore,
                child: const Text(
                  'EXPLORE ALL FRAGRANCES',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FINAL BRAND SECTION
// ============================================================================

class _FinalBrandSection extends StatefulWidget {
  const _FinalBrandSection();

  @override
  State<_FinalBrandSection> createState() =>
      _FinalBrandSectionState();
}

class _FinalBrandSectionState
    extends State<_FinalBrandSection> {
  static const String _signature = 'WEAR THE MOMENT.';

  Timer? _timer;
  int _visibleCharacters = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 105),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_visibleCharacters >= _signature.length) {
          timer.cancel();
          return;
        }

        setState(() {
          _visibleCharacters++;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 650;

    final visibleText = _signature.substring(
      0,
      _visibleCharacters,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: mobile ? 80 : 115,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF040404),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 1,
            color: const Color(0xFFD4AF37),
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: mobile ? 43 : 62,
            child: Text(
              visibleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: mobile ? 28 : 45,
                fontWeight: FontWeight.w300,
                letterSpacing: mobile ? 2.5 : 4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Discover a fragrance that becomes part of your story.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .50),
              fontSize: mobile ? 13 : 15,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 32),

          _GoldFilledButton(
            label: 'SHOP SHANO SHAN',
            onPressed: () => context.go('/shop'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STAY CONNECTED
// ============================================================================

class _StayConnectedSection extends StatelessWidget {
  const _StayConnectedSection();

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 700;

    return Container(
      width: double.infinity,
      color: const Color(0xFF030303),
      child: Stack(
        children: [
          Positioned(
            left: mobile ? -20 : -50,
            right: mobile ? -20 : -50,
            bottom: mobile ? 70 : 35,
            child: IgnorePointer(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'SHANO SHAN',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .022),
                    fontSize: mobile ? 90 : 190,
                    fontWeight: FontWeight.w800,
                    letterSpacing: mobile ? 5 : 15,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 24 : 55,
              vertical: mobile ? 72 : 92,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: mobile ? 35 : 55,
                        height: 1,
                        color: gold,
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'SHANO SHAN FRAGRANCE',
                        style: TextStyle(
                          color: gold,
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'STAY\nCONNECTED.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mobile ? 44 : 76,
                      height: .95,
                      fontWeight: FontWeight.w300,
                      letterSpacing: mobile ? 1 : 2,
                    ),
                  ),

                  const SizedBox(height: 28),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                    ),
                    child: Text(
                      'Discover the world of SHANO SHAN. '
                      'Follow our journey, explore new fragrances, '
                      'and stay close to the stories behind every scent.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .56),
                        fontSize: mobile ? 14 : 16,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  if (mobile)
                    const _MobileConnectionLinks()
                  else
                    const _DesktopConnectionLinks(),

                  const SizedBox(height: 65),

                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withValues(alpha: .09),
                  ),

                  const SizedBox(height: 23),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© SHANO SHAN FRAGRANCE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .30),
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (!mobile)
                        Text(
                          'CRAFTED FOR THOSE WHO LEAVE AN IMPRESSION.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .22),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DESKTOP CONNECTION LINKS
// ============================================================================

class _DesktopConnectionLinks extends StatelessWidget {
  const _DesktopConnectionLinks();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: 30,
            runSpacing: 18,
            children: const [
              _ConnectionLink(
                icon: Icons.camera_alt_outlined,
                label: 'INSTAGRAM',
              ),
              _ConnectionLink(
                icon: Icons.music_note_outlined,
                label: 'TIKTOK',
              ),
              _ConnectionLink(
                icon: Icons.facebook,
                label: 'FACEBOOK',
              ),
              _ConnectionLink(
                icon: Icons.mail_outline_rounded,
                label: 'EMAIL',
              ),
            ],
          ),
        ),
        const SizedBox(width: 35),
        _ContactButton(),
      ],
    );
  }
}

// ============================================================================
// MOBILE CONNECTION LINKS
// ============================================================================

class _MobileConnectionLinks extends StatelessWidget {
  const _MobileConnectionLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ConnectionLink(
          icon: Icons.camera_alt_outlined,
          label: 'INSTAGRAM',
        ),
        SizedBox(height: 22),
        _ConnectionLink(
          icon: Icons.music_note_outlined,
          label: 'TIKTOK',
        ),
        SizedBox(height: 22),
        _ConnectionLink(
          icon: Icons.facebook,
          label: 'FACEBOOK',
        ),
        SizedBox(height: 22),
        _ConnectionLink(
          icon: Icons.mail_outline_rounded,
          label: 'EMAIL',
        ),
        SizedBox(height: 42),
        _ContactButton(),
      ],
    );
  }
}

// ============================================================================
// CONNECTION LINK
// ============================================================================

class _ConnectionLink extends StatefulWidget {
  const _ConnectionLink({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  State<_ConnectionLink> createState() =>
      _ConnectionLinkState();
}

class _ConnectionLinkState extends State<_ConnectionLink> {
  bool _hovering = false;

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: () => context.go('/contact'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _hovering
                    ? gold
                    : Colors.white.withValues(alpha: .12),
                width: _hovering ? 1.2 : 1,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: _hovering
                    ? gold
                    : Colors.white.withValues(alpha: .55),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovering
                      ? Colors.white
                      : Colors.white.withValues(alpha: .55),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CONTACT BUTTON
// ============================================================================

class _ContactButton extends StatefulWidget {
  const _ContactButton();

  @override
  State<_ContactButton> createState() =>
      _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _hovering = false;

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: () => context.go('/contact'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: _hovering ? gold : Colors.transparent,
            border: Border.all(
              color: gold,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONTACT US',
                style: TextStyle(
                  color: _hovering ? Colors.black : gold,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: _hovering ? Colors.black : gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GOLD OUTLINE BUTTON
// ============================================================================

class _GoldOutlineButton extends StatefulWidget {
  const _GoldOutlineButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_GoldOutlineButton> createState() =>
      _GoldOutlineButtonState();
}

class _GoldOutlineButtonState
    extends State<_GoldOutlineButton> {
  bool _hovering = false;

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovering = true);
      },
      onExit: (_) {
        setState(() => _hovering = false);
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 29,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: _hovering ? gold : Colors.transparent,
            border: Border.all(
              color: gold,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovering ? Colors.black : gold,
              fontSize: 10,
              letterSpacing: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GOLD FILLED BUTTON
// ============================================================================

class _GoldFilledButton extends StatefulWidget {
  const _GoldFilledButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_GoldFilledButton> createState() =>
      _GoldFilledButtonState();
}

class _GoldFilledButtonState
    extends State<_GoldFilledButton> {
  bool _hovering = false;

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovering = true);
      },
      onExit: (_) {
        setState(() => _hovering = false);
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 34,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFFE5BC55)
                : gold,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
