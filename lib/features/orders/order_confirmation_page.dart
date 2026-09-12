import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({
    super.key,
    this.order,
    this.phone = '',
  });

  final Map<String, dynamic>? order;
  final String phone;

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with SingleTickerProviderStateMixin {
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF050505);
  static const Color panel = Color(0xFF0D0D0D);
  static const Color border = Color(0xFF252525);
  static const Color muted = Color(0xFF777777);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(dynamic value, dynamic currency) {
    final amount = int.tryParse(value?.toString() ?? '') ?? 0;
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${currency?.toString() ?? 'PKR'} $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    if (order == null) {
      return _missingOrder(context);
    }

    final orderNumber = order['order_number']?.toString() ?? '';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 45, 22, 55),
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: _successIcon(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'ORDER CONFIRMED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thank you for choosing SHANO SHAN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 11, height: 1.6),
                ),
                const SizedBox(height: 32),
                _orderNumberCard(orderNumber),
                const SizedBox(height: 18),
                _statusCard(order),
                const SizedBox(height: 18),
                _totalCard(order),
                const SizedBox(height: 30),
                _trackButton(context, orderNumber),
                const SizedBox(height: 12),
                _secondaryButton(
                  label: 'VIEW MY ORDERS',
                  onPressed: () => context.go('/my-orders'),
                ),
                const SizedBox(height: 12),
                _secondaryButton(
                  label: 'CONTINUE SHOPPING',
                  onPressed: () => context.go('/shop'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'BACK TO HOME',
                    style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _successIcon() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.check, color: gold, size: 42),
      ),
    );
  }

  Widget _orderNumberCard(String orderNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: panel, border: Border.all(color: border)),
      child: Column(
        children: [
          const Text(
            'ORDER NUMBER',
            style: TextStyle(color: muted, fontSize: 9, letterSpacing: 1.8),
          ),
          const SizedBox(height: 10),
          Text(
            orderNumber.isEmpty ? '—' : orderNumber,
            style: const TextStyle(
              color: gold,
              fontSize: 19,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(Map<String, dynamic> order) {
    final status = order['order_status']?.toString() ?? 'pending';
    final payment = order['payment_status']?.toString() ?? 'pending';
    final method = order['payment_method']?.toString() ?? 'cod';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: panel, border: Border.all(color: border)),
      child: Column(
        children: [
          _row('ORDER STATUS', status.replaceAll('_', ' ').toUpperCase()),
          const SizedBox(height: 15),
          _row('PAYMENT', method == 'online' ? 'EASYPAISA' : 'CASH ON DELIVERY'),
          const SizedBox(height: 15),
          _row('PAYMENT STATUS', payment.replaceAll('_', ' ').toUpperCase()),
        ],
      ),
    );
  }

  Widget _totalCard(Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: panel, border: Border.all(color: border)),
      child: Column(
        children: [
          _row('SUBTOTAL', _formatPrice(order['subtotal'], order['currency'])),
          const SizedBox(height: 15),
          _row('DELIVERY', _formatPrice(order['delivery_fee'], order['currency'])),
          const SizedBox(height: 20),
          Container(height: 1, color: border),
          const SizedBox(height: 20),
          _row('TOTAL', _formatPrice(order['total'], order['currency']), highlight: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.white : muted,
            fontSize: highlight ? 11 : 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.3,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlight ? gold : Colors.white,
            fontSize: highlight ? 17 : 10,
            fontWeight: highlight ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _trackButton(BuildContext context, String orderNumber) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: orderNumber.isEmpty
            ? null
            : () => context.push(
                  '/order-details',
                  extra: {
                    'order': widget.order,
                    'phone': widget.phone,
                  },
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
        ),
        child: const Text(
          'TRACK MY ORDER',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _secondaryButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: border),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.7),
        ),
      ),
    );
  }

  Widget _missingOrder(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, color: Color(0xFF555555), size: 60),
              const SizedBox(height: 22),
              const Text(
                'ORDER NOT FOUND',
                style: TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 2.5),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => context.go('/shop'),
                style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                child: const Text('CONTINUE SHOPPING'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
