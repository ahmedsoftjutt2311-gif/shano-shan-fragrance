import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? _user;

  bool _loading = true;
  bool _loggingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final user =
          await AuthService.instance.fetchCurrentUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error =
            AuthService.instance.cleanError(error);
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
    });

    await AuthService.instance.logout();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                  strokeWidth: 2,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_user == null) {
      return _buildSignedOut();
    }

    final name =
        _user!['name']?.toString() ?? 'SHANO SHAN CLIENT';

    final email =
        _user!['email']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
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
              // ======================================================
              // HEADER
              // ======================================================

              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFD4AF37),
                size: 28,
              ),

              const SizedBox(height: 18),

              const Text(
                'MY ACCOUNT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'WELCOME TO SHANO SHAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 45),

              // ======================================================
              // PROFILE CARD
              // ======================================================

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0B0B),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.09),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              const Color(0xFFD4AF37),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFFD4AF37),
                        size: 29,
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w400,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ======================================================
              // MY ORDERS
              // ======================================================

              _AccountAction(
                icon: Icons.receipt_long_outlined,
                title: 'MY ORDERS',
                subtitle:
                    'View your purchases and order status',
                onTap: () {
                  context.push('/my-orders');
                },
              ),

              const SizedBox(height: 12),

              // ======================================================
              // TRACK ORDER
              // ======================================================

              _AccountAction(
                icon: Icons.local_shipping_outlined,
                title: 'TRACK AN ORDER',
                subtitle:
                    'Check the status of an order',
                onTap: () {
                  context.push('/order-tracking');
                },
              ),

              const SizedBox(height: 12),

              // ======================================================
              // CONTINUE SHOPPING
              // ======================================================

              _AccountAction(
                icon: Icons.shopping_bag_outlined,
                title: 'CONTINUE SHOPPING',
                subtitle:
                    'Explore the SHANO SHAN collection',
                onTap: () {
                  context.go('/shop');
                },
              ),

              const SizedBox(height: 35),

              // ======================================================
              // ERROR
              // ======================================================

              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ======================================================
              // LOGOUT
              // ======================================================

              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      _loggingOut ? null : _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.white70,
                    side: BorderSide(
                      color: Colors.white
                          .withValues(alpha: 0.18),
                    ),
                    shape:
                        const RoundedRectangleBorder(),
                  ),
                  child: _loggingOut
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Color(0xFFD4AF37),
                          ),
                        )
                      : const Text(
                          'SIGN OUT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'YOUR FRAGRANCE. YOUR STORY.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 9,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignedOut() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              color: Color(0xFFD4AF37),
              size: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              'SIGN IN TO YOUR ACCOUNT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign in to view your orders and account details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape:
                      const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ACCOUNT ACTION
// ================================================================

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B0B0B),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white
                  .withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size: 25,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white30,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}