
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class FragranceFinderPage extends StatefulWidget {
  const FragranceFinderPage({super.key});

  @override
  State<FragranceFinderPage> createState() => _FragranceFinderPageState();
}

class _FragranceFinderPageState extends State<FragranceFinderPage>
    with TickerProviderStateMixin {
  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  static const Color gold = Color(0xFFD6A33A);
  static const Color brightGold = Color(0xFFE9B84A);
  static const Color cream = Color(0xFFF5E8C7);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0C0C0C);

  int _step = 0;

  String? _occasion;
  String? _mood;
  String? _style;

  bool _showResult = false;
  bool _loadingProducts = false;

  String? _errorMessage;

  List<Map<String, dynamic>> _products = [];

  Map<String, dynamic>? _recommendedProduct;

  late final AnimationController _questionController;
  late final AnimationController _resultController;

  final List<String> _occasions = [
    'Everyday',
    'Date Night',
    'Formal',
    'Special Occasion',
  ];

  final List<String> _moods = [
    'Fresh & Energetic',
    'Elegant & Refined',
    'Bold & Powerful',
    'Warm & Mysterious',
  ];

  final List<String> _styles = [
    'Fresh',
    'Woody',
    'Sweet',
    'Deep & Rich',
  ];

  @override
  void initState() {
    super.initState();

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _questionController.forward();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECTION
  // ============================================================

  void _select(String value) {
    setState(() {
      if (_step == 0) {
        _occasion = value;
      } else if (_step == 1) {
        _mood = value;
      } else {
        _style = value;
      }
    });
  }

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> _next() async {
    if (_currentSelection == null) {
      return;
    }

    if (_step < 2) {
      await _questionController.reverse();

      if (!mounted) {
        return;
      }

      setState(() {
        _step++;
        _errorMessage = null;
      });

      await _questionController.forward();
      return;
    }

    await _findMyScent();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _findMyScent() async {
    setState(() {
      _loadingProducts = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('$_apiBaseUrl/api/products'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Unable to load fragrances right now.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from fragrance service.',
        );
      }

      final rawProducts = decoded['products'];

      if (rawProducts is! List) {
        throw Exception(
          'No fragrance catalog was returned.',
        );
      }

      final products = rawProducts
          .whereType<Map>()
          .map(
            (product) => Map<String, dynamic>.from(product),
          )
          .where(_isActiveProduct)
          .toList();

      if (products.isEmpty) {
        throw Exception(
          'There are no fragrances available right now.',
        );
      }

      final recommendation = _selectBestProduct(products);

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _recommendedProduct = recommendation;
        _showResult = true;
        _loadingProducts = false;
      });

      _resultController.forward(from: 0);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingProducts = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  // ============================================================
  // PRODUCT FILTER
  // ============================================================

  bool _isActiveProduct(Map<String, dynamic> product) {
    final value = product['is_active'] ?? product['isActive'];

    if (value == null) {
      return true;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value.toString().trim().toLowerCase();

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes';
  }

  // ============================================================
  // RECOMMENDATION ENGINE
  // ============================================================

  Map<String, dynamic> _selectBestProduct(
    List<Map<String, dynamic>> products,
  ) {
    Map<String, dynamic>? bestProduct;
    int bestScore = -1;

    for (final product in products) {
      final score = _scoreProduct(product);

      if (score > bestScore) {
        bestScore = score;
        bestProduct = product;
      }
    }

    return bestProduct ?? products.first;
  }

  int _scoreProduct(Map<String, dynamic> product) {
    final searchableText = [
      product['name'],
      product['slug'],
      product['category'],
      product['description'],
    ]
        .where((value) => value != null)
        .map((value) => value.toString().toLowerCase())
        .join(' ');

    int score = 0;

    switch (_style) {
      case 'Fresh':
        if (_containsAny(
          searchableText,
          [
            'fresh',
            'citrus',
            'bergamot',
            'lemon',
            'orange',
            'marine',
            'aquatic',
            'clean',
            'green',
          ],
        )) {
          score += 8;
        }
        break;

      case 'Woody':
        if (_containsAny(
          searchableText,
          [
            'woody',
            'wood',
            'cedar',
            'sandalwood',
            'vetiver',
            'oud',
            'leather',
          ],
        )) {
          score += 8;
        }
        break;

      case 'Sweet':
        if (_containsAny(
          searchableText,
          [
            'sweet',
            'vanilla',
            'caramel',
            'honey',
            'tonka',
            'amber',
            'fruity',
            'fruit',
          ],
        )) {
          score += 8;
        }
        break;

      case 'Deep & Rich':
        if (_containsAny(
          searchableText,
          [
            'deep',
            'rich',
            'dark',
            'oud',
            'leather',
            'amber',
            'musk',
            'spicy',
            'mysterious',
          ],
        )) {
          score += 8;
        }
        break;
    }

    switch (_mood) {
      case 'Fresh & Energetic':
        if (_containsAny(
          searchableText,
          [
            'fresh',
            'energetic',
            'citrus',
            'aquatic',
            'clean',
            'bright',
          ],
        )) {
          score += 5;
        }
        break;

      case 'Elegant & Refined':
        if (_containsAny(
          searchableText,
          [
            'elegant',
            'refined',
            'luxury',
            'classic',
            'sophisticated',
            'premium',
          ],
        )) {
          score += 5;
        }
        break;

      case 'Bold & Powerful':
        if (_containsAny(
          searchableText,
          [
            'bold',
            'powerful',
            'strong',
            'intense',
            'statement',
            'oud',
            'spicy',
          ],
        )) {
          score += 5;
        }
        break;

      case 'Warm & Mysterious':
        if (_containsAny(
          searchableText,
          [
            'warm',
            'mysterious',
            'amber',
            'musk',
            'vanilla',
            'oud',
            'dark',
            'rich',
          ],
        )) {
          score += 5;
        }
        break;
    }

    switch (_occasion) {
      case 'Everyday':
        if (_containsAny(
          searchableText,
          [
            'everyday',
            'daily',
            'fresh',
            'clean',
            'light',
            'versatile',
          ],
        )) {
          score += 3;
        }
        break;

      case 'Date Night':
        if (_containsAny(
          searchableText,
          [
            'date',
            'night',
            'seductive',
            'romantic',
            'warm',
            'mysterious',
            'sweet',
            'amber',
          ],
        )) {
          score += 3;
        }
        break;

      case 'Formal':
        if (_containsAny(
          searchableText,
          [
            'formal',
            'elegant',
            'refined',
            'sophisticated',
            'luxury',
            'classic',
          ],
        )) {
          score += 3;
        }
        break;

      case 'Special Occasion':
        if (_containsAny(
          searchableText,
          [
            'special',
            'occasion',
            'luxury',
            'signature',
            'exclusive',
            'premium',
            'bold',
          ],
        )) {
          score += 3;
        }
        break;
    }

    if (_isFeaturedProduct(product)) {
      score += 1;
    }

    return score;
  }

  bool _containsAny(
    String text,
    List<String> words,
  ) {
    for (final word in words) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  bool _isFeaturedProduct(Map<String, dynamic> product) {
    final value = product['is_featured'] ?? product['isFeatured'];

    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value.toString().trim().toLowerCase();

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes';
  }

  // ============================================================
  // BACK
  // ============================================================

  Future<void> _back() async {
    if (_loadingProducts) {
      return;
    }

    if (_showResult) {
      await _resultController.reverse();

      if (!mounted) {
        return;
      }

      setState(() {
        _showResult = false;
        _errorMessage = null;
      });

      await _questionController.forward();
      return;
    }

    if (_step > 0) {
      await _questionController.reverse();

      if (!mounted) {
        return;
      }

      setState(() {
        _step--;
        _errorMessage = null;
      });

      await _questionController.forward();
    }
  }

  // ============================================================
  // RESTART
  // ============================================================

  void _restart() {
    setState(() {
      _step = 0;
      _occasion = null;
      _mood = null;
      _style = null;
      _showResult = false;
      _loadingProducts = false;
      _errorMessage = null;
      _recommendedProduct = null;
      _products = [];
    });

    _questionController.forward(from: 0);
  }

  // ============================================================
  // QUESTION DATA
  // ============================================================

  String get _questionEyebrow {
    switch (_step) {
      case 0:
        return 'STEP ONE';

      case 1:
        return 'STEP TWO';

      default:
        return 'STEP THREE';
    }
  }

  String get _questionTitle {
    switch (_step) {
      case 0:
        return 'WHEN WILL YOU WEAR IT?';

      case 1:
        return 'WHAT SHOULD IT FEEL LIKE?';

      default:
        return 'WHAT STYLE SPEAKS TO YOU?';
    }
  }

  String get _questionDescription {
    switch (_step) {
      case 0:
        return 'Tell us where your fragrance belongs.';

      case 1:
        return 'Choose the feeling you want to leave behind.';

      default:
        return 'Choose the fragrance character that feels most like you.';
    }
  }

  List<String> get _currentOptions {
    switch (_step) {
      case 0:
        return _occasions;

      case 1:
        return _moods;

      default:
        return _styles;
    }
  }

  String? get _currentSelection {
    switch (_step) {
      case 0:
        return _occasion;

      case 1:
        return _mood;

      default:
        return _style;
    }
  }

  // ============================================================
  // RECOMMENDATION REASON
  // ============================================================

  String get _recommendationReason {
    switch (_style) {
      case 'Fresh':
        return 'A refined direction for a clean, confident presence.';

      case 'Woody':
        return 'A sophisticated direction with a confident character.';

      case 'Sweet':
        return 'A memorable direction with warmth and personality.';

      case 'Deep & Rich':
        return 'A rich and distinctive direction for a statement presence.';

      default:
        return 'A fragrance direction selected around your personal choices.';
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return 'We could not load your fragrance recommendation. '
        'Please try again.';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const _BackgroundGlow(),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.025),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _showResult
                  ? _buildResult()
                  : _buildQuiz(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================

  Widget _buildQuiz() {
    return SingleChildScrollView(
      key: const ValueKey('quiz'),
      padding: const EdgeInsets.fromLTRB(
        22,
        45,
        22,
        70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            children: [
              _buildTopBrand(),

              const SizedBox(height: 42),

              const Text(
                'FIND YOUR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cream,
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  letterSpacing: 6,
                  height: 1,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'SIGNATURE SCENT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: brightGold,
                  fontFamily: 'Georgia',
                  fontSize: 42,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1,
                  height: 1.05,
                ),
              ),

              const SizedBox(height: 20),

              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 570,
                ),
                child: Text(
                  'A few thoughtful choices. One fragrance direction '
                  'that feels distinctly yours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.58),
                    fontSize: 15,
                    height: 1.7,
                    letterSpacing: .2,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              _buildProgress(),

              const SizedBox(height: 55),

              AnimatedBuilder(
                animation: _questionController,
                builder: (context, child) {
                  final curved = CurvedAnimation(
                    parent: _questionController,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .035),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      _questionEyebrow,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Text(
                      _questionTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Georgia',
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _questionDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.45),
                        fontSize: 13,
                        letterSpacing: .3,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ...List.generate(
                      _currentOptions.length,
                      (index) {
                        return _buildOption(
                          _currentOptions[index],
                          index,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 22),
              ],

              _buildNavigation(),

              const SizedBox(height: 30),

              TextButton(
                onPressed: _loadingProducts
                    ? null
                    : () => context.pop(),
                child: const Text(
                  'RETURN TO SHANO SHAN',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BRAND HEADER
  // ============================================================

  Widget _buildTopBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 1,
          color: gold,
        ),
        const SizedBox(width: 14),
        const Text(
          'SHANO SHAN FRAGRANCE',
          style: TextStyle(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.4,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 38,
          height: 1,
          color: gold,
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) {
              final active = index <= _step;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 72,
                height: 2,
                decoration: BoxDecoration(
                  color: active ? gold : Colors.white12,
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x33D6A33A),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_step + 1} / 3',
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 9,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OPTION
  // ============================================================

  Widget _buildOption(
    String option,
    int index,
  ) {
    final selected = _currentSelection == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FinderOption(
        option: option,
        selected: selected,
        index: index,
        enabled: !_loadingProducts,
        onTap: () => _select(option),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_step > 0) ...[
          SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: _loadingProducts ? null : _back,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(
                  color: Colors.white12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
              ),
              child: const Text(
                'BACK',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _currentSelection == null ||
                    _loadingProducts
                ? null
                : _next,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: gold,
              foregroundColor: Colors.black,
              disabledBackgroundColor: const Color(0xFF181818),
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              shape: const RoundedRectangleBorder(),
            ),
            child: _loadingProducts
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _step == 2
                            ? 'DISCOVER MY SCENT'
                            : 'CONTINUE',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESULT
  // ============================================================

  Widget _buildResult() {
    final product = _recommendedProduct;

    if (product == null) {
      return _buildEmptyResult();
    }

    final name = _stringValue(
      product['name'],
      fallback: 'SHANO SHAN',
    );

    final slug = _stringValue(
      product['slug'],
      fallback: '',
    );

    final description = _stringValue(
      product['description'],
      fallback:
          'A signature SHANO SHAN fragrance crafted '
          'for memorable moments.',
    );

    final category = _stringValue(
      product['category'],
      fallback: 'FRAGRANCE',
    );

    final imageUrl = _stringValue(
      product['image_url'] ?? product['imageUrl'],
      fallback: '',
    );

    final price = _formatPrice(
      product['price'],
      product['currency'],
    );

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.fromLTRB(
        22,
        50,
        22,
        80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1080,
          ),
          child: AnimatedBuilder(
            animation: _resultController,
            builder: (context, child) {
              final animation = CurvedAnimation(
                parent: _resultController,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .035),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                _buildTopBrand(),

                const SizedBox(height: 48),

                const Text(
                  'YOUR FRAGRANCE',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'WE FOUND YOUR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cream,
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    letterSpacing: 3,
                  ),
                ),

                const Text(
                  'Signature',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: brightGold,
                    fontFamily: 'Georgia',
                    fontSize: 48,
                    fontStyle: FontStyle.italic,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: 70,
                  height: 1,
                  color: gold,
                ),

                const SizedBox(height: 45),

                Container(
                  decoration: BoxDecoration(
                    color: panel,
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact =
                          constraints.maxWidth < 720;

                      if (compact) {
                        return Column(
                          children: [
                            _buildProductImage(
                              imageUrl,
                              name: name,
                              height: 380,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(28),
                              child: _buildRecommendationInfo(
                                name: name,
                                category: category,
                                price: price,
                                description: description,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildProductImage(
                              imageUrl,
                              name: name,
                              height: 520,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(52),
                              child: Center(
                                child:
                                    _buildRecommendationInfo(
                                  name: name,
                                  category: category,
                                  price: price,
                                  description: description,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  _recommendationReason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 18),

                _buildChoiceSummary(),

                const SizedBox(height: 38),

                if (slug.isNotEmpty)
                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/product/${Uri.encodeComponent(slug)}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 34,
                        ),
                        shape:
                            const RoundedRectangleBorder(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DISCOVER ${name.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.arrow_forward,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _restart,
                  child: const Text(
                    'START THE DISCOVERY AGAIN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                if (_products.length > 1) ...[
                  const SizedBox(height: 20),
                  Text(
                    '${_products.length} fragrances in the SHANO SHAN collection.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                      letterSpacing: .5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHOICE SUMMARY
  // ============================================================

  Widget _buildChoiceSummary() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _summaryChip(_occasion ?? ''),
        _summaryChip(_mood ?? ''),
        _summaryChip(_style ?? ''),
      ],
    );
  }

  Widget _summaryChip(String text) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 8,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(
    String imageUrl, {
    required String name,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF090909),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 1,
              height: 55,
              color: gold.withOpacity(.65),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              width: 55,
              height: 1,
              color: gold.withOpacity(.65),
            ),
          ),
          if (imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(25),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildImageFallback(name);
                },
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          gold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            _buildImageFallback(name),
        ],
      ),
    );
  }

  Widget _buildImageFallback(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            border: Border.all(
              color: gold.withOpacity(.65),
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'SS',
              style: TextStyle(
                color: gold,
                fontFamily: 'Georgia',
                fontSize: 25,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'SHANO SHAN',
          style: TextStyle(
            color: gold,
            fontFamily: 'Georgia',
            fontSize: 17,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 8,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECOMMENDATION INFO
  // ============================================================

  Widget _buildRecommendationInfo({
    required String name,
    required String category,
    required String price,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(
            color: gold,
            fontSize: 9,
            letterSpacing: 3.2,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          name.toUpperCase(),
          style: const TextStyle(
            color: cream,
            fontFamily: 'Georgia',
            fontSize: 39,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
            height: 1.12,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: 55,
          height: 1,
          color: gold,
        ),

        const SizedBox(height: 22),

        Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(.62),
            fontSize: 14,
            height: 1.8,
          ),
        ),

        if (price.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            price,
            style: const TextStyle(
              color: brightGold,
              fontFamily: 'Georgia',
              fontSize: 25,
              letterSpacing: 1,
            ),
          ),
        ],

        const SizedBox(height: 28),

        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: gold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'SELECTED FOR YOUR PROFILE',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 8,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY RESULT
  // ============================================================

  Widget _buildEmptyResult() {
    return SingleChildScrollView(
      key: const ValueKey('empty-result'),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 90,
      ),
      child: Center(
        child: Column(
          children: [
            _buildTopBrand(),

            const SizedBox(height: 70),

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(
                  color: gold.withOpacity(.5),
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: gold,
                size: 34,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'NO MATCH FOUND',
              style: TextStyle(
                color: cream,
                fontFamily: 'Georgia',
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'We could not find a fragrance match right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(.55),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
              ),
              child: const Text(
                'START AGAIN',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorMessage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 650,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF110D08),
        border: Border.all(
          color: gold.withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: gold,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  String _formatPrice(
    dynamic rawPrice,
    dynamic rawCurrency,
  ) {
    if (rawPrice == null) {
      return '';
    }

    final currency = _stringValue(
      rawCurrency,
      fallback: 'PKR',
    );

    double? price;

    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else {
      price = double.tryParse(
        rawPrice.toString(),
      );
    }

    if (price == null) {
      return '';
    }

    final formatted = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);

    return '$currency $formatted';
  }
}

// ==================================================================
// BACKGROUND
// ==================================================================

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -180,
            left: -140,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD6A33A).withOpacity(.055),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -180,
            bottom: -180,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD6A33A).withOpacity(.035),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// OPTION WIDGET
// ==================================================================

class _FinderOption extends StatefulWidget {
  const _FinderOption({
    required this.option,
    required this.selected,
    required this.index,
    required this.enabled,
    required this.onTap,
  });

  final String option;
  final bool selected;
  final int index;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_FinderOption> createState() => _FinderOptionState();
}

class _FinderOptionState extends State<_FinderOption> {
  bool _hovered = false;

  static const Color gold = Color(0xFFD6A33A);

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.selected || _hovered;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!widget.enabled) {
          return;
        }

        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            maxWidth: 650,
            minHeight: 70,
          ),
          width: double.infinity,
          transform: Matrix4.identity()
            ..translate(
              highlighted ? 3.0 : 0.0,
              0.0,
            ),
          decoration: BoxDecoration(
            color: widget.selected
                ? gold.withOpacity(.09)
                : _hovered
                    ? Colors.white.withOpacity(.035)
                    : Colors.white.withOpacity(.018),
            border: Border.all(
              color: widget.selected
                  ? gold
                  : _hovered
                      ? Colors.white24
                      : Colors.white10,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 17,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.selected
                          ? gold
                          : Colors.white24,
                    ),
                    shape: BoxShape.circle,
                    color: widget.selected
                        ? gold.withOpacity(.12)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
                      width: widget.selected ? 9 : 5,
                      height: widget.selected ? 9 : 5,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? gold
                            : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 17),

                Expanded(
                  child: Text(
                    widget.option,
                    style: TextStyle(
                      color: widget.selected
                          ? gold
                          : Colors.white.withOpacity(.88),
                      fontSize: 14,
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      letterSpacing: .7,
                    ),
                  ),
                ),

                AnimatedOpacity(
                  duration:
                      const Duration(milliseconds: 180),
                  opacity: highlighted ? 1 : 0,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: gold,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
