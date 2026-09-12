import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/order_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders =
          await OrderService.instance.getMyOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error =
            OrderService.instance.cleanError(error);
        _loading = false;
      });
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'ORDER PLACED';

      case 'confirmed':
        return 'CONFIRMED';

      case 'processing':
        return 'PROCESSING';

      case 'shipped':
        return 'SHIPPED';

      case 'delivered':
        return 'DELIVERED';

      case 'cancelled':
        return 'CANCELLED';

      default:
        return status
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF6FCF97);

      case 'shipped':
        return const Color(0xFF7DB7FF);

      case 'cancelled':
        return const Color(0xFFFF6B6B);

      case 'processing':
      case 'confirmed':
        return const Color(0xFFD4AF37);

      default:
        return Colors.white54;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    final raw = value.toString();

    try {
      final date = DateTime.parse(raw).toLocal();

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

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} '
          '${date.year}';
    } catch (_) {
      return raw;
    }
  }

  String _money(dynamic value, dynamic currency) {
    final amount =
        double.tryParse(value?.toString() ?? '') ?? 0;

    final code =
        currency?.toString().trim().isNotEmpty == true
            ? currency.toString()
            : 'PKR';

    return '$code ${amount.toStringAsFixed(0)}';
  }

  int _itemCount(Map<String, dynamic> order) {
    final items = order['items'];

    if (items is! List) return 0;

    var count = 0;

    for (final item in items) {
      if (item is Map) {
        count +=
            int.tryParse(
                  item['quantity']?.toString() ?? '0',
                ) ??
                0;
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MY ORDERS',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF111111),
        onRefresh: _loadOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_orders.isEmpty) {
      return _buildEmpty();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        25,
        20,
        50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Text(
                'YOUR JOURNEY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'ORDER HISTORY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${_orders.length} '
                '${_orders.length == 1 ? 'ORDER' : 'ORDERS'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 35),

              ..._orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: _OrderCard(
                    order: order,
                    statusLabel: _statusLabel(
                      order['order_status']
                              ?.toString() ??
                          'pending',
                    ),
                    statusColor: _statusColor(
                      order['order_status']
                              ?.toString() ??
                          'pending',
                    ),
                    formattedDate: _formatDate(
                      order['created_at'],
                    ),
                    itemCount: _itemCount(order),
                    total: _money(
                      order['total'],
                      order['currency'],
                    ),
                    onTap: () {
                      final number =
                          order['order_number']
                              ?.toString();

                      if (number == null ||
                          number.isEmpty) {
                        return;
                      }

                      context.push(
                        '/order-details/${Uri.encodeComponent(number)}',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight - 60,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFD4AF37),
                    size: 50,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'NO ORDERS YET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Your fragrance journey starts here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/shop');
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD4AF37),
                        foregroundColor:
                            Colors.black,
                        shape:
                            const RoundedRectangleBorder(),
                      ),
                      child: const Text(
                        'EXPLORE FRAGRANCES',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.white38,
                size: 48,
              ),

              const SizedBox(height: 22),

              const Text(
                'COULD NOT LOAD ORDERS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              OutlinedButton(
                onPressed: _loadOrders,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFFD4AF37),
                  side: const BorderSide(
                    color: Color(0xFFD4AF37),
                  ),
                  shape:
                      const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'TRY AGAIN',
                  style: TextStyle(
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
}

// ================================================================
// ORDER CARD
// ================================================================

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String statusLabel;
  final Color statusColor;
  final String formattedDate;
  final int itemCount;
  final String total;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    required this.formattedDate,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber =
        order['order_number']?.toString() ??
            'UNKNOWN ORDER';

    return Material(
      color: const Color(0xFF0B0B0B),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white
                  .withValues(alpha: 0.09),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFD4AF37),
                    size: 18,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      orderNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: statusColor
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                height: 1,
                color: Colors.white
                    .withValues(alpha: 0.07),
              ),

              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: _Info(
                      label: 'DATE',
                      value: formattedDate,
                    ),
                  ),
                  Expanded(
                    child: _Info(
                      label: 'ITEMS',
                      value: '$itemCount',
                    ),
                  ),
                  Expanded(
                    child: _Info(
                      label: 'TOTAL',
                      value: total,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  const Text(
                    'VIEW ORDER',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFD4AF37),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 8,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}