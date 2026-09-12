
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/order_service.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final TextEditingController _orderNumberController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  bool _loading = false;

  Map<String, dynamic>? _order;

  String? _error;

  @override
  void dispose() {
    _orderNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // TRACK ORDER
  // ============================================================

  Future<void> _trackOrder() async {
    FocusScope.of(context).unfocus();

    final orderNumber =
        _orderNumberController.text.trim().toUpperCase();

    final phone = _phoneController.text.trim();

    if (orderNumber.isEmpty) {
      setState(() {
        _error = 'Please enter your order number.';
        _order = null;
      });
      return;
    }

    if (phone.isEmpty) {
      setState(() {
        _error =
            'Please enter the phone number used for your order.';
        _order = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _order = null;
    });

    try {
      final result = await OrderService.instance.trackOrder(
        orderNumber: orderNumber,
        phone: phone,
      );

      if (!mounted) return;

      setState(() {
        _order = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = OrderService.instance.cleanError(error);
        _order = null;
      });
    }
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

    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  int _numberValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatMoney(
    dynamic value,
    String currency,
  ) {
    final amount = _numberValue(value);

    return '$currency ${amount.toString()}';
  }

  String _formatDate(dynamic value) {
    final raw = _stringValue(value);

    if (raw.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(raw).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year • $hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Placed';

      case 'confirmed':
        return 'Confirmed';

      case 'processing':
        return 'Processing';

      case 'shipped':
        return 'Shipped';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      default:
        if (status.isEmpty) {
          return 'Order Placed';
        }

        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) {
                if (word.isEmpty) {
                  return word;
                }

                return '${word[0].toUpperCase()}'
                    '${word.substring(1)}';
              },
            )
            .join(' ');
    }
  }

  int _statusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;

      case 'confirmed':
        return 1;

      case 'processing':
        return 2;

      case 'shipped':
        return 3;

      case 'delivered':
        return 4;

      case 'cancelled':
        return -1;

      default:
        return 0;
    }
  }

  IconData _statusIcon(int index) {
    switch (index) {
      case 0:
        return Icons.receipt_long_outlined;

      case 1:
        return Icons.verified_outlined;

      case 2:
        return Icons.inventory_2_outlined;

      case 3:
        return Icons.local_shipping_outlined;

      case 4:
        return Icons.check_circle_outline;

      default:
        return Icons.circle_outlined;
    }
  }

  Widget _goldLine() {
    return Container(
      height: 1,
      width: 70,
      color: const Color(0xFFC9A45C),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Color(0xFFC9A45C),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.30),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFC9A45C),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.035),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          ),
          borderSide: BorderSide(
            color: Color(0xFFC9A45C),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH SECTION
  // ============================================================

  Widget _buildSearchSection(double width) {
    final compact = width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 60,
        vertical: compact ? 42 : 64,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.018),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: Column(
            children: [
              _goldLine(),

              const SizedBox(height: 22),

              const Text(
                'TRACK YOUR ORDER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC9A45C),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Follow your SHANO SHAN fragrance journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: compact ? 27 : 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Enter your order number and the phone number used at checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 14,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 34),

              _field(
                controller: _orderNumberController,
                label: 'Order Number',
                hint: 'SS-20260911-A7F2',
                icon: Icons.receipt_long_outlined,
              ),

              const SizedBox(height: 14),

              _field(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Phone number used at checkout',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _trackOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFC9A45C),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        const Color(0xFF8C7444),
                    disabledForegroundColor:
                        Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(3),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'TRACK ORDER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        Colors.red.withValues(alpha: 0.07),
                    border: Border.all(
                      color:
                          Colors.red.withValues(alpha: 0.25),
                    ),
                    borderRadius:
                        BorderRadius.circular(3),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDER RESULT
  // ============================================================

  Widget _buildOrderResult(double width) {
    if (_order == null) {
      return const SizedBox.shrink();
    }

    final order = _order!;

    final orderNumber =
        _stringValue(order['order_number']);

    final status = _stringValue(
      order['order_status'],
      fallback: 'pending',
    );

    final paymentStatus = _stringValue(
      order['payment_status'],
      fallback: 'pending',
    );

    final currency = _stringValue(
      order['currency'],
      fallback: 'PKR',
    );

    final List<Map<String, dynamic>> items = [];

    final rawItems = order['items'];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(
            Map<String, dynamic>.from(item),
          );
        }
      }
    }

    final currentStep = _statusStep(status);

    final cancelled =
        status.toLowerCase() == 'cancelled';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width < 700 ? 22 : 60,
        vertical: 52,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(
                orderNumber,
                status,
                paymentStatus,
                currency,
                order,
              ),

              const SizedBox(height: 28),

              _buildStatusCard(
                currentStep: currentStep,
                cancelled: cancelled,
                status: status,
              ),

              const SizedBox(height: 28),

              _buildItemsCard(
                order: order,
                items: items,
                currency: currency,
              ),

              const SizedBox(height: 28),

              _buildDeliveryCard(order),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDER HEADER
  // ============================================================

  Widget _buildOrderHeader(
    String orderNumber,
    String status,
    String paymentStatus,
    String currency,
    Map<String, dynamic> order,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        color: Colors.white.withValues(alpha: 0.018),
      ),
      child: Wrap(
        spacing: 30,
        runSpacing: 22,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                orderNumber,
                style: const TextStyle(
                  color: Color(0xFFC9A45C),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _formatDate(order['created_at']),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _formatMoney(
                  order['total'],
                  currency,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Payment: ${_statusLabel(paymentStatus)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          _statusBadge(status),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final cancelled =
        status.toLowerCase() == 'cancelled';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: cancelled
            ? Colors.red.withValues(alpha: 0.08)
            : const Color(0xFFC9A45C)
                .withValues(alpha: 0.09),
        border: Border.all(
          color: cancelled
              ? Colors.red.withValues(alpha: 0.35)
              : const Color(0xFFC9A45C)
                  .withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        _statusLabel(status).toUpperCase(),
        style: TextStyle(
          color: cancelled
              ? Colors.redAccent
              : const Color(0xFFC9A45C),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard({
    required int currentStep,
    required bool cancelled,
    required String status,
  }) {
    const steps = [
      'Order Placed',
      'Confirmed',
      'Processing',
      'Shipped',
      'Delivered',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        color: Colors.white.withValues(alpha: 0.018),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER STATUS',
            style: TextStyle(
              color: Color(0xFFC9A45C),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 26),

          if (cancelled)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This order has been cancelled.',
                      style: TextStyle(
                        color:
                            Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              steps.length,
              (index) {
                final completed =
                    index <= currentStep;

                final active =
                    index == currentStep;

                return _statusRow(
                  label: steps[index],
                  index: index,
                  completed: completed,
                  active: active,
                  isLast:
                      index == steps.length - 1,
                );
              },
            ),

          if (!cancelled) ...[
            const SizedBox(height: 8),
            Text(
              'Current status: ${_statusLabel(status)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STATUS ROW
  // ============================================================

  Widget _statusRow({
    required String label,
    required int index,
    required bool completed,
    required bool active,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? const Color(0xFFC9A45C)
                    : Colors.transparent,
                border: Border.all(
                  color: completed
                      ? const Color(0xFFC9A45C)
                      : Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Icon(
                _statusIcon(index),
                size: 17,
                color: completed
                    ? Colors.black
                    : Colors.white.withValues(alpha: 0.30),
              ),
            ),

            if (!isLast)
              Container(
                width: 1,
                height: 35,
                color: completed
                    ? const Color(0xFFC9A45C)
                    : Colors.white.withValues(alpha: 0.10),
              ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 9,
              bottom: 25,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : completed
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.white.withValues(alpha: 0.30),
                fontSize: 14,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ITEMS CARD
  // ============================================================

  Widget _buildItemsCard({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> items,
    required String currency,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        color: Colors.white.withValues(alpha: 0.018),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR FRAGRANCES',
            style: TextStyle(
              color: Color(0xFFC9A45C),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 22),

          if (items.isEmpty)
            Text(
              'No item details available.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            )
          else
            ...items.map(
              (item) => _orderItem(
                item,
                currency,
              ),
            ),

          const Divider(
            height: 35,
            color: Color(0x22FFFFFF),
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color:
                      Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
              Text(
                _formatMoney(
                  order['subtotal'],
                  currency,
                ),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  color:
                      Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
              Text(
                _numberValue(
                          order['delivery_fee'],
                        ) ==
                        0
                    ? 'FREE'
                    : _formatMoney(
                        order['delivery_fee'],
                        currency,
                      ),
                style: const TextStyle(
                  color: Color(0xFFC9A45C),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatMoney(
                  order['total'],
                  currency,
                ),
                style: const TextStyle(
                  color: Color(0xFFC9A45C),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER ITEM
  // ============================================================

  Widget _orderItem(
    Map<String, dynamic> item,
    String currency,
  ) {
    final name = _stringValue(
      item['name'],
      fallback: 'Fragrance',
    );

    final quantity =
        _numberValue(item['quantity']);

    final total = _formatMoney(
      item['total_price'],
      currency,
    );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC9A45C)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.local_florist_outlined,
              color: Color(0xFFC9A45C),
              size: 22,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Quantity: $quantity',
                  style: TextStyle(
                    color:
                        Colors.white.withValues(alpha: 0.40),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            total,
            style: const TextStyle(
              color: Color(0xFFC9A45C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERY CARD
  // ============================================================

  Widget _buildDeliveryCard(
    Map<String, dynamic> order,
  ) {
    final name =
        _stringValue(order['customer_name']);

    final address =
        _stringValue(order['address']);

    final city =
        _stringValue(order['city']);

    final province =
        _stringValue(order['province']);

    final phone =
        _stringValue(order['phone']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        color: Colors.white.withValues(alpha: 0.018),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY DETAILS',
            style: TextStyle(
              color: Color(0xFFC9A45C),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 22),

          if (name.isNotEmpty)
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

          if (address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              address,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],

          if (city.isNotEmpty ||
              province.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              [
                city,
                province,
              ].where(
                (item) => item.isNotEmpty,
              ).join(', '),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ],

          if (phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              phone,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TRACK ANOTHER ORDER
  // ============================================================

  void _resetTracking() {
    setState(() {
      _order = null;
      _error = null;
      _loading = false;
    });

    _orderNumberController.clear();
    _phoneController.clear();

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ==================================================
                  // TOP BAR
                  // ==================================================

                  SizedBox(
                    height: 74,
                    child: Row(
                      children: [
                        const SizedBox(width: 24),

                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white70,
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () =>
                              context.go('/'),
                          child: const Text(
                            'SHANO SHAN',
                            style: TextStyle(
                              color:
                                  Color(0xFFC9A45C),
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(width: 72),
                      ],
                    ),
                  ),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  _buildSearchSection(
                    constraints.maxWidth,
                  ),

                  // ==================================================
                  // RESULT
                  // ==================================================

                  _buildOrderResult(
                    constraints.maxWidth,
                  ),

                  // ==================================================
                  // TRACK ANOTHER
                  // ==================================================

                  if (_order != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        left: 22,
                        right: 22,
                        bottom: 50,
                      ),
                      child: OutlinedButton(
                        onPressed:
                            _resetTracking,
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(
                            0xFFC9A45C,
                          ),
                          side:
                              const BorderSide(
                            color: Color(
                              0xFFC9A45C,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              3,
                            ),
                          ),
                        ),
                        child: const Text(
                          'TRACK ANOTHER ORDER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
