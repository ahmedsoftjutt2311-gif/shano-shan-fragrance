import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/cart_service.dart';
import '../../core/constants/app_assets.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0D0D0D);
  static const Color border = Color(0xFF252525);

  @override
  void initState() {
    super.initState();

    // Refresh from Cloudflare D1 whenever the cart page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CartService.instance.loadCart();
    });
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
            return LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                final isDesktop = constraints.maxWidth >= 950;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 70 : 22,
                        vertical: isDesktop ? 45 : 25,
                      ),
                      child: isDesktop
                          ? _buildDesktop(context)
                          : _buildMobile(context),
                    ),

                    // Global loading overlay.
                    if (CartService.instance.loading)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.black.withValues(
                              alpha: 0.35,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    gold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final cart = CartService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 50),

        if (cart.error != null && cart.error!.isNotEmpty)
          _buildErrorMessage(),

        if (cart.isEmpty)
          _buildEmptyCart(context)
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildItems(),
              ),
              const SizedBox(width: 50),
              SizedBox(
                width: 390,
                child: _buildSummary(context),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    final cart = CartService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 35),

        if (cart.error != null && cart.error!.isNotEmpty)
          _buildErrorMessage(),

        if (cart.isEmpty)
          _buildEmptyCart(context)
        else ...[
          _buildItems(),
          const SizedBox(height: 35),
          _buildSummary(context),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    final error = CartService.instance.error;

    if (error == null || error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF160C0C),
        border: Border.all(
          color: const Color(0xFF402020),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFCC7777),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFCCAAAA),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              CartService.instance.loadCart();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 19,
            ),
            tooltip: 'Retry',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cart = CartService.instance;

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
            size: 19,
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          AppAssets.logo,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 25),
        const Text(
          'YOUR BAG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const Spacer(),
        if (cart.isNotEmpty)
          TextButton(
            onPressed: cart.loading
                ? null
                : () {
                    _showClearCartDialog(context);
                  },
            child: const Text(
              'CLEAR BAG',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF555555),
              size: 70,
            ),
            const SizedBox(height: 30),
            const Text(
              'YOUR BAG IS EMPTY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Discover a fragrance crafted for your story.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: 230,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/shop');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'EXPLORE FRAGRANCES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems() {
    final items = CartService.instance.items;

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildCartItem(items[i]),
          if (i != items.length - 1)
            const SizedBox(height: 15),
        ],
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(
          color: border,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(item),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildProductInfo(item),
                    ),
                    _buildRemoveButton(item),
                  ],
                ),
                const SizedBox(height: 20),
                _buildQuantityAndPrice(item),
              ],
            );
          }

          return Row(
            children: [
              _buildProductImage(item),
              const SizedBox(width: 24),
              Expanded(
                child: _buildProductInfo(item),
              ),
              _buildQuantityAndPrice(item),
              const SizedBox(width: 15),
              _buildRemoveButton(item),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    String imageUrl = item.imageUrl;

    // CHAMPIONS has a frontend fallback image.
    if (imageUrl.isEmpty &&
        item.name.toLowerCase() == 'champions') {
      imageUrl = AppAssets.championsReference;
    }

    Widget image;

    if (imageUrl.isEmpty) {
      image = const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF555555),
          size: 40,
        ),
      );
    } else if (imageUrl.startsWith('http')) {
      image = Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF555555),
              size: 40,
            ),
          );
        },
      );
    } else {
      image = Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF555555),
              size: 40,
            ),
          );
        },
      );
    }

    return Container(
      width: 120,
      height: 140,
      color: const Color(0xFF111111),
      child: image,
    );
  }

  Widget _buildProductInfo(CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.category.toUpperCase(),
          style: const TextStyle(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _formatPrice(
            item.price,
            item.currency,
          ),
          style: const TextStyle(
            color: gold,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndPrice(CartItem item) {
    final cart = CartService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF333333),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: cart.loading
                    ? null
                    : () async {
                        await cart.decreaseQuantity(item.id);
                      },
                icon: const Icon(
                  Icons.remove,
                  size: 15,
                ),
                color: Colors.white,
              ),
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: cart.loading ||
                        item.quantity >= item.stock
                    ? null
                    : () async {
                        await cart.increaseQuantity(item.id);
                      },
                icon: const Icon(
                  Icons.add,
                  size: 15,
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _formatPrice(
            item.totalPrice,
            item.currency,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(CartItem item) {
    final cart = CartService.instance;

    return IconButton(
      onPressed: cart.loading
          ? null
          : () async {
              await cart.removeItem(item.id);
            },
      icon: const Icon(
        Icons.close,
        size: 18,
      ),
      color: const Color(0xFF777777),
      tooltip: 'Remove',
    );
  }

  Widget _buildSummary(BuildContext context) {
    final cart = CartService.instance;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 28),
          _buildSummaryRow(
            'ITEMS',
            '${cart.itemCount}',
          ),
          const SizedBox(height: 18),
          _buildSummaryRow(
            'SUBTOTAL',
            _formatPrice(
              cart.subtotal,
              cart.currency,
            ),
          ),
          const SizedBox(height: 18),
          _buildSummaryRow(
            'DELIVERY',
            'CALCULATED AT CHECKOUT',
          ),
          const SizedBox(height: 25),
          Container(
            height: 1,
            color: border,
          ),
          const SizedBox(height: 25),
          _buildSummaryRow(
            'TOTAL',
            _formatPrice(
              cart.subtotal,
              cart.currency,
            ),
            highlight: true,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: cart.isEmpty || cart.loading
                  ? null
                  : () {
                      context.push('/checkout');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    const Color(0xFF222222),
                disabledForegroundColor:
                    const Color(0xFF666666),
                elevation: 0,
                shape: const RoundedRectangleBorder(),
              ),
              child: cart.loading
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
                  : const Text(
                      'PROCEED TO CHECKOUT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Secure checkout • Luxury delivery',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlight
                ? Colors.white
                : const Color(0xFF777777),
            fontSize: highlight ? 12 : 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlight ? gold : Colors.white,
            fontSize: highlight ? 17 : 11,
            fontWeight: highlight
                ? FontWeight.w500
                : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _showClearCartDialog(
    BuildContext context,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Clear your bag?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'All items will be removed from your bag.',
            style: TextStyle(
              color: Color(0xFF999999),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  color: gold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await CartService.instance.clear();
    }
  }
}