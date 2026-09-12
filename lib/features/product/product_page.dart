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
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0D0D0D);
  static const Color border = Color(0xFF252525);
  static const Color muted = Color(0xFF777777);

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
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );

    return '$currency $formatted';
  }

  // ==========================================================
  // ADD PRODUCT TO NORMAL CART
  // ==========================================================

  Future<bool> _addProductToCart() async {
    if (_product == null) {
      return false;
    }

    final product = _product!;

    final id = product['id']?.toString() ?? '';
    final slug = product['slug']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Fragrance';
    final category = product['category']?.toString() ?? '';
    final description = product['description']?.toString() ?? '';

    final price = _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ?? 'PKR';

    final imageUrl =
        product['image_url']?.toString() ?? '';

    final stock = _parseInt(product['stock']);

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

    final success = await _addProductToCart();

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
  //
  // IMPORTANT:
  // This does NOT add anything to the normal CartService.
  //
  // The selected product is sent to CheckoutPage through
  // GoRouter's `extra`.
  //
  // CheckoutPage then creates a separate temporary cart
  // containing ONLY this product.
  // ==========================================================

  Future<void> _buyNow() async {
    if (_addingToCart || _product == null) {
      return;
    }

    final product = _product!;

    final id = product['id']?.toString() ?? '';
    final slug = product['slug']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Fragrance';
    final category = product['category']?.toString() ?? '';
    final description =
        product['description']?.toString() ?? '';

    final price = _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ?? 'PKR';

    final imageUrl =
        product['image_url']?.toString() ?? '';

    final stock = _parseInt(product['stock']);

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

    // ----------------------------------------------------------
    // Go to checkout WITHOUT touching the normal bag.
    // ----------------------------------------------------------

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

    final stock = _parseInt(
      _product!['stock'],
    );

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

  Widget _buildBody(BuildContext context) {
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
            constraints.maxWidth >= 900;

        return SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 70 : 22,
              vertical: desktop ? 40 : 22,
            ),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(
                  height: desktop ? 55 : 30,
                ),
                desktop
                    ? _buildDesktopProduct(context)
                    : _buildMobileProduct(context),
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
        IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/shop');
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          AppAssets.logo,
          height: 42,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            context.push('/cart');
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 25,
              ),
              AnimatedBuilder(
                animation: CartService.instance,
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
                    right: -7,
                    top: -7,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
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
                          fontSize: 8,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _buildDesktopProduct(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildProductImage(
            desktop: true,
          ),
        ),
        const SizedBox(width: 70),
        Expanded(
          flex: 5,
          child: _buildProductInformation(
            context,
          ),
        ),
      ],
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
        const SizedBox(height: 35),
        _buildProductInformation(context),
      ],
    );
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  Widget _buildProductImage({
    required bool desktop,
  }) {
    final product = _product!;

    var imageUrl =
        product['image_url']?.toString() ?? '';

    final name =
        product['name']?.toString() ?? '';

    if (imageUrl.isEmpty &&
        name.toLowerCase() == 'champions') {
      imageUrl =
          AppAssets.championsReference;
    }

    return Container(
      width: double.infinity,
      height: desktop ? 620 : 430,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: border,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildProductImageWidget(
              imageUrl,
            ),
          ),
          if (_toBoolean(
            product['is_featured'],
          ))
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                color: gold,
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
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
        product['category']?.toString() ?? '';

    final description =
        product['description']?.toString() ?? '';

    final price =
        _parseInt(product['price']);

    final currency =
        product['currency']?.toString() ?? 'PKR';

    final stock =
        _parseInt(product['stock']);

    final outOfStock =
        stock <= 0;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (category.isNotEmpty)
          Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 18),
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
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 13,
              height: 1.8,
            ),
          ),
        const SizedBox(height: 35),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: outOfStock
                    ? const Color(0xFF8A4444)
                    : gold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              outOfStock
                  ? 'OUT OF STOCK'
                  : '$stock AVAILABLE',
              style: TextStyle(
                color: outOfStock
                    ? const Color(0xFFAA6666)
                    : const Color(0xFF999999),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            const Text(
              'QUANTITY',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 20),
            _buildQuantitySelector(
              disabled:
                  outOfStock || _addingToCart,
            ),
          ],
        ),
        const SizedBox(height: 25),

        // ======================================================
        // BUY NOW
        // ======================================================

        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed:
                outOfStock || _addingToCart
                    ? null
                    : _buyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              disabledBackgroundColor:
                  const Color(0xFF292929),
              disabledForegroundColor:
                  const Color(0xFF666666),
              elevation: 0,
              shape:
                  const RoundedRectangleBorder(),
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 18,
                ),
                SizedBox(width: 9),
                Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // ADD TO BAG
        // ======================================================

        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton(
            onPressed:
                outOfStock || _addingToCart
                    ? null
                    : _addToBag,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor:
                  const Color(0xFF555555),
              side: const BorderSide(
                color: Color(0xFF444444),
              ),
              shape:
                  const RoundedRectangleBorder(),
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 17,
                ),
                SizedBox(width: 9),
                Text(
                  'ADD TO BAG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        _buildFeatureRow(
          Icons.local_shipping_outlined,
          'FREE DELIVERY',
          'Delivery available across Pakistan',
        ),
        const SizedBox(height: 18),
        _buildFeatureRow(
          Icons.verified_outlined,
          'AUTHENTIC FRAGRANCE',
          'Original SHANO SHAN fragrance',
        ),
        const SizedBox(height: 18),
        _buildFeatureRow(
          Icons.replay_outlined,
          'SECURE ORDERING',
          'Safe and simple checkout',
        ),
      ],
    );
  }

  // ==========================================================
  // QUANTITY
  // ==========================================================

  Widget _buildQuantitySelector({
    required bool disabled,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed:
                disabled
                    ? null
                    : _decreaseQuantity,
            icon: const Icon(
              Icons.remove,
              size: 15,
            ),
            color: Colors.white,
            disabledColor:
                const Color(0xFF444444),
          ),
          Container(
            width: 35,
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed:
                disabled
                    ? null
                    : _increaseQuantity,
            icon: const Icon(
              Icons.add,
              size: 15,
            ),
            color: gold,
            disabledColor:
                const Color(0xFF555555),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FEATURE
  // ==========================================================

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: gold,
          size: 21,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
            ],
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
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFF555555),
              size: 60,
            ),
            const SizedBox(height: 25),
            Text(
              _error ?? 'Product not found.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: _loadProduct,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF444444),
                    ),
                  ),
                  child:
                      const Text('TRY AGAIN'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.go('/shop'),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  child: const Text('SHOP'),
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
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor:
              const Color(0xFF171717),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(seconds: 2),
        ),
      );
  }

  // ==========================================================
  // ERROR CLEAN
  // ==========================================================

  String _cleanError(
    Object error,
  ) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}