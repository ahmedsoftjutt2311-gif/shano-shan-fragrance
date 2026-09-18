import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/order_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderNumber;

  const OrderDetailsPage({
    super.key,
    required this.orderNumber,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrderService _orderService = OrderService.instance;

  Map<String, dynamic>? _order;

  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    _loadOrder();

    // Refresh the order status every 30 seconds.
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshOrderSilently(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final order = await _orderService.getOrder(
        widget.orderNumber,
      );

      if (!mounted) return;

      setState(() {
        _order = order;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _orderService.cleanError(error);
      });
    }
  }

  Future<void> _refreshOrder() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    try {
      final order = await _orderService.getOrder(
        widget.orderNumber,
      );

      if (!mounted) return;

      setState(() {
        _order = order;
        _error = null;
        _refreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ORDER STATUS UPDATED'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _refreshing = false;
        _error = _orderService.cleanError(error);
      });
    }
  }

  Future<void> _refreshOrderSilently() async {
    if (_loading || _refreshing) return;

    try {
      final order = await _orderService.getOrder(
        widget.orderNumber,
      );

      if (!mounted) return;

      setState(() {
        _order = order;
        _error = null;
      });
    } catch (_) {
      // Silent refresh failure.
      // Keep the currently displayed order.
    }
  }

  String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _money(dynamic value, String currency) {
    final amount = _number(value);

    return '$currency ${amount.toStringAsFixed(0)}';
  }

  String _status(dynamic value) {
    return _string(value)
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'ORDER PLACED';

      case 'confirmed':
        return 'CONFIRMED';

      case 'processing':
        return 'BEING PREPARED';

      case 'shipped':
        return 'SHIPPED';

      case 'delivered':
        return 'DELIVERED';

      case 'cancelled':
      case 'canceled':
        return 'CANCELLED';

      default:
        if (status.isEmpty) {
          return 'ORDER PLACED';
        }

        return status
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.receipt_long_outlined;

      case 'confirmed':
        return Icons.check_circle_outline;

      case 'processing':
        return Icons.inventory_2_outlined;

      case 'shipped':
        return Icons.local_shipping_outlined;

      case 'delivered':
        return Icons.done_all;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;

      default:
        return Icons.receipt_long_outlined;
    }
  }

  DateTime? _parseDate(dynamic value) {
    final text = _string(value);

    if (text.isEmpty) return null;

    return DateTime.tryParse(text)?.toLocal();
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);

    if (date == null) return 'DATE UNAVAILABLE';

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year} • '
        '$hour:$minute $period';
  }

  List<Map<String, dynamic>> _items() {
    final rawItems = _order?['items'];

    if (rawItems is! List) {
      return [];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  bool _statusReached(
    String current,
    String target,
  ) {
    const statuses = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
    ];

    final currentIndex = statuses.indexOf(current);
    final targetIndex = statuses.indexOf(target);

    if (currentIndex < 0 || targetIndex < 0) {
      return false;
    }

    return currentIndex >= targetIndex;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        18,
        22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORDER DETAILS',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.orderNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                _refreshing ? null : _refreshOrder,
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    size: 22,
                  ),
            color: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHero() {
    final order = _order!;

    final status = _status(
      order['order_status'],
    );

    final paymentStatus = _status(
      order['payment_status'],
    );

    final currency =
        _string(order['currency']).isEmpty
            ? 'PKR'
            : _string(order['currency']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFFD4AF37)
              .withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 1.5,
              ),
            ),
            child: Icon(
              _statusIcon(status),
              color: const Color(0xFFD4AF37),
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _statusLabel(status),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order['created_at']),
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  _money(order['total'], currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                paymentStatus == 'paid'
                    ? Icons.verified_outlined
                    : Icons.schedule_outlined,
                size: 15,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(width: 7),
              Text(
                paymentStatus == 'paid'
                    ? 'PAYMENT CONFIRMED'
                    : 'PAYMENT ${paymentStatus.isEmpty ? 'PENDING' : paymentStatus.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final status = _status(
      _order?['order_status'],
    );

    final cancelled =
        status == 'cancelled' ||
        status == 'canceled';

    if (cancelled) {
      return _buildCancelledTimeline();
    }

    const steps = [
      {
        'status': 'pending',
        'title': 'ORDER PLACED',
        'subtitle': 'Your order has been received.',
        'icon': Icons.receipt_long_outlined,
      },
      {
        'status': 'confirmed',
        'title': 'CONFIRMED',
        'subtitle': 'Your order has been confirmed.',
        'icon': Icons.check_circle_outline,
      },
      {
        'status': 'processing',
        'title': 'BEING PREPARED',
        'subtitle': 'Your fragrance is being prepared.',
        'icon': Icons.inventory_2_outlined,
      },
      {
        'status': 'shipped',
        'title': 'SHIPPED',
        'subtitle': 'Your order is on its way.',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'status': 'delivered',
        'title': 'DELIVERED',
        'subtitle': 'Your order has arrived.',
        'icon': Icons.done_all,
      },
    ];

    return _section(
      title: 'TRACK YOUR ORDER',
      child: Column(
        children: List.generate(
          steps.length,
          (index) {
            final step = steps[index];

            final stepStatus =
                step['status'] as String;

            final reached = _statusReached(
              status,
              stepStatus,
            );

            final active =
                status == stepStatus;

            final isLast =
                index == steps.length - 1;

            return _timelineItem(
              icon: step['icon'] as IconData,
              title: step['title'] as String,
              subtitle:
                  step['subtitle'] as String,
              reached: reached,
              active: active,
              isLast: isLast,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCancelledTimeline() {
    return _section(
      title: 'ORDER STATUS',
      child: _timelineItem(
        icon: Icons.cancel_outlined,
        title: 'ORDER CANCELLED',
        subtitle:
            'This order has been cancelled.',
        reached: true,
        active: true,
        isLast: true,
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool reached,
    required bool active,
    required bool isLast,
  }) {
    final gold = const Color(0xFFD4AF37);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached
                        ? gold.withOpacity(0.12)
                        : Colors.white.withOpacity(0.04),
                    border: Border.all(
                      color: reached
                          ? gold
                          : Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: reached
                        ? gold
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      color: reached
                          ? gold.withOpacity(0.45)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 25,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: reached
                                ? Colors.white
                                : Colors.white.withOpacity(0.35),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      if (active)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: gold.withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 8,
                              letterSpacing: 1,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: reached
                          ? Colors.white.withOpacity(0.55)
                          : Colors.white.withOpacity(0.25),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    final items = _items();

    return _section(
      title: 'YOUR FRAGRANCES',
      child: Column(
        children: [
          for (int index = 0;
              index < items.length;
              index++) ...[
            _buildItemCard(items[index]),
            if (index != items.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
  ) {
    final currency =
        _string(item['currency']).isEmpty
            ? (_string(_order?['currency']).isEmpty
                ? 'PKR'
                : _string(_order?['currency']))
            : _string(item['currency']);

    final quantity =
        (item['quantity'] as num?)?.toInt() ??
            int.tryParse(
              _string(item['quantity']),
            ) ??
            0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: const Color(0xFFD4AF37)
                    .withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.local_florist_outlined,
              color: Color(0xFFD4AF37),
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _string(item['name']).isEmpty
                      ? 'SHANO SHAN FRAGRANCE'
                      : _string(item['name']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'QTY $quantity',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _money(
                    item['unit_price'],
                    currency,
                  ),
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(
              item['total_price'],
              currency,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final order = _order!;

    final currency =
        _string(order['currency']).isEmpty
            ? 'PKR'
            : _string(order['currency']);

    return _section(
      title: 'ORDER SUMMARY',
      child: Column(
        children: [
          _summaryRow(
            'SUBTOTAL',
            _money(
              order['subtotal'],
              currency,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'DELIVERY',
            _number(order['delivery_fee']) == 0
                ? 'FREE'
                : _money(
                    order['delivery_fee'],
                    currency,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Divider(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          _summaryRow(
            'TOTAL',
            _money(
              order['total'],
              currency,
            ),
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(
              large ? 0.75 : 0.45,
            ),
            fontSize: large ? 12 : 10,
            fontWeight: large
                ? FontWeight.w600
                : FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: large
                ? const Color(0xFFD4AF37)
                : Colors.white,
            fontSize: large ? 18 : 12,
            fontWeight: large
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingDetails() {
    final order = _order!;

    final address =
        _string(order['address']);

    final city =
        _string(order['city']);

    final province =
        _string(order['province']);

    final postalCode =
        _string(order['postal_code']);

    final phone =
        _string(order['phone']);

    final paymentMethod =
        _string(order['payment_method']);

    return _section(
      title: 'DELIVERY DETAILS',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _detailRow(
            Icons.person_outline,
            'CUSTOMER',
            _string(order['customer_name']),
          ),
          _detailRow(
            Icons.phone_outlined,
            'PHONE',
            phone,
          ),
          if (_string(order['email']).isNotEmpty)
            _detailRow(
              Icons.email_outlined,
              'EMAIL',
              _string(order['email']),
            ),
          _detailRow(
            Icons.location_on_outlined,
            'ADDRESS',
            [
              address,
              city,
              province,
              postalCode,
            ]
                .where(
                  (value) => value.trim().isNotEmpty,
                )
                .join(', '),
          ),
          _detailRow(
            Icons.payments_outlined,
            'PAYMENT',
            paymentMethod.isEmpty
                ? 'NOT SPECIFIED'
                : paymentMethod.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty
                      ? 'NOT PROVIDED'
                      : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        18,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFD4AF37),
              size: 45,
            ),
            const SizedBox(height: 18),
            const Text(
              'COULD NOT LOAD ORDER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: _loadOrder,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFFD4AF37),
                side: const BorderSide(
                  color: Color(0xFFD4AF37),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'TRY AGAIN',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      );
    }

    if (_order == null) {
      return _buildError();
    }

    return RefreshIndicator(
      color: const Color(0xFFD4AF37),
      backgroundColor: const Color(0xFF111111),
      onRefresh: _refreshOrder,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 40,
        ),
        children: [
          _buildStatusHero(),
          _buildTrackingTimeline(),
          if (_items().isNotEmpty)
            _buildItems(),
          _buildPriceSummary(),
          _buildShippingDetails(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }
}