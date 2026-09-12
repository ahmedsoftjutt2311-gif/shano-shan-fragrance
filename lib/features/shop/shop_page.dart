import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../services/cart_service.dart';
import '../../core/constants/app_assets.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({
    super.key,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF050505);
  static const Color card = Color(0xFF0D0D0D);
  static const Color border = Color(0xFF252525);

  List<_Fragrance> _products = [];

  bool _isLoading = true;

  String? _errorMessage;

  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/products'),
        headers: const {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'SHOP PRODUCTS RESPONSE: ${response.statusCode}',
      );

      debugPrint(
        'SHOP PRODUCTS BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid server response.',
        );
      }

      final data = Map<String, dynamic>.from(decoded);

      final rawProducts = data['products'];

      if (rawProducts is! List) {
        throw Exception(
          'Products were not found.',
        );
      }

      final loaded = <_Fragrance>[];

      for (final rawProduct in rawProducts) {
        if (rawProduct is! Map) {
          continue;
        }

        final product = _Fragrance.fromJson(
          Map<String, dynamic>.from(rawProduct),
        );

        if (product.slug.trim().isEmpty) {
          continue;
        }

        if (!product.isActive) {
          continue;
        }

        loaded.add(product);
      }

      if (!mounted) return;

      setState(() {
        _products = loaded;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'SHOP PRODUCTS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _products = [];
        _isLoading = false;
        _errorMessage =
            'Unable to load fragrances right now.';
      });
    }
  }

  List<_Fragrance> get _filteredProducts {
    if (_selectedCategory == 'ALL') {
      return _products;
    }

    return _products
        .where(
          (product) =>
              product.category.toUpperCase() ==
              _selectedCategory,
        )
        .toList();
  }

  List<String> get _categories {
    final values = <String>{'ALL'};

    for (final product in _products) {
      final category = product.category.trim();

      if (category.isNotEmpty) {
        values.add(category.toUpperCase());
      }
    }

    return values.toList();
  }

  String _formatPrice(
    int price,
    String currency,
  ) {
    final formatted = price
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );

    return '$currency $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: CartService.instance,
          builder: (context, child) {
            return _buildBody(context);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isDesktop =
            constraints.maxWidth >= 900;

        return SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 70 : 22,
            vertical: isDesktop ? 45 : 25,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 55),
              _buildIntro(isDesktop),
              const SizedBox(height: 45),
              _buildCategories(),
              const SizedBox(height: 40),
              _buildContent(
                context,
                isDesktop,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(
    BuildContext context,
  ) {
    final count =
        CartService.instance.itemCount;

    return Row(
      children: [
        Image.asset(
          AppAssets.logo,
          height: 42,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                context.push('/cart');
              },
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 2,
                top: 0,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 99
                          ? '99+'
                          : '$count',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntro(
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'THE COLLECTION',
          style: TextStyle(
            color: gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Discover Your\nSignature Scent.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 54 : 38,
            height: 1.05,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 650,
          child: Text(
            'Explore the SHANO SHAN fragrance collection, crafted for those who believe every fragrance should tell a story.',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 15,
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in _categories) ...[
            _buildCategoryButton(category),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
  ) {
    final selected =
        category == _selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color:
              selected ? gold : Colors.transparent,
          border: Border.all(
            color: selected
                ? gold
                : const Color(0xFF333333),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: selected
                ? Colors.black
                : const Color(0xFFAAAAAA),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDesktop,
  ) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(80),
          child: CircularProgressIndicator(
            color: gold,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Color(0xFF777777),
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              OutlinedButton(
                onPressed: _loadProducts,
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: const BorderSide(
                    color: gold,
                  ),
                ),
                child: const Text(
                  'TRY AGAIN',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(80),
          child: Text(
            'No fragrances found.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            isDesktop ? 4 : 1,
        crossAxisSpacing:
            isDesktop ? 22 : 0,
        mainAxisSpacing: 30,
        childAspectRatio:
            isDesktop ? 0.72 : 0.9,
      ),
      itemBuilder: (
        context,
        index,
      ) {
        return _buildProductCard(
          context,
          products[index],
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    _Fragrance product,
  ) {
    final isOutOfStock =
        product.stock <= 0;

    String imageUrl =
        product.imageUrl;

    if (imageUrl.isEmpty &&
        product.name.toUpperCase() ==
            'CHAMPIONS') {
      imageUrl =
          AppAssets.championsReference;
    }

    return GestureDetector(
      onTap: () {
        context.push(
          '/product/${product.slug}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: card,
          border: Border.all(
            color: border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildProductImage(
                imageUrl,
                isOutOfStock,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category
                        .toUpperCase(),
                    style: const TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _formatPrice(
                          product.price,
                          product.currency,
                        ),
                        style:
                            const TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (!isOutOfStock)
                        const Icon(
                          Icons.arrow_forward,
                          color:
                              Color(0xFF777777),
                          size: 17,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    String imageUrl,
    bool isOutOfStock,
  ) {
    Widget image;

    if (imageUrl.isEmpty) {
      image = const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF555555),
          size: 55,
        ),
      );
    } else if (imageUrl.startsWith('http')) {
      image = Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF555555),
              size: 55,
            ),
          );
        },
      );
    } else {
      image = Image.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF555555),
              size: 55,
            ),
          );
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFF111111),
          child: image,
        ),
        if (isOutOfStock)
          Container(
            color: Colors.black.withValues(
              alpha: 0.62,
            ),
            child: const Center(
              child: Text(
                'OUT OF STOCK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Fragrance {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String description;
  final int price;
  final String currency;
  final String imageUrl;
  final int stock;
  final bool isActive;
  final bool isFeatured;

  const _Fragrance({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.stock,
    required this.isActive,
    required this.isFeatured,
  });

  factory _Fragrance.fromJson(
    Map<String, dynamic> json,
  ) {
    return _Fragrance(
      id: json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ??
              'Fragrance',
      slug:
          json['slug']?.toString() ?? '',
      category:
          json['category']?.toString() ??
              '',
      description:
          json['description']?.toString() ??
              '',
      price: _parseInt(
        json['price'],
      ),
      currency:
          json['currency']?.toString() ??
              'PKR',
      imageUrl:
          json['image_url']?.toString() ??
              '',
      stock: _parseInt(
        json['stock'],
      ),
      isActive:
          _toBool(json['is_active']),
      isFeatured:
          _toBool(json['is_featured']),
    );
  }

  static int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static bool _toBool(
    dynamic value,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text =
        value?.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'on';
  }
}