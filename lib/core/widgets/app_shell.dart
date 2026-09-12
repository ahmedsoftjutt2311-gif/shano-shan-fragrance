
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_assets.dart';
import 'announcement_bar.dart';
import '../../features/ai/shano_ai_chat.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath =
        GoRouterState.of(context).uri.path;

    final isAdminPage =
        currentPath.startsWith('/admin');

    return Scaffold(
      backgroundColor: AppColors.black,
      drawer: const _MobileDrawer(),

      body: Stack(
        children: [
          // ====================================================
          // MAIN WEBSITE
          // ====================================================

          Column(
            children: [
              const AnnouncementBar(),

              const _DesktopHeader(),

              Expanded(
                child: child,
              ),
            ],
          ),

          // ====================================================
          // SHANO AI FRAGRANCE ASSISTANT
          // ====================================================
          //
          // AI is available throughout the customer website.
          // It is hidden from the Admin Panel.
          //

          if (!isAdminPage)
            const ShanoAiChat(),
        ],
      ),
    );
  }
}

// ======================================================
// DESKTOP / MOBILE HEADER
// ======================================================

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return const _MobileHeader();
        }

        return const _DesktopNavigation();
      },
    );
  }
}

// ======================================================
// DESKTOP NAVIGATION
// ======================================================

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1440,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            child: Row(
              children: [
                // BRAND
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: const _DesktopBrand(),
                ),

                const Spacer(),

                // NAVIGATION
                _NavItem(
                  label: 'SHOP',
                  route: '/shop',
                ),

                _NavItem(
                  label: 'FIND YOUR SCENT',
                  route: '/find-your-scent',
                ),

                _NavItem(
                  label: 'ABOUT',
                  route: '/about',
                ),

                _NavItem(
                  label: 'CONTACT',
                  route: '/contact',
                ),

                _NavItem(
                  label: 'TRACK ORDER',
                  route: '/track-order',
                ),

                const SizedBox(width: 12),

                // ACCOUNT
                _HeaderIconButton(
                  icon: Icons.person_outline,
                  tooltip: 'Account',
                  onPressed: () => context.go('/account'),
                ),

                // CART
                _HeaderIconButton(
                  icon: Icons.shopping_bag_outlined,
                  tooltip: 'Cart',
                  onPressed: () => context.go('/cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// DESKTOP BRAND
// ======================================================

class _DesktopBrand extends StatelessWidget {
  const _DesktopBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.logo,
          width: 82,
          height: 82,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),

        const SizedBox(width: 18),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'SHANO SHAN',
              style: TextStyle(
                color: Color(0xFFE6B94F),
                fontFamily: 'Georgia',
                fontSize: 25,
                fontWeight: FontWeight.w400,
                letterSpacing: 2.8,
                height: 1.0,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 1,
                  color: Color(0xFFD6A33A),
                ),

                const SizedBox(width: 10),

                const Text(
                  'FRAGRANCE',
                  style: TextStyle(
                    color: Color(0xFFE6B94F),
                    fontFamily: 'Georgia',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4.5,
                    height: 1.0,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 32,
                  height: 1,
                  color: Color(0xFFD6A33A),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ======================================================
// NAVIGATION ITEM
// ======================================================

class _NavItem extends StatefulWidget {
  final String label;
  final String route;

  const _NavItem({
    required this.label,
    required this.route,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentPath =
        GoRouterState.of(context).uri.path;

    final isActive =
        currentPath == widget.route ||
        (widget.route != '/' &&
            currentPath.startsWith(
              '${widget.route}/',
            ));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () =>
            context.go(widget.route),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 10,
          ),
          child:
              AnimatedDefaultTextStyle(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            style:
                AppTypography.navigation
                    .copyWith(
              color:
                  isActive || isHovered
                      ? AppColors.gold
                      : AppColors.textSecondary,
              letterSpacing: 1.6,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HEADER ICON
// ======================================================

class _HeaderIconButton
    extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_HeaderIconButton> createState() =>
      _HeaderIconButtonState();
}

class _HeaderIconButtonState
    extends State<_HeaderIconButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: IconButton(
        tooltip: widget.tooltip,
        onPressed: widget.onPressed,
        icon: Icon(
          widget.icon,
          size: 21,
          color: hovered
              ? AppColors.gold
              : AppColors.textSecondary,
        ),
        splashRadius: 22,
      ),
    );
  }
}

// ======================================================
// MOBILE HEADER
// ======================================================

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context)
                      .openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.ivory,
                ),
              );
            },
          ),

          const Spacer(),

          GestureDetector(
            onTap: () =>
                context.go('/'),
            child:
                const _MobileBrand(),
          ),

          const Spacer(),

          IconButton(
            tooltip: 'Cart',
            onPressed: () =>
                context.go('/cart'),
            icon: const Icon(
              Icons
                  .shopping_bag_outlined,
              color:
                  AppColors.ivory,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MOBILE BRAND
// ======================================================

class _MobileBrand extends StatelessWidget {
  const _MobileBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.logo,
          width: 48,
          height: 64,
          fit: BoxFit.contain,
          filterQuality:
              FilterQuality.high,
        ),

        const SizedBox(width: 8),

        Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'SHANO SHAN',
              style: TextStyle(
                color:
                    Color(0xFFE6B94F),
                fontFamily: 'Georgia',
                fontSize: 13,
                fontWeight:
                    FontWeight.w400,
                letterSpacing: 1.8,
                height: 1.0,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 15,
                  height: 1,
                  color:
                      Color(0xFFD6A33A),
                ),

                const SizedBox(width: 5),

                const Text(
                  'FRAGRANCE',
                  style: TextStyle(
                    color:
                        Color(0xFFE6B94F),
                    fontFamily:
                        'Georgia',
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w500,
                    letterSpacing: 2.2,
                  ),
                ),

                const SizedBox(width: 5),

                Container(
                  width: 15,
                  height: 1,
                  color:
                      Color(0xFFD6A33A),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ======================================================
// MOBILE DRAWER
// ======================================================

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          AppColors.charcoal,
      child: SafeArea(
        child:
            SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Image.asset(
                AppAssets.logo,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                filterQuality:
                    FilterQuality.high,
              ),

              const SizedBox(height: 8),

              const Text(
                'SHANO SHAN',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Color(0xFFE6B94F),
                  fontFamily:
                      'Georgia',
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w400,
                  letterSpacing: 2.5,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'FRAGRANCE',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Color(0xFFE6B94F),
                  fontFamily:
                      'Georgia',
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w500,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 18),

              const Divider(
                color:
                    AppColors.divider,
              ),

              _DrawerItem(
                label: 'HOME',
                route: '/',
              ),

              _DrawerItem(
                label: 'SHOP',
                route: '/shop',
              ),

              _DrawerItem(
                label: 'FIND YOUR SCENT',
                route:
                    '/find-your-scent',
              ),

              _DrawerItem(
                label: 'ABOUT',
                route: '/about',
              ),

              _DrawerItem(
                label: 'CONTACT',
                route: '/contact',
              ),

              _DrawerItem(
                label: 'TRACK MY ORDER',
                route:
                    '/track-order',
              ),

              _DrawerItem(
                label: 'MY ACCOUNT',
                route: '/account',
              ),

              _DrawerItem(
                label: 'CART',
                route: '/cart',
              ),

              const SizedBox(height: 18),

              const Divider(
                color:
                    AppColors.divider,
              ),

              const SizedBox(height: 12),

              const Text(
                'SHANO SHAN',
                style: TextStyle(
                  color:
                      AppColors.goldDark,
                  fontFamily:
                      'Georgia',
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// DRAWER ITEM
// ======================================================

class _DrawerItem extends StatelessWidget {
  final String label;
  final String route;

  const _DrawerItem({
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context)
            .pop();

        context.go(route);
      },
      title: Text(
        label,
        style:
            AppTypography.navigation
                .copyWith(
          color:
              AppColors.textSecondary,
          letterSpacing: 1.8,
        ),
      ),
      trailing:
          const Icon(
        Icons
            .arrow_forward_ios,
        size: 13,
        color:
            AppColors.goldDark,
      ),
    );
  }
}



// ======================================================
// CONSTANTS
// ======================================================

abstract final class AppConstantsForShell {
  static const double
      mobileBreakpoint = 700;
}
