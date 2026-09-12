
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_assets.dart';
import '../../services/cart_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.slug,
  });

  final String slug;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // ==========================================================
  // COLORS
  // ==========================================================

  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE8D49A);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0B0B0B);

  static const Color border = Color(0xFF252525);
  static const Color borderLight = Color(0xFF333333);
  static const Color muted = Color(0xFF777777);
  static const Color lightText = Color(0xFFAAAAAA);

  // ==========================================================
  // API
  // ==========================================================

  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  // ==========================================================
  // STATE
  // ==========================================================

  Map<String, dynamic>? _product;

  bool _loading = true;
  bool _addingToCart = false;

  int _quantity = 1;

  String? _error;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ==========================================================
  // LOAD PRODUCT
  // ==========================================================

  Future<void> _loadProduct() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/api/products/${Uri.encodeComponent(widget.slug)}',
      );

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'PRODUCT RESPONSE: ${response.statusCode}',
      );

      debugPrint(
        'PRODUCT BODY: ${response.body}',
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Product could not be loaded.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid product response.',
        );
      }

      final data = Map<String, dynamic>.from(decoded);

      final rawProduct = data['product'];

      if (rawProduct is! Map) {
        throw Exception(
          'Product not found.',
        );
      }

      final product =
          Map<String, dynamic>.from(rawProduct);

      final active = _toBoolean(
        product['is_active'],
        fallback: true,
      );

      if (!active) {
        throw Exception(
          'This fragrance is currently unavailable.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'PRODUCT ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _cleanError(e);
      });
    }
  }

  // ==========================================================
  // BOOLEAN
  // ==========================================================

  bool _toBoolean(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
        value.toString().trim().toLowerCase();

    if (normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'on') {
      return true;
    }

    if (normalized == 'false' ||
        normalized == '0' ||
        normalized == 'no' ||
        normalized == 'off') {
      return false;
    }

    return fallback;
  }

  // ==========================================================
  // INTEGER
  // ==========================================================

  int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.round() ??
        0;
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  String _formatPrice(
    int price,
    String currency,
  ) {
    final formatted =
        price.toString().replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (_) => ',',
            );

    return '$currency $formatted';
  }

  // ==========================================================
  // ADD TO NORMAL CART
  // ==========================================================

  Future<bool> _addProductToCart() async {
    if (_product == null) {
      return false;
    }

    final product = _product!;

    final id =
        product['id']?.toString() ?? '';

    final slug =
        product['slug']?.toString() ?? '';

    final name =
        product['name']?.toString() ?? 'Fragrance';

    final category =
        product['category']?.toString() ?? '';

    final description =
        product['description']?.toString() ?? '';

    final price =
        _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ?? 'PKR';

    final imageUrl =
        product['image_url']?.toString() ?? '';

    final stock =
        _parseInt(product['stock']);

    if (id.isEmpty) {
      _showMessage(
        'Product ID is missing.',
      );
      return false;
    }

    if (stock <= 0) {
      _showMessage(
        'This fragrance is out of stock.',
      );
      return false;
    }

    if (_quantity > stock) {
      _showMessage(
        'Not enough stock available.',
      );
      return false;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      return await CartService.instance.addItem(
        id: id,
        slug: slug,
        name: name,
        category: category,
        description: description,
        price: price,
        currency: currency,
        imageUrl: imageUrl,
        stock: stock,
        quantity: _quantity,
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  // ==========================================================
  // ADD TO BAG
  // ==========================================================

  Future<void> _addToBag() async {
    if (_addingToCart) {
      return;
    }

    final success =
        await _addProductToCart();

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        'Added to your bag.',
      );
    } else {
      _showMessage(
        CartService.instance.error ??
            'Could not add this fragrance.',
      );
    }
  }

  // ==========================================================
  // BUY NOW
  // ==========================================================

  Future<void> _buyNow() async {
    if (_addingToCart ||
        _product == null) {
      return;
    }

    final product = _product!;

    final id =
        product['id']?.toString() ?? '';

    final slug =
        product['slug']?.toString() ?? '';

    final name =
        product['name']?.toString() ?? 'Fragrance';

    final category =
        product['category']?.toString() ?? '';

    final description =
        product['description']?.toString() ?? '';

    final price =
        _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ?? 'PKR';

    final imageUrl =
        product['image_url']?.toString() ?? '';

    final stock =
        _parseInt(product['stock']);

    if (id.isEmpty) {
      _showMessage(
        'Product ID is missing.',
      );
      return;
    }

    if (stock <= 0) {
      _showMessage(
        'This fragrance is out of stock.',
      );
      return;
    }

    if (_quantity > stock) {
      _showMessage(
        'Not enough stock available.',
      );
      return;
    }

    // IMPORTANT:
    // Buy Now does not modify the normal bag.
    context.push(
      '/checkout',
      extra: {
        'buy_now': true,
        'product': {
          'id': id,
          'slug': slug,
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'currency': currency,
          'image_url': imageUrl,
          'stock': stock,
        },
        'quantity': _quantity,
      },
    );
  }

  // ==========================================================
  // QUANTITY
  // ==========================================================

  void _increaseQuantity() {
    if (_product == null) {
      return;
    }

    final stock =
        _parseInt(_product!['stock']);

    if (_quantity >= stock) {
      _showMessage(
        'Maximum available stock reached.',
      );
      return;
    }

    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }

    setState(() {
      _quantity--;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody(
    BuildContext context,
  ) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: gold,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return _buildError(context);
    }

    if (_product == null) {
      return _buildError(context);
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final desktop =
            constraints.maxWidth >= 950;

        return SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  desktop ? 70 : 20,
              vertical:
                  desktop ? 32 : 18,
            ),
            child: Column(
              children: [
                _buildHeader(context),

                SizedBox(
                  height:
                      desktop ? 45 : 28,
                ),

                desktop
                    ? _buildDesktopProduct(
                        context,
                      )
                    : _buildMobileProduct(
                        context,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Row(
      children: [
        _headerButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/shop');
            }
          },
        ),

        const SizedBox(width: 12),

        Image.asset(
          AppAssets.logo,
          height: 42,
          fit: BoxFit.contain,
        ),

        const Spacer(),

        _headerButton(
          icon: Icons.shopping_bag_outlined,
          onTap: () {
            context.push('/cart');
          },
          showBadge: true,
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: panel,
          shape: BoxShape.circle,
          border: Border.all(
            color: border,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),

            if (showBadge)
              AnimatedBuilder(
                animation:
                    CartService.instance,
                builder: (
                  context,
                  _,
                ) {
                  final count =
                      CartService.instance.itemCount;

                  if (count <= 0) {
                    return const SizedBox();
                  }

                  return Positioned(
                    right: -11,
                    top: -11,
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
                      alignment:
                          Alignment.center,
                      decoration:
                          const BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 99
                            ? '99+'
                            : '$count',
                        style:
                            const TextStyle(
                          color: Colors.black,
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _buildDesktopProduct(
    BuildContext context,
  ) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(
        maxWidth: 1450,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _buildProductImage(
              desktop: true,
            ),
          ),

          const SizedBox(width: 80),

          Expanded(
            flex: 5,
            child:
                _buildProductInformation(
              context,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

  Widget _buildMobileProduct(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildProductImage(
          desktop: false,
        ),

        const SizedBox(height: 38),

        _buildProductInformation(
          context,
        ),
      ],
    );
  }

  // ==========================================================
  // PRODUCT IMAGE
  // ==========================================================

  Widget _buildProductImage({
    required bool desktop,
  }) {
    final product = _product!;

    var imageUrl =
        product['image_url']
                ?.toString() ??
            '';

    final name =
        product['name']?.toString() ?? '';

    if (imageUrl.isEmpty &&
        name.toLowerCase() ==
            'champions') {
      imageUrl =
          AppAssets.championsReference;
    }

    final featured =
        _toBoolean(
      product['is_featured'],
    );

    return Container(
      width: double.infinity,
      height: desktop ? 680 : 460,
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        border: Border.all(
          color: border,
        ),
      ),
      child: Stack(
        children: [
          // Soft center glow
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      RadialGradient(
                    center:
                        Alignment.center,
                    radius: 0.75,
                    colors: [
                      const Color(
                        0xFF171717,
                      ),
                      const Color(
                        0xFF090909,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child:
                _buildProductImageWidget(
              imageUrl,
            ),
          ),

          // Top category
          Positioned(
            top: 22,
            left: 22,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(alpha: 0.65),
                border: Border.all(
                  color: borderLight,
                ),
              ),
              child: Text(
                product['category']
                        ?.toString()
                        .toUpperCase() ??
                    'FRAGRANCE',
                style:
                    const TextStyle(
                  color: softGold,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w600,
                  letterSpacing: 1.7,
                ),
              ),
            ),
          ),

          if (featured)
            Positioned(
              top: 22,
              right: 22,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                color: gold,
                child: const Text(
                  'FEATURED',
                  style:
                      TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

          // Bottom editorial label
          Positioned(
            bottom: 22,
            left: 22,
            right: 22,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 1,
                  color: gold,
                ),
                const SizedBox(width: 10),
                Text(
                  'SHANO SHAN FRAGRANCE',
                  style:
                      TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.4),
                    fontSize: 8,
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

  // ==========================================================
  // IMAGE WIDGET
  // ==========================================================

  Widget _buildProductImageWidget(
    String imageUrl,
  ) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF444444),
          size: 60,
        ),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF444444),
              size: 60,
            ),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF444444),
            size: 60,
          ),
        );
      },
    );
  }

  // ==========================================================
  // PRODUCT INFORMATION
  // ==========================================================

  Widget _buildProductInformation(
    BuildContext context,
  ) {
    final product = _product!;

    final name =
        product['name']?.toString() ??
            'Fragrance';

    final category =
        product['category']?.toString() ??
            '';

    final description =
        product['description']
                ?.toString() ??
            '';

    final price =
        _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ??
            'PKR';

    final stock =
        _parseInt(product['stock']);

    final outOfStock =
        stock <= 0;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Row(
          children: [
            Container(
              width: 32,
              height: 1,
              color: gold,
            ),
            const SizedBox(width: 12),
            Text(
              category.isEmpty
                  ? 'SHANO SHAN'
                  : category.toUpperCase(),
              style:
                  const TextStyle(
                color: gold,
                fontSize: 9,
                fontWeight:
                    FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Product name
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            height: 1.05,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 18),

        // Price
        Text(
          _formatPrice(
            price,
            currency,
          ),
          style: const TextStyle(
            color: gold,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 28),

        Container(
          height: 1,
          color: border,
        ),

        const SizedBox(height: 28),

        // Description
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              color: lightText,
              fontSize: 14,
              height: 1.9,
            ),
          ),

        const SizedBox(height: 30),

        // Stock
        _buildStockStatus(
          stock,
          outOfStock,
        ),

        const SizedBox(height: 30),

        // Quantity
        _buildQuantityArea(
          outOfStock,
        ),

        const SizedBox(height: 26),

        // Buy now
        _buildBuyNowButton(
          outOfStock,
        ),

        const SizedBox(height: 12),

        // Add to bag
        _buildAddToBagButton(
          outOfStock,
        ),

        const SizedBox(height: 34),

        // Features
        _buildFeatures(),

        const SizedBox(height: 30),

        // Trust line
        _buildTrustLine(),
      ],
    );
  }

  // ==========================================================
  // STOCK
  // ==========================================================

  Widget _buildStockStatus(
    int stock,
    bool outOfStock,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: outOfStock
            ? const Color(0xFF160D0D)
            : const Color(0xFF10100D),
        border: Border.all(
          color: outOfStock
              ? const Color(0xFF382020)
              : const Color(0xFF292919),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(
              color: outOfStock
                  ? const Color(
                      0xFF9A5555,
                    )
                  : gold,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            outOfStock
                ? 'CURRENTLY UNAVAILABLE'
                : '$stock AVAILABLE',
            style: TextStyle(
              color: outOfStock
                  ? const Color(
                      0xFFAA7777,
                    )
                  : const Color(
                      0xFFAAAAAA,
                    ),
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // QUANTITY AREA
  // ==========================================================

  Widget _buildQuantityArea(
    bool outOfStock,
  ) {
    return Row(
      children: [
        const Text(
          'QUANTITY',
          style: TextStyle(
            color: muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(width: 18),

        _buildQuantitySelector(
          disabled:
              outOfStock ||
                  _addingToCart,
        ),
      ],
    );
  }

  // ==========================================================
  // BUY NOW BUTTON
  // ==========================================================

  Widget _buildBuyNowButton(
    bool outOfStock,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed:
            outOfStock ||
                    _addingToCart
                ? null
                : _buyNow,
        style:
            ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor:
              Colors.black,
          disabledBackgroundColor:
              const Color(0xFF292929),
          disabledForegroundColor:
              const Color(0xFF666666),
          elevation: 0,
          shape:
              const RoundedRectangleBorder(),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bolt_rounded,
              size: 19,
            ),
            const SizedBox(width: 9),
            Text(
              _addingToCart
                  ? 'PLEASE WAIT'
                  : 'BUY NOW',
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ADD TO BAG BUTTON
  // ==========================================================

  Widget _buildAddToBagButton(
    bool outOfStock,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed:
            outOfStock ||
                    _addingToCart
                ? null
                : _addToBag,
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              Colors.white,
          disabledForegroundColor:
              const Color(0xFF555555),
          side: const BorderSide(
            color: borderLight,
          ),
          shape:
              const RoundedRectangleBorder(),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 17,
            ),
            const SizedBox(width: 9),
            Text(
              _addingToCart
                  ? 'ADDING...'
                  : 'ADD TO BAG',
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // QUANTITY SELECTOR
  // ==========================================================

  Widget _buildQuantitySelector({
    required bool disabled,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove,
            onTap: disabled
                ? null
                : _decreaseQuantity,
          ),

          Container(
            width: 48,
            alignment:
                Alignment.center,
            child: Text(
              '$_quantity',
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.add,
            goldIcon: true,
            onTap: disabled
                ? null
                : _increaseQuantity,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool goldIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 44,
        child: Icon(
          icon,
          size: 15,
          color: onTap == null
              ? const Color(
                  0xFF444444,
                )
              : goldIcon
                  ? gold
                  : Colors.white,
        ),
      ),
    );
  }

  // ==========================================================
  // FEATURES
  // ==========================================================

  Widget _buildFeatures() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            Icons.local_shipping_outlined,
            'FREE DELIVERY',
            'Delivery available across Pakistan',
          ),
          const SizedBox(height: 18),
          _buildFeatureDivider(),
          const SizedBox(height: 18),
          _buildFeatureItem(
            Icons.verified_outlined,
            'AUTHENTIC FRAGRANCE',
            'Original SHANO SHAN fragrance',
          ),
          const SizedBox(height: 18),
          _buildFeatureDivider(),
          const SizedBox(height: 18),
          _buildFeatureItem(
            Icons.lock_outline_rounded,
            'SECURE ORDERING',
            'Safe and simple checkout',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment:
              Alignment.center,
          decoration: BoxDecoration(
            color: const Color(
              0xFF151515,
            ),
            border: Border.all(
              color: border,
            ),
          ),
          child: Icon(
            icon,
            color: gold,
            size: 18,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                style:
                    const TextStyle(
                  color: muted,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureDivider() {
    return Container(
      height: 1,
      color: const Color(
        0xFF1D1D1D,
      ),
    );
  }

  // ==========================================================
  // TRUST LINE
  // ==========================================================

  Widget _buildTrustLine() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.shield_outlined,
          color: Color(0xFF666666),
          size: 15,
        ),
        const SizedBox(width: 8),
        Text(
          'A REFINED SHANO SHAN EXPERIENCE',
          style: TextStyle(
            color: Colors.white
                .withValues(alpha: 0.3),
            fontSize: 8,
            letterSpacing: 1.7,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildError(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: panel,
                shape: BoxShape.circle,
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Icon(
                Icons
                    .error_outline_rounded,
                color:
                    Color(0xFF555555),
                size: 34,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              _error ??
                  'Product not found.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed:
                      _loadProduct,
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Colors.white,
                    side:
                        const BorderSide(
                      color:
                          borderLight,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                  ),
                  child:
                      const Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: () =>
                      context.go(
                    '/shop',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        gold,
                    foregroundColor:
                        Colors.black,
                    elevation: 0,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                  ),
                  child:
                      const Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style:
                const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor:
              const Color(0xFF171717),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ==========================================================
  // ERROR CLEAN
  // ==========================================================

  String _cleanError(
    Object error,
  ) {
    final message =
        error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}
