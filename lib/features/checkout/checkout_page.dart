import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_assets.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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
  // DELIVERY
  // ==========================================================

  // Fallback only.
  // The real value comes from the Worker.
  static const int _fallbackDeliveryFee = 250;

  int _deliveryFee = _fallbackDeliveryFee;

  bool _loadingDeliveryFee = true;

  // ==========================================================
  // EASYPAISA
  // ==========================================================

  static const String easypaisaAccountName =
      'SHANO SHAN FRAGRANCE';

  static const String easypaisaAccountNumber =
      '03XX-XXXXXXX';

  static const String easypaisaQrImage = '';

  // ==========================================================
  // FORM
  // ==========================================================

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _addressController = TextEditingController();

  final _cityController = TextEditingController();

  final _provinceController = TextEditingController();

  final _postalCodeController = TextEditingController();

  final _transactionController = TextEditingController();

  // ==========================================================
  // STATE
  // ==========================================================

  String _paymentMethod = 'cod';

  bool _placingOrder = false;

  bool _loadingSavedDetails = true;

  // ==========================================================
  // BUY NOW STATE
  // ==========================================================

  bool _isBuyNow = false;

  bool _preparingBuyNow = false;

  bool _buyNowReady = false;

  Map<String, dynamic>? _buyNowProduct;

  int _buyNowQuantity = 1;

  String? _buyNowCartId;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _restoreCheckoutDetails();

    _loadDeliveryFee();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_buyNowProduct == null && !_isBuyNow) {
      final extra = GoRouterState.of(context).extra;

      if (extra is Map) {
        final buyNow = extra['buy_now'] == true;

        final rawProduct = extra['product'];

        if (buyNow && rawProduct is Map) {
          _isBuyNow = true;

          _buyNowProduct = Map<String, dynamic>.from(
            rawProduct,
          );

          _buyNowQuantity = _toInt(
            extra['quantity'],
          );

          if (_buyNowQuantity <= 0) {
            _buyNowQuantity = 1;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _prepareBuyNowCheckout();
          });
        }
      }
    }
  }

  // ==========================================================
  // LOAD DELIVERY FEE
  // ==========================================================

  Future<void> _loadDeliveryFee() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/api/settings/checkout',
        ),
        headers: const {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'DELIVERY SETTINGS RESPONSE: ${response.statusCode}',
      );

      debugPrint(
        'DELIVERY SETTINGS BODY: ${response.body}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          final data = Map<String, dynamic>.from(
            decoded,
          );

          final settings = data['settings'];

          if (settings is Map) {
            final parsedFee = _toInt(
              settings['delivery_fee'],
            );

            if (parsedFee >= 0) {
              if (mounted) {
                setState(() {
                  _deliveryFee = parsedFee;
                });
              }

              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint(
        'DELIVERY FEE LOAD ERROR: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingDeliveryFee = false;
        });
      }
    }
  }

  // ==========================================================
  // RESTORE DETAILS
  // ==========================================================

  Future<void> _restoreCheckoutDetails() async {
    try {
      final details =
          await OrderService.instance.loadCheckoutDetails();

      if (details != null) {
        _nameController.text =
            details['name']?.toString() ?? '';

        _phoneController.text =
            details['phone']?.toString() ?? '';

        _emailController.text =
            details['email']?.toString() ?? '';

        _addressController.text =
            details['address']?.toString() ?? '';

        _cityController.text =
            details['city']?.toString() ?? '';

        _provinceController.text =
            details['province']?.toString() ?? '';

        _postalCodeController.text =
            details['postal_code']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint(
        'Saved checkout details error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingSavedDetails = false;
        });
      }
    }
  }

  // ==========================================================
  // BUY NOW PREPARATION
  // ==========================================================

  Future<void> _prepareBuyNowCheckout() async {
    if (!_isBuyNow ||
        _buyNowProduct == null ||
        _preparingBuyNow ||
        _buyNowReady) {
      return;
    }

    setState(() {
      _preparingBuyNow = true;
    });

    try {
      final product = _buyNowProduct!;

      final productId =
          product['id']?.toString() ?? '';

      if (productId.isEmpty) {
        throw Exception(
          'Product ID is missing.',
        );
      }

      final stock = _toInt(
        product['stock'],
      );

      if (stock <= 0) {
        throw Exception(
          'This fragrance is out of stock.',
        );
      }

      if (_buyNowQuantity > stock) {
        throw Exception(
          'Not enough stock available.',
        );
      }

      // --------------------------------------------------------
      // Create completely separate guest cart ID.
      // --------------------------------------------------------

      final temporaryCartId =
          _generateCartId();

      debugPrint(
        'BUY NOW TEMP CART: $temporaryCartId',
      );

      final response = await http.post(
        Uri.parse(
          '$_apiBaseUrl/api/cart/items',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Cart-ID': temporaryCartId,
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': _buyNowQuantity,
        }),
      );

      debugPrint(
        'BUY NOW CART RESPONSE: ${response.statusCode}',
      );

      debugPrint(
        'BUY NOW CART BODY: ${response.body}',
      );

      Map<String, dynamic>? data;

      try {
        final decoded =
            jsonDecode(response.body);

        if (decoded is Map) {
          data =
              Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {}

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data?['error']?.toString() ??
              data?['message']?.toString() ??
              'Could not prepare your order.',
        );
      }

      // --------------------------------------------------------
      // Prefer server-returned cart ID.
      // --------------------------------------------------------

      final returnedCartId =
          data?['cart_id']?.toString();

      _buyNowCartId =
          returnedCartId != null &&
                  returnedCartId.isNotEmpty
              ? returnedCartId
              : temporaryCartId;

      if (!mounted) {
        return;
      }

      setState(() {
        _buyNowReady = true;
      });
    } catch (e) {
      debugPrint(
        'BUY NOW PREPARATION ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _buyNowReady = false;
      });

      _showError(
        _cleanError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _preparingBuyNow = false;
        });
      }
    }
  }

  // ==========================================================
  // TEMP CART ID
  // ==========================================================

  String _generateCartId() {
    final random = Random();

    String hex(int length) {
      const chars =
          '0123456789abcdef';

      return List.generate(
        length,
        (_) => chars[
            random.nextInt(
              chars.length,
            )
          ],
      ).join();
    }

    return '${hex(8)}-${hex(4)}-4${hex(3)}-'
        '${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-'
        '${hex(12)}';
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _transactionController.dispose();

    super.dispose();
  }

  // ==========================================================
  // INTEGER
  // ==========================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        double.tryParse(
              value.toString(),
            )?.round() ??
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
              RegExp(
                r'\B(?=(\d{3})+(?!\d))',
              ),
              (_) => ',',
            );

    return '$currency $formatted';
  }

  // ==========================================================
  // BUY NOW SUBTOTAL
  // ==========================================================

  int get _buyNowSubtotal {
    if (_buyNowProduct == null) {
      return 0;
    }

    return _toInt(
          _buyNowProduct!['price'],
        ) *
        _buyNowQuantity;
  }

  

  // ==========================================================
  // BUY NOW TOTAL
  // ==========================================================

  int get _buyNowTotal {
    return _buyNowSubtotal + _deliveryFee;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    // --------------------------------------------------------
    // BUY NOW preparation.
    // --------------------------------------------------------

    if (_isBuyNow &&
        (!_buyNowReady ||
            _preparingBuyNow)) {
      return Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: gold,
                  strokeWidth: 2,
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  'PREPARING YOUR ORDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Please wait...',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation:
              CartService.instance,
          builder: (
            context,
            _,
          ) {
            // ==================================================
            // BUY NOW MODE
            // ==================================================

            if (_isBuyNow) {
              return _buildBuyNowCheckout(
                context,
              );
            }

            // ==================================================
            // NORMAL CART MODE
            // ==================================================

            final cart =
                CartService.instance;

            if (cart.isEmpty) {
              return _buildEmptyCheckout(
                context,
              );
            }

            return _buildNormalCheckout(
              context,
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // NORMAL CHECKOUT
  // ==========================================================

  Widget _buildNormalCheckout(
    BuildContext context,
  ) {
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
          padding:
              EdgeInsets.symmetric(
            horizontal:
                desktop ? 70 : 22,
            vertical:
                desktop ? 45 : 25,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 45),

              if (_loadingSavedDetails ||
                  _loadingDeliveryFee)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 20,
                  ),
                  child:
                      LinearProgressIndicator(
                    minHeight: 1,
                    color: gold,
                    backgroundColor:
                        border,
                  ),
                ),

              if (desktop)
                _buildDesktopLayout(
                  context,
                )
              else
                _buildMobileLayout(
                  context,
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUY NOW CHECKOUT
  // ==========================================================

  Widget _buildBuyNowCheckout(
    BuildContext context,
  ) {
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
          padding:
              EdgeInsets.symmetric(
            horizontal:
                desktop ? 70 : 22,
            vertical:
                desktop ? 45 : 25,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 45),

              if (_loadingSavedDetails ||
                  _loadingDeliveryFee)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 20,
                  ),
                  child:
                      LinearProgressIndicator(
                    minHeight: 1,
                    color: gold,
                    backgroundColor:
                        border,
                  ),
                ),

              if (desktop)
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child:
                          _buildCheckoutForm(
                        context,
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    SizedBox(
                      width: 390,
                      child:
                          _buildBuyNowSummary(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildCheckoutForm(
                      context,
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    _buildBuyNowSummary(),
                  ],
                ),
            ],
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
              context.go('/cart');
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
        Text(
          _isBuyNow
              ? 'BUY NOW'
              : 'CHECKOUT',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _buildDesktopLayout(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child:
              _buildCheckoutForm(context),
        ),
        const SizedBox(width: 50),
        SizedBox(
          width: 390,
          child:
              _buildOrderSummary(),
        ),
      ],
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

  Widget _buildMobileLayout(
    BuildContext context,
  ) {
    return Column(
      children: [
        _buildCheckoutForm(context),
        const SizedBox(height: 35),
        _buildOrderSummary(),
      ],
    );
  }

  // ==========================================================
  // CHECKOUT FORM
  // ==========================================================

  Widget _buildCheckoutForm(
    BuildContext context,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            '01',
            'CONTACT INFORMATION',
          ),
          const SizedBox(height: 20),

          _buildField(
            controller:
                _nameController,
            label: 'FULL NAME',
            hint: 'Your full name',
            icon:
                Icons.person_outline,
            validator:
                _required(
              'Please enter your name',
            ),
          ),

          const SizedBox(height: 15),

          _buildField(
            controller:
                _phoneController,
            label: 'PHONE NUMBER',
            hint: '03XX-XXXXXXX',
            icon:
                Icons.phone_outlined,
            keyboardType:
                TextInputType.phone,
            validator:
                _required(
              'Please enter your phone number',
            ),
          ),

          const SizedBox(height: 15),

          _buildField(
            controller:
                _emailController,
            label: 'EMAIL ADDRESS',
            hint: 'your@email.com',
            icon:
                Icons.email_outlined,
            keyboardType:
                TextInputType.emailAddress,
          ),

          const SizedBox(height: 45),

          _buildSectionTitle(
            '02',
            'DELIVERY ADDRESS',
          ),

          const SizedBox(height: 20),

          _buildField(
            controller:
                _addressController,
            label: 'STREET ADDRESS',
            hint:
                'House number, street, area',
            icon:
                Icons.location_on_outlined,
            maxLines: 2,
            validator:
                _required(
              'Please enter your delivery address',
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller:
                      _cityController,
                  label: 'CITY',
                  hint: 'City',
                  icon:
                      Icons.location_city_outlined,
                  validator:
                      _required(
                    'Required',
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildField(
                  controller:
                      _provinceController,
                  label: 'PROVINCE',
                  hint: 'Province',
                  icon:
                      Icons.map_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _buildField(
            controller:
                _postalCodeController,
            label: 'POSTAL CODE',
            hint: 'Optional',
            icon:
                Icons.markunread_mailbox_outlined,
            keyboardType:
                TextInputType.number,
          ),

          const SizedBox(height: 45),

          _buildSectionTitle(
            '03',
            'PAYMENT METHOD',
          ),

          const SizedBox(height: 20),

          _buildPaymentSelector(),

          const SizedBox(height: 20),

          if (_paymentMethod == 'online')
            _buildOnlinePaymentDetails(),

          const SizedBox(height: 35),

          _buildPlaceOrderButton(context),
        ],
      ),
    );
  }

  // ==========================================================
  // VALIDATOR
  // ==========================================================

  String? Function(String?) _required(
    String message,
  ) {
    return (value) {
      if (value == null ||
          value.trim().isEmpty) {
        return message;
      }

      return null;
    };
  }

  // ==========================================================
  // FIELD
  // ==========================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 9,
            fontWeight:
                FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType:
              keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          cursorColor: gold,
          decoration:
              InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(
              color:
                  Color(0xFF555555),
              fontSize: 12,
            ),
            prefixIcon: Icon(
              icon,
              color:
                  const Color(0xFF666666),
              size: 19,
            ),
            filled: true,
            fillColor: panel,
            enabledBorder:
                const OutlineInputBorder(
              borderSide:
                  BorderSide(
                color: border,
              ),
            ),
            focusedBorder:
                const OutlineInputBorder(
              borderSide:
                  BorderSide(
                color: gold,
              ),
            ),
            errorBorder:
                const OutlineInputBorder(
              borderSide:
                  BorderSide(
                color:
                    Color(0xFF773333),
              ),
            ),
            focusedErrorBorder:
                const OutlineInputBorder(
              borderSide:
                  BorderSide(
                color:
                    Color(0xFFAA5555),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _buildSectionTitle(
    String number,
    String title,
  ) {
    return Row(
      children: [
        Text(
          number,
          style:
              const TextStyle(
            color: gold,
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PAYMENT SELECTOR
  // ==========================================================

  Widget _buildPaymentSelector() {
    return Column(
      children: [
        _buildPaymentOption(
          value: 'cod',
          title:
              'CASH ON DELIVERY',
          subtitle:
              'Pay when your fragrance arrives',
          icon:
              Icons.local_shipping_outlined,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: 'online',
          title:
              'ONLINE PAYMENT',
          subtitle:
              'Pay through Easypaisa',
          icon:
              Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected =
        _paymentMethod == value;

    return InkWell(
      onTap: _placingOrder
          ? null
          : () {
              setState(() {
                _paymentMethod = value;
              });
            },
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(
                  0xFF14120C,
                )
              : panel,
          border:
              Border.all(
            color:
                selected
                    ? gold
                    : border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  selected
                      ? gold
                      : muted,
              size: 25,
            ),
            const SizedBox(width: 17),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFFCCCCCC,
                            ),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color: selected
                      ? gold
                      : const Color(
                          0xFF555555,
                        ),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child:
                          Container(
                        width: 10,
                        height: 10,
                        decoration:
                            const BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: gold,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ONLINE PAYMENT
  // ==========================================================

  Widget _buildOnlinePaymentDetails() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF0A0A0A),
        border:
            Border.all(
          color:
              const Color(0xFF302A18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .account_balance_wallet_outlined,
                color: gold,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'EASYPAISA PAYMENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'SEND YOUR PAYMENT TO',
            style: TextStyle(
              color: muted,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(18),
            color: panel,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACCOUNT NAME',
                  style: TextStyle(
                    color:
                        Color(0xFF666666),
                    fontSize: 8,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  easypaisaAccountName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'EASYPAISA NUMBER',
                  style: TextStyle(
                    color:
                        Color(0xFF666666),
                    fontSize: 8,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  easypaisaAccountNumber,
                  style: TextStyle(
                    color: gold,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (easypaisaQrImage.isNotEmpty)
            Center(
              child: Container(
                width: 220,
                height: 220,
                padding:
                    const EdgeInsets.all(15),
                color: Colors.white,
                child: Image.network(
                  easypaisaQrImage,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (
                    _,
                    _,
                    _,
                  ) =>
                          const Icon(
                    Icons.qr_code_2,
                    color: Colors.black,
                    size: 150,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 190,
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFF111111),
                border:
                    Border.all(
                  color:
                      const Color(0xFF292929),
                ),
              ),
              child:
                  const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    color:
                        Color(0xFF555555),
                    size: 80,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'PAYMENT QR CODE',
                    style: TextStyle(
                      color:
                          Color(0xFF555555),
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Payment QR will be available here',
                    style: TextStyle(
                      color:
                          Color(0xFF444444),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 22),

          const Text(
            'After making the payment, enter your transaction/reference number below.',
            style: TextStyle(
              color:
                  Color(0xFF888888),
              fontSize: 11,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 15),

          _buildField(
            controller:
                _transactionController,
            label:
                'TRANSACTION / REFERENCE NUMBER',
            hint:
                'Enter payment reference',
            icon:
                Icons.receipt_long_outlined,
            validator:
                _paymentMethod ==
                        'online'
                    ? _required(
                        'Please enter your payment reference',
                      )
                    : null,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NORMAL ORDER SUMMARY
  // ==========================================================

  Widget _buildOrderSummary() {
    final cart =
        CartService.instance;

    final subtotal =
        cart.subtotal;

    final total =
        subtotal + _deliveryFee;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(28),
      decoration:
          BoxDecoration(
        color: panel,
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ORDER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 25),

          for (
            int i = 0;
            i < cart.items.length;
            i++
          ) ...[
            _buildOrderItem(
              cart.items[i],
            ),
            if (i <
                cart.items.length - 1)
              const SizedBox(
                height: 18,
              ),
          ],

          const SizedBox(height: 25),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 25),

          _buildSummaryRow(
            'ITEMS',
            '${cart.itemCount}',
          ),

          const SizedBox(height: 15),

          _buildSummaryRow(
            'SUBTOTAL',
            _formatPrice(
              subtotal,
              cart.currency,
            ),
          ),

          const SizedBox(height: 15),

          _buildSummaryRow(
            'DELIVERY',
            _deliveryFee == 0
                ? 'FREE'
                : _formatPrice(
                    _deliveryFee,
                    cart.currency,
                  ),
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
              total,
              cart.currency,
            ),
            highlight: true,
          ),

          if (_loadingDeliveryFee)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 12,
              ),
              child: Text(
                'Updating delivery charge...',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUY NOW SUMMARY
  // ==========================================================

  Widget _buildBuyNowSummary() {
    final product =
        _buyNowProduct!;

    final name =
        product['name']?.toString() ??
            'Fragrance';

    final imageUrl =
        product['image_url']?.toString() ??
            '';

    final currency =
        product['currency']?.toString() ??
            'PKR';

    final subtotal =
        _buyNowSubtotal;

    final total =
        _buyNowTotal;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(28),
      decoration:
          BoxDecoration(
        color: panel,
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ORDER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Container(
                width: 60,
                height: 70,
                color:
                    const Color(0xFF111111),
                child:
                    _buildBuyNowImage(
                  imageUrl,
                  name,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'QTY $_buyNowQuantity',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF666666),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _formatPrice(
                  subtotal,
                  currency,
                ),
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 25),

          _buildSummaryRow(
            'ITEMS',
            '$_buyNowQuantity',
          ),

          const SizedBox(height: 15),

          _buildSummaryRow(
            'SUBTOTAL',
            _formatPrice(
              subtotal,
              currency,
            ),
          ),

          const SizedBox(height: 15),

          _buildSummaryRow(
            'DELIVERY',
            _deliveryFee == 0
                ? 'FREE'
                : _formatPrice(
                    _deliveryFee,
                    currency,
                  ),
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
              total,
              currency,
            ),
            highlight: true,
          ),

          if (_loadingDeliveryFee)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 12,
              ),
              child: Text(
                'Updating delivery charge...',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // NORMAL ITEM
  // ==========================================================

  Widget _buildOrderItem(
    CartItem item,
  ) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 70,
          color:
              const Color(0xFF111111),
          child:
              _buildItemImage(item),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'QTY ${item.quantity}',
                style:
                    const TextStyle(
                  color:
                      Color(0xFF666666),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        Text(
          _formatPrice(
            item.totalPrice,
            item.currency,
          ),
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUY NOW IMAGE
  // ==========================================================

  Widget _buildBuyNowImage(
    String imageUrl,
    String name,
  ) {
    var image =
        imageUrl;

    if (image.isEmpty &&
        name.toLowerCase() ==
            'champions') {
      image =
          AppAssets.championsReference;
    }

    if (image.isEmpty) {
      return const Icon(
        Icons
            .image_not_supported_outlined,
        color:
            Color(0xFF555555),
      );
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder:
            (
          _,
          _,
          _,
        ) =>
                const Icon(
          Icons
              .broken_image_outlined,
          color:
              Color(0xFF555555),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder:
          (
        _,
        _,
        _,
      ) =>
              const Icon(
        Icons
            .broken_image_outlined,
        color:
            Color(0xFF555555),
      ),
    );
  }

  // ==========================================================
  // NORMAL ITEM IMAGE
  // ==========================================================

  Widget _buildItemImage(
    CartItem item,
  ) {
    var imageUrl =
        item.imageUrl;

    if (imageUrl.isEmpty &&
        item.name.toLowerCase() ==
            'champions') {
      imageUrl =
          AppAssets.championsReference;
    }

    if (imageUrl.isEmpty) {
      return const Icon(
        Icons
            .image_not_supported_outlined,
        color:
            Color(0xFF555555),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (
          _,
          _,
          _,
        ) =>
                const Icon(
          Icons
              .broken_image_outlined,
          color:
              Color(0xFF555555),
        ),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder:
          (
        _,
        _,
        _,
      ) =>
              const Icon(
        Icons
            .broken_image_outlined,
        color:
            Color(0xFF555555),
      ),
    );
  }

  // ==========================================================
  // SUMMARY ROW
  // ==========================================================

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
                : const Color(
                    0xFF777777,
                  ),
            fontSize:
                highlight ? 12 : 10,
            fontWeight:
                FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlight
                ? gold
                : Colors.white,
            fontSize:
                highlight ? 17 : 11,
            fontWeight: highlight
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PLACE ORDER BUTTON
  // ==========================================================

  Widget _buildPlaceOrderButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed:
            _placingOrder
                ? null
                : () =>
                    _placeOrder(
                      context,
                    ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor:
              Colors.black,
          disabledBackgroundColor:
              const Color(0xFF292929),
          elevation: 0,
          shape:
              const RoundedRectangleBorder(),
        ),
        child:
            _placingOrder
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        Colors.black,
                      ),
                    ),
                  )
                : const Text(
                    'PLACE ORDER',
                    style:
                        TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER
  // ==========================================================

  Future<void> _placeOrder(
    BuildContext context,
  ) async {
    if (_placingOrder) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? cartId;

    // ========================================================
    // BUY NOW
    // ========================================================

    if (_isBuyNow) {
      if (!_buyNowReady ||
          _buyNowCartId == null ||
          _buyNowCartId!.trim().isEmpty) {
        _showError(
          'Your order is still being prepared. Please try again.',
        );
        return;
      }

      cartId =
          _buyNowCartId;
    }

    // ========================================================
    // NORMAL CART
    // ========================================================

    else {
      final cart =
          CartService.instance;

      if (cart.isEmpty) {
        _showError(
          'Your bag is empty.',
        );
        return;
      }

      if (cart.cartId == null ||
          cart.cartId!.trim().isEmpty) {
        final loaded =
            await cart.loadCart();

        if (!loaded ||
            cart.cartId == null ||
            cart.cartId!
                .trim()
                .isEmpty) {
          _showError(
            'Could not identify your shopping bag. Please try again.',
          );
          return;
        }
      }

      cartId =
          cart.cartId;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      final phone =
          _phoneController.text.trim();

      final uri = Uri.parse(
        '$_apiBaseUrl/api/orders',
      );

      debugPrint(
        'ORDER POST: $uri',
      );

      final response =
          await http.post(
        uri,
        headers: {
          'Content-Type':
              'application/json',
          'Accept':
              'application/json',
          'X-Cart-ID':
              cartId!,
        },
        body: jsonEncode({
          'customer_name':
              _nameController.text.trim(),
          'email':
              _emailController.text.trim(),
          'phone':
              phone,
          'address':
              _addressController.text.trim(),
          'city':
              _cityController.text.trim(),
          'province':
              _provinceController.text.trim(),
          'postal_code':
              _postalCodeController.text.trim(),
          'payment_method':
              _paymentMethod,
          'transaction_reference':
              _paymentMethod ==
                      'online'
                  ? _transactionController
                      .text
                      .trim()
                  : '',
        }),
      );

      debugPrint(
        'ORDER RESPONSE: ${response.statusCode}',
      );

      debugPrint(
        'ORDER BODY: ${response.body}',
      );

      Map<String, dynamic>? data;

      try {
        final decoded =
            jsonDecode(response.body);

        if (decoded is Map) {
          data =
              Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {}

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data?['error']?.toString() ??
              data?['message']?.toString() ??
              'Unable to place your order. Please try again.',
        );
      }

      if (data == null ||
          data['success'] != true) {
        throw Exception(
          data?['error']?.toString() ??
              data?['message']?.toString() ??
              'The order could not be completed.',
        );
      }

      final rawOrder =
          data['order'];

      if (rawOrder is! Map) {
        throw Exception(
          'The server returned an invalid order response.',
        );
      }

      final order =
          Map<String, dynamic>.from(
        rawOrder,
      );

      final orderNumber =
          order['order_number']
                  ?.toString() ??
              '';

      if (orderNumber.isEmpty) {
        throw Exception(
          'The order was created, but no order number was returned.',
        );
      }

      // ======================================================
      // SERVER-CALCULATED BILL
      // ======================================================
      //
      // The Worker is authoritative here.
      // We do not send delivery_fee from Flutter.
      //

      final serverDeliveryFee =
          _toInt(
        order['delivery_fee'],
      );

      final serverSubtotal =
          _toInt(
        order['subtotal'],
      );

      final serverTotal =
          _toInt(
        order['total'],
      );

      debugPrint(
        'SERVER SUBTOTAL: $serverSubtotal',
      );

      debugPrint(
        'SERVER DELIVERY FEE: $serverDeliveryFee',
      );

      debugPrint(
        'SERVER TOTAL: $serverTotal',
      );

      // ======================================================
      // SAVE DETAILS
      // ======================================================

      await OrderService.instance
          .saveCheckoutDetails(
        name:
            _nameController.text.trim(),
        phone:
            phone,
        email:
            _emailController.text.trim(),
        address:
            _addressController.text.trim(),
        city:
            _cityController.text.trim(),
        province:
            _provinceController.text.trim(),
        postalCode:
            _postalCodeController.text.trim(),
      );

      // ======================================================
      // SAVE ORDER REFERENCE
      // ======================================================

      await OrderService.instance
          .saveOrderReference(
        orderNumber:
            orderNumber,
        phone:
            phone,
      );

      // ======================================================
      // NORMAL CART REFRESH
      // ======================================================

      if (!_isBuyNow) {
        await CartService.instance
            .loadCart();
      }

      if (!mounted) {
        return;
      }

      // ======================================================
      // CONFIRMATION
      // ======================================================

      context.push(
        '/order-confirmation',
        extra: {
          'order': order,
          'phone': phone,
        },
      );
    } catch (e) {
      debugPrint(
        'ORDER ERROR: $e',
      );

      if (mounted) {
        _showError(
          OrderService.instance
              .cleanError(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(
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
              color:
                  Colors.white,
            ),
          ),
          backgroundColor:
              const Color(0xFF381919),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(
            seconds: 4,
          ),
        ),
      );
  }

  // ==========================================================
  // CLEAN ERROR
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

  // ==========================================================
  // EMPTY CHECKOUT
  // ==========================================================

  Widget _buildEmptyCheckout(
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
            const Icon(
              Icons
                  .shopping_bag_outlined,
              color:
                  Color(0xFF555555),
              size: 65,
            ),

            const SizedBox(
              height: 25,
            ),

            const Text(
              'YOUR BAG IS EMPTY',
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize: 19,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            ElevatedButton(
              onPressed: () =>
                  context.go(
                '/shop',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    gold,
                foregroundColor:
                    Colors.black,
                elevation: 0,
              ),
              child:
                  const Text(
                'EXPLORE FRAGRANCES',
              ),
            ),
          ],
        ),
      ),
    );
  }
}