
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_assets.dart';

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
          // ========================================================
          // HERO
          // ========================================================

          HomeHero(
            onShop: () => context.go('/shop'),
            onFindScent: () => context.go('/find-your-scent'),
          ),

          const SizedBox(height: 120),

          // ========================================================
          // BRAND STATEMENT
          // ========================================================

          const _BrandStatement(),

          const SizedBox(height: 130),

          // ========================================================
          // FEATURED FRAGRANCES
          // ========================================================

          _FeaturedFragrancesSection(
            products: _featuredProducts,
            loading: _productsLoading,
            onViewAll: () => context.go('/shop'),
          ),

          const SizedBox(height: 150),

          // ========================================================
          // FOUNDER
          // ========================================================

          _FounderSection(
            onMeetFounder: () {
              context.go('/about');
            },
          ),

          const SizedBox(height: 150),

          // ========================================================
          // FIND YOUR SCENT
          // ========================================================

          _ScentExperienceSection(
            onExplore: () {
              context.go('/shop');
            },
          ),

          const SizedBox(height: 130),

          // ========================================================
          // FINAL BRAND CTA
          // ========================================================

          const _FinalBrandSection(),

          const SizedBox(height: 1),

          // ========================================================
          // STAY CONNECTED
          // ========================================================

          const _StayConnectedSection(),

          const SizedBox(height: 1),
        ],
      ),
    );
  }
}

// ==================================================================
// BRAND STATEMENT
// ==================================================================

class _BrandStatement extends StatelessWidget {
  const _BrandStatement();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 950,
        ),
        child: Column(
          children: [
            const Text(
              'THE SHANO SHAN PHILOSOPHY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'A fragrance is more than a scent.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w300,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'It is an impression. A memory. A quiet statement '
              'that stays long after you have left the room.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .62),
                fontSize: 17,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// FEATURED FRAGRANCES
// ==================================================================

class _FeaturedFragrancesSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final bool loading;
  final VoidCallback onViewAll;

  const _FeaturedFragrancesSection({
    required this.products,
    required this.loading,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 650;
    final tablet = width >= 650 && width < 1050;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: _MistVideoBackground(),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0x90000000),
                          const Color(0x18000000),
                          const Color(0x78000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 8 : 0,
                  vertical: 58,
                ),
                child: Column(
                  children: [
                    const Text(
                      'THE COLLECTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 12,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SIGNATURE FRAGRANCES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Discover the fragrances that define SHANO SHAN.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .68),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 50),
                    if (loading)
                      const SizedBox(
                        height: 320,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD4AF37),
                            strokeWidth: 1.5,
                          ),
                        ),
                      )
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
                          mainAxisSpacing: 24,
                          childAspectRatio: mobile ? 0.95 : 0.72,
                        ),
                        itemBuilder: (context, index) {
                          return _FeaturedProductCard(
                            product: products[index],
                          );
                        },
                      ),
                    const SizedBox(height: 45),
                    OutlinedButton(
                      onPressed: onViewAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                        side: const BorderSide(
                          color: Color(0xFFD4AF37),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                      ),
                      child: const Text(
                        'VIEW ALL FRAGRANCES',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
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

// ==================================================================
// ANIMATED PERFUME MIST BACKGROUND
// ==================================================================

class _MistVideoBackground extends StatefulWidget {
  const _MistVideoBackground();

  @override
  State<_MistVideoBackground> createState() => _MistVideoBackgroundState();
}

class _MistVideoBackgroundState extends State<_MistVideoBackground> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(
      AppAssets.productMistBackground,
    );

    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      setState(() {});
      await controller.play();
    } catch (_) {
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xFF050505),
      );
    }

    final videoSize = controller.value.size;

    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.center,
      child: SizedBox(
        width: videoSize.width,
        height: videoSize.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

// ==================================================================
// FEATURED PRODUCT CARD
// ==================================================================

class _FeaturedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _FeaturedProductCard({
    required this.product,
  });

  static const Color gold = Color(0xFFD4AF37);

  String _stringValue(String key) {
    return product[key]?.toString().trim() ?? '';
  }

  double _price() {
    final raw = product['price'];

    if (raw is num) {
      return raw.toDouble();
    }

    return double.tryParse(raw?.toString() ?? '') ?? 0;
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

    return InkWell(
      onTap: slug.isEmpty
          ? null
          : () {
              context.go('/product/$slug');
            },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xE60B0B0B),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ProductImage(
                imageUrl: imageUrl,
                name: name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    name.isEmpty ? 'SHANO SHAN' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$currency ${_formatPrice(_price())}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .65),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }
}

// ==================================================================
// PRODUCT IMAGE
// ==================================================================

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _ProductImage({
    required this.imageUrl,
    required this.name,
  });

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
            Color(0xFF181818),
            Color(0xFF080808),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFFD4AF37),
              size: 38,
            ),
            const SizedBox(height: 18),
            Text(
              name.isEmpty ? 'SHANO SHAN' : name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY COLLECTION
// ==================================================================

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 70,
        horizontal: 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: Color(0xFFD4AF37),
            size: 40,
          ),
          const SizedBox(height: 20),
          const Text(
            'THE COLLECTION IS GROWING',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover our fragrance collection in the shop.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FOUNDER SECTION
// ==================================================================

class _FounderSection extends StatelessWidget {
  final VoidCallback onMeetFounder;

  const _FounderSection({
    required this.onMeetFounder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 750;

            final image = Container(
              height: mobile ? 420 : 560,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.8,
                          colors: [
                            const Color(0xFFD4AF37)
                                .withValues(alpha: .08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white24,
                      size: 82,
                    ),
                  ),
                ],
              ),
            );

            final content = Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 5 : 55,
                vertical: mobile ? 45 : 20,
              ),
              child: Column(
                crossAxisAlignment: mobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'THE MAN BEHIND SHANO SHAN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Every fragrance has a story.\n'
                    'This is ours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'SHANO SHAN was created with a simple belief: '
                    'fragrance should feel personal. Every detail, '
                    'from the bottle to the final note, is designed '
                    'to become part of your story.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .62),
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 35),
                  OutlinedButton(
                    onPressed: onMeetFounder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(
                        color: Color(0xFFD4AF37),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                    ),
                    child: const Text(
                      'MEET THE FOUNDER',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                Expanded(
                  child: image,
                ),
                Expanded(
                  child: content,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==================================================================
// SCENT EXPERIENCE
// ==================================================================

class _ScentExperienceSection extends StatelessWidget {
  final VoidCallback onExplore;

  const _ScentExperienceSection({
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1100,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 85,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white12,
          ),
          color: Colors.white.withValues(alpha: .015),
        ),
        child: Column(
          children: [
            const Text(
              'DISCOVER YOUR SIGNATURE',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Find the fragrance\nthat feels like you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w300,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Not sure where to begin? Let SHANO SHAN guide you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () {
                context.go('/find-your-scent');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 19,
                ),
              ),
              child: const Text(
                'FIND YOUR SCENT',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onExplore,
              child: const Text(
                'EXPLORE ALL FRAGRANCES',
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// FINAL BRAND SECTION — LETTER BY LETTER ANIMATION
// ==================================================================

class _FinalBrandSection extends StatefulWidget {
  const _FinalBrandSection();

  @override
  State<_FinalBrandSection> createState() =>
      _FinalBrandSectionState();
}

class _FinalBrandSectionState extends State<_FinalBrandSection> {
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
      const Duration(milliseconds: 115),
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
        vertical: mobile ? 80 : 120,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF050505),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 1,
            color: const Color(0xFFD4AF37),
          ),

          const SizedBox(height: 35),

          // --------------------------------------------------------
          // TYPEWRITER SIGNATURE
          // --------------------------------------------------------

          SizedBox(
            height: mobile ? 45 : 65,
            child: Text(
              visibleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 30 : 46,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Discover a fragrance that becomes part of your story.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .52),
              fontSize: 15,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 35),

          ElevatedButton(
            onPressed: () {
              context.go('/shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 38,
                vertical: 20,
              ),
            ),
            child: const Text(
              'SHOP SHANO SHAN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// STAY CONNECTED
// ==================================================================

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
          // --------------------------------------------------------
          // OVERSIZED BACKGROUND BRAND NAME
          // --------------------------------------------------------

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
                    color: Colors.white.withValues(alpha: .025),
                    fontSize: mobile ? 90 : 190,
                    fontWeight: FontWeight.w800,
                    letterSpacing: mobile ? 5 : 15,
                  ),
                ),
              ),
            ),
          ),

          // --------------------------------------------------------
          // MAIN CONTENT
          // --------------------------------------------------------

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 24 : 55,
              vertical: mobile ? 75 : 95,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // TOP LINE
                  // ------------------------------------------------

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

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    'STAY\nCONNECTED.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mobile ? 46 : 78,
                      height: .95,
                      fontWeight: FontWeight.w300,
                      letterSpacing: mobile ? 1 : 2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                    ),
                    child: Text(
                      'Discover the world of SHANO SHAN. '
                      'Follow our journey, explore new fragrances, '
                      'and stay close to the stories behind every scent.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .58),
                        fontSize: mobile ? 14 : 16,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),

                  // ------------------------------------------------
                  // LINKS + CONTACT
                  // ------------------------------------------------

                  if (mobile)
                    const _MobileConnectionLinks()
                  else
                    const _DesktopConnectionLinks(),

                  const SizedBox(height: 70),

                  // ------------------------------------------------
                  // BOTTOM LINE
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withValues(alpha: .10),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Text(
                        '© SHANO SHAN FRAGRANCE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .32),
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (!mobile)
                        Text(
                          'CRAFTED FOR THOSE WHO LEAVE AN IMPRESSION.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .25),
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

// ==================================================================
// DESKTOP CONNECTION LINKS
// ==================================================================

class _DesktopConnectionLinks extends StatelessWidget {
  const _DesktopConnectionLinks();

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            children: [
              _ConnectionLink(
                icon: Icons.camera_alt_outlined,
                label: 'INSTAGRAM',
                onTap: () {
                  _showComingSoon(context, 'Instagram');
                },
              ),
              const SizedBox(width: 35),
              _ConnectionLink(
                icon: Icons.music_note_outlined,
                label: 'TIKTOK',
                onTap: () {
                  _showComingSoon(context, 'TikTok');
                },
              ),
              const SizedBox(width: 35),
              _ConnectionLink(
                icon: Icons.facebook,
                label: 'FACEBOOK',
                onTap: () {
                  _showComingSoon(context, 'Facebook');
                },
              ),
              const SizedBox(width: 35),
              _ConnectionLink(
                icon: Icons.mail_outline_rounded,
                label: 'EMAIL',
                onTap: () {
                  _showComingSoon(context, 'Email');
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        _ContactButton(
          onTap: () {
            context.go('/contact');
          },
        ),
      ],
    );
  }
}

// ==================================================================
// MOBILE CONNECTION LINKS
// ==================================================================

class _MobileConnectionLinks extends StatelessWidget {
  const _MobileConnectionLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ConnectionLink(
          icon: Icons.camera_alt_outlined,
          label: 'INSTAGRAM',
          onTap: () {
            _showComingSoon(context, 'Instagram');
          },
        ),
        const SizedBox(height: 25),
        _ConnectionLink(
          icon: Icons.music_note_outlined,
          label: 'TIKTOK',
          onTap: () {
            _showComingSoon(context, 'TikTok');
          },
        ),
        const SizedBox(height: 25),
        _ConnectionLink(
          icon: Icons.facebook,
          label: 'FACEBOOK',
          onTap: () {
            _showComingSoon(context, 'Facebook');
          },
        ),
        const SizedBox(height: 25),
        _ConnectionLink(
          icon: Icons.mail_outline_rounded,
          label: 'EMAIL',
          onTap: () {
            _showComingSoon(context, 'Email');
          },
        ),
        const SizedBox(height: 45),
        Align(
          alignment: Alignment.centerLeft,
          child: _ContactButton(
            onTap: () {
              context.go('/contact');
            },
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// CONNECTION LINK
// ==================================================================

class _ConnectionLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ConnectionLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ConnectionLink> createState() => _ConnectionLinkState();
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.only(
            bottom: 9,
          ),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                transform: Matrix4.translationValues(
                  _hovering ? 0 : -2,
                  0,
                  0,
                ),
                child: Icon(
                  widget.icon,
                  size: 17,
                  color: _hovering
                      ? gold
                      : Colors.white.withValues(alpha: .58),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovering
                      ? Colors.white
                      : Colors.white.withValues(alpha: .58),
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

// ==================================================================
// CONTACT BUTTON
// ==================================================================

class _ContactButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ContactButton({
    required this.onTap,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: _hovering
                ? gold
                : Colors.transparent,
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
                  color: _hovering
                      ? Colors.black
                      : gold,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 15),
              AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.only(
                  left: _hovering ? 4 : 0,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _hovering
                      ? Colors.black
                      : gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// TEMPORARY SOCIAL LINK MESSAGE
// ==================================================================

void _showComingSoon(
  BuildContext context,
  String platform,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF111111),
      behavior: SnackBarBehavior.floating,
      content: Text(
        '$platform link will be available soon.',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}
