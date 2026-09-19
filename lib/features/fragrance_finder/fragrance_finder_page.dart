
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class FragranceFinderPage extends StatefulWidget {
  const FragranceFinderPage({super.key});

  @override
  State<FragranceFinderPage> createState() => _FragranceFinderPageState();
}

class _FragranceFinderPageState extends State<FragranceFinderPage> {
  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  int _step = 0;

  String? _occasion;
  String? _mood;
  String? _style;

  bool _showResult = false;
  bool _loadingProducts = false;

  String? _errorMessage;

  List<Map<String, dynamic>> _products = [];

  Map<String, dynamic>? _recommendedProduct;

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

  // ======================================================
  // SELECTION
  // ======================================================

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

  // ======================================================
  // NEXT
  // ======================================================

  Future<void> _next() async {
    if (_step == 0 && _occasion == null) {
      return;
    }

    if (_step == 1 && _mood == null) {
      return;
    }

    if (_step == 2 && _style == null) {
      return;
    }

    if (_step < 2) {
      setState(() {
        _step++;
      });

      return;
    }

    await _findMyScent();
  }

  // ======================================================
  // FIND REAL PRODUCT
  // ======================================================

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
          .where(
            (product) => _isActiveProduct(product),
          )
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

  // ======================================================
  // PRODUCT FILTER
  // ======================================================

  bool _isActiveProduct(Map<String, dynamic> product) {
    final value =
        product['is_active'] ?? product['isActive'];

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

  // ======================================================
  // RECOMMENDATION ENGINE
  // ======================================================

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

    // ====================================================
    // STYLE
    // ====================================================

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

    // ====================================================
    // MOOD
    // ====================================================

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

    // ====================================================
    // OCCASION
    // ====================================================

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

    // Featured products get a small preference when
    // there is otherwise no strong textual match.
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
    final value =
        product['is_featured'] ?? product['isFeatured'];

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

  // ======================================================
  // BACK
  // ======================================================

  void _back() {
    if (_loadingProducts) {
      return;
    }

    if (_showResult) {
      setState(() {
        _showResult = false;
        _errorMessage = null;
      });

      return;
    }

    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  // ======================================================
  // RESTART
  // ======================================================

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
  }

  // ======================================================
  // CURRENT QUESTION
  // ======================================================

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

  // ======================================================
  // RECOMMENDATION REASON
  // ======================================================

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

  // ======================================================
  // ERROR
  // ======================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return 'We could not load your fragrance recommendation. '
        'Please try again.';
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _showResult
              ? _buildResult()
              : _buildQuiz(),
        ),
      ),
    );
  }

  // ======================================================
  // QUIZ
  // ======================================================

  Widget _buildQuiz() {
    return SingleChildScrollView(
      key: const ValueKey('quiz'),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'SHANO SHAN',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 13,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'FIND YOUR SCENT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Discover the fragrance direction that fits your mood, '
                'occasion and personal style.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .65),
                  fontSize: 16,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 55),

              _buildProgress(),

              const SizedBox(height: 55),

              Text(
                _questionTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              ..._currentOptions.map(_buildOption),

              const SizedBox(height: 40),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  child: _buildErrorMessage(),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: _loadingProducts
                          ? null
                          : _back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: .25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('BACK'),
                    ),

                  if (_step > 0)
                    const SizedBox(width: 14),

                  ElevatedButton(
                    onPressed: _currentSelection == null ||
                            _loadingProducts
                        ? null
                        : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor:
                          const Color(0xFF252525),
                      disabledForegroundColor:
                          Colors.white38,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 18,
                      ),
                    ),
                    child: _loadingProducts
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            _step == 2
                                ? 'DISCOVER MY SCENT'
                                : 'CONTINUE',
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // PROGRESS
  // ======================================================

  Widget _buildProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) {
          final active = index <= _step;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            width: 70,
            height: 3,
            color: active
                ? const Color(0xFFD4AF37)
                : Colors.white12,
          );
        },
      ),
    );
  }

  // ======================================================
  // OPTION
  // ======================================================

  Widget _buildOption(String option) {
    final selected = _currentSelection == option;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: InkWell(
        onTap: _loadingProducts
            ? null
            : () => _select(option),
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFD4AF37).withValues(alpha: .12)
                : Colors.white.withValues(alpha: .025),
            border: Border.all(
              color: selected
                  ? const Color(0xFFD4AF37)
                  : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFFD4AF37)
                    : Colors.white38,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFD4AF37)
                        : Colors.white,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // RESULT
  // ======================================================

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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            children: [
              const Text(
                'YOUR SCENT DIRECTION',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 13,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'WE FOUND YOUR MATCH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3.5,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 1,
                width: 100,
                color: const Color(0xFFD4AF37),
              ),

              const SizedBox(height: 45),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .025),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxWidth < 650;

                    if (compact) {
                      return Column(
                        children: [
                          _buildProductImage(
                            imageUrl,
                            height: 320,
                          ),

                          const SizedBox(height: 30),

                          _buildRecommendationInfo(
                            name: name,
                            category: category,
                            price: price,
                            description: description,
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildProductImage(
                            imageUrl,
                            height: 430,
                          ),
                        ),

                        const SizedBox(width: 50),

                        Expanded(
                          child: _buildRecommendationInfo(
                            name: name,
                            category: category,
                            price: price,
                            description: description,
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
                  color: Colors.white.withValues(alpha: .7),
                  fontSize: 16,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Based on your choices: '
                '${_occasion ?? ''} • '
                '${_mood ?? ''} • '
                '${_style ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 38),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (slug.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/product/${Uri.encodeComponent(slug)}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 34,
                          vertical: 20,
                        ),
                      ),
                      child: Text(
                        'DISCOVER $name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: _restart,
                child: const Text(
                  'START AGAIN',
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
              ),

              if (_products.length > 1)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                  ),
                  child: Text(
                    '${_products.length} SHANO SHAN '
                    'fragrances available in our collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .35),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // PRODUCT IMAGE
  // ======================================================

  Widget _buildProductImage(
    String imageUrl, {
    required double height,
  }) {
    if (imageUrl.isNotEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0B),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _buildImageFallback();
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
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
              ),
            );
          },
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome,
          size: 42,
          color: const Color(0xFFD4AF37)
              .withValues(alpha: .7),
        ),

        const SizedBox(height: 15),

        const Text(
          'SHANO SHAN',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontFamily: 'Georgia',
            fontSize: 17,
            letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'FRAGRANCE',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // RECOMMENDATION INFO
  // ======================================================

  Widget _buildRecommendationInfo({
    required String name,
    required String category,
    required String price,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Georgia',
            fontSize: 38,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.5,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: 60,
          height: 1,
          color: const Color(0xFFD4AF37),
        ),

        const SizedBox(height: 20),

        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .65),
            fontSize: 15,
            height: 1.7,
          ),
        ),

        if (price.isNotEmpty) ...[
          const SizedBox(height: 24),

          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontFamily: 'Georgia',
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  // ======================================================
  // EMPTY RESULT
  // ======================================================

  Widget _buildEmptyResult() {
    return SingleChildScrollView(
      key: const ValueKey('empty-result'),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFFD4AF37),
              size: 48,
            ),

            const SizedBox(height: 25),

            const Text(
              'NO MATCH FOUND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 3,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'We could not find a fragrance match right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'START AGAIN',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // ERROR MESSAGE
  // ======================================================

  Widget _buildErrorMessage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 650,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .06),
        border: Border.all(
          color: Colors.red.withValues(alpha: .25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white54,
            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // STRING HELPERS
  // ======================================================

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

  // ======================================================
  // PRICE
  // ======================================================

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
