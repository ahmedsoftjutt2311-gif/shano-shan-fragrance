import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import 'theme/app_theme.dart';

import '../features/intro/intro_page.dart';
import '../features/home/home_page.dart';
import '../features/shop/shop_page.dart';
import '../features/fragrance_finder/fragrance_finder_page.dart';
import '../features/account/account_page.dart';
import '../features/cart/cart_page.dart';
import '../features/checkout/checkout_page.dart';
import '../features/orders/order_confirmation_page.dart';
import '../features/orders/my_orders_page.dart';
import '../features/orders/track_order_page.dart';
import '../features/product/product_page.dart';
import '../features/auth/login_page.dart';
import '../features/admin/admin_page.dart';
import '../features/about/about_page.dart';
import '../features/contact/contact_page.dart';

class ShanoShanApp extends StatelessWidget {
  const ShanoShanApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/intro',
    routes: [
      // ============================================================
      // INTRO
      // ============================================================

      GoRoute(
        path: '/intro',
        builder: (context, state) {
          return const IntroPage();
        },
      ),

      // ============================================================
      // CUSTOMER APP
      // ============================================================

      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            child: child,
          );
        },
        routes: [
          // HOME
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const HomePage();
            },
          ),

          // SHOP
          GoRoute(
            path: '/shop',
            builder: (context, state) {
              return const ShopPage();
            },
          ),

          // FIND YOUR SCENT
          GoRoute(
            path: '/find-your-scent',
            builder: (context, state) {
              return const FragranceFinderPage();
            },
          ),

          // PRODUCT
          GoRoute(
            path: '/product/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;

              return ProductPage(
                slug: slug,
              );
            },
          ),

          // ABOUT
          GoRoute(
            path: '/about',
            builder: (context, state) {
              return const AboutPage();
            },
          ),

          // CONTACT
          GoRoute(
            path: '/contact',
            builder: (context, state) {
              return const ContactPage();
            },
          ),

          // CART
          GoRoute(
            path: '/cart',
            builder: (context, state) {
              return const CartPage();
            },
          ),

          // CHECKOUT
          GoRoute(
            path: '/checkout',
            builder: (context, state) {
              return const CheckoutPage();
            },
          ),

          // ORDER CONFIRMATION
          GoRoute(
            path: '/order-confirmation',
            builder: (context, state) {
              final extra = state.extra;

              Map<String, dynamic>? order;

              if (extra is Map<String, dynamic>) {
                final rawOrder = extra['order'];

                if (rawOrder is Map<String, dynamic>) {
                  order = rawOrder;
                }
              }

              return OrderConfirmationPage(
                order: order,
              );
            },
          ),

          // MY ORDERS
          GoRoute(
            path: '/my-orders',
            builder: (context, state) {
              return const MyOrdersPage();
            },
          ),

          // TRACK MY ORDER
          GoRoute(
            path: '/track-order',
            builder: (context, state) {
              return const TrackOrderPage();
            },
          ),

          // ACCOUNT
          GoRoute(
            path: '/account',
            builder: (context, state) {
              return const AccountPage();
            },
          ),

          // LOGIN
          GoRoute(
            path: '/login',
            builder: (context, state) {
              return const LoginPage();
            },
          ),

          // ADMIN
          GoRoute(
            path: '/admin',
            builder: (context, state) {
              return const AdminPage();
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SHANO SHAN FRAGRANCE',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.dark(),
    );
  }
}