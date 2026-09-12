
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
// SITE FOOTER
// ======================================================

class _SiteFooter extends StatelessWidget {
  const _SiteFooter();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        if (constraints.maxWidth <
            700) {
          return const _MobileFooter();
        }

        return const _DesktopFooter();
      },
    );
  }
}

// ======================================================
// DESKTOP FOOTER
// ======================================================

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:
          const BoxDecoration(
        color:
            AppColors.charcoal,
        border:
            Border(
          top: BorderSide(
            color:
                AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1440,
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              48,
              58,
              48,
              28,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Expanded(
                      flex: 2,
                      child:
                          _FooterBrand(
                        onTap: () =>
                            context.go(
                          '/',
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 60,
                    ),

                    const Expanded(
                      child:
                          _FooterNavigationColumn(
                        title:
                            'SHOP',
                        items: [
                          _FooterLinkData(
                            label:
                                'Shop All Fragrances',
                            route:
                                '/shop',
                          ),
                          _FooterLinkData(
                            label:
                                'Find Your Scent',
                            route:
                                '/find-your-scent',
                          ),
                          _FooterLinkData(
                            label:
                                'Track My Order',
                            route:
                                '/track-order',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 30,
                    ),

                    const Expanded(
                      child:
                          _FooterNavigationColumn(
                        title:
                            'COMPANY',
                        items: [
                          _FooterLinkData(
                            label:
                                'About Us',
                            route:
                                '/about',
                          ),
                          _FooterLinkData(
                            label:
                                'Contact',
                            route:
                                '/contact',
                          ),
                          _FooterLinkData(
                            label:
                                'My Account',
                            route:
                                '/account',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 30,
                    ),

                    Expanded(
                      child:
                          _FooterConnect(
                        onContact: () =>
                            context.go(
                          '/contact',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 50,
                ),

                const Divider(
                  color:
                      AppColors.divider,
                ),

                const SizedBox(
                  height: 22,
                ),

                Row(
                  children: [
                    const Text(
                      '© SHANO SHAN FRAGRANCE',
                      style:
                          TextStyle(
                        color:
                            AppColors
                                .textMuted,
                        fontSize: 10,
                        letterSpacing:
                            1.5,
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      'CRAFTED FOR MEMORABLE MOMENTS.',
                      style:
                          TextStyle(
                        color:
                            AppColors
                                .textMuted,
                        fontFamily:
                            'Georgia',
                        fontSize: 10,
                        letterSpacing:
                            1.8,
                      ),
                    ),
                  ],
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
// FOOTER BRAND
// ======================================================

class _FooterBrand extends StatelessWidget {
  final VoidCallback onTap;

  const _FooterBrand({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.logo,
                width: 74,
                height: 74,
                fit: BoxFit.contain,
                filterQuality:
                    FilterQuality.high,
              ),

              const SizedBox(
                width: 15,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'SHANO SHAN',
                    style:
                        TextStyle(
                      color: Color(
                        0xFFE6B94F,
                      ),
                      fontFamily:
                          'Georgia',
                      fontSize: 21,
                      letterSpacing:
                          2.5,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Text(
                    'FRAGRANCE',
                    style:
                        TextStyle(
                      color:
                          AppColors
                              .goldDark,
                      fontSize: 9,
                      letterSpacing:
                          3.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Every fragrance has a story.\n'
            'Make yours memorable.',
            style:
                TextStyle(
              color:
                  AppColors
                      .textSecondary,
              fontFamily:
                  'Georgia',
              fontSize: 16,
              height: 1.7,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          const Text(
            'DISCOVER YOUR SIGNATURE.',
            style:
                TextStyle(
              color:
                  AppColors.gold,
              fontSize: 10,
              letterSpacing: 2.2,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FOOTER NAVIGATION COLUMN
// ======================================================

class _FooterNavigationColumn
    extends StatelessWidget {
  final String title;
  final List<_FooterLinkData>
      items;

  const _FooterNavigationColumn({
    required this.title,
    required this.items,
  });

  @override
  Widget build(
      BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.gold,
            fontSize: 10,
            letterSpacing: 2.5,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        ...items.map(
          (item) =>
              _FooterLink(
            label: item.label,
            route: item.route,
          ),
        ),
      ],
    );
  }
}

// ======================================================
// FOOTER LINK
// ======================================================

class _FooterLinkData {
  final String label;
  final String route;

  const _FooterLinkData({
    required this.label,
    required this.route,
  });
}

class _FooterLink
    extends StatefulWidget {
  final String label;
  final String route;

  const _FooterLink({
    required this.label,
    required this.route,
  });

  @override
  State<_FooterLink> createState() =>
      _FooterLinkState();
}

class _FooterLinkState
    extends State<_FooterLink> {
  bool hovered = false;

  @override
  Widget build(
      BuildContext context) {
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
      child: GestureDetector(
        onTap: () =>
            context.go(
          widget.route,
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(
            bottom: 15,
          ),
          child:
              AnimatedDefaultTextStyle(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            style: TextStyle(
              color: hovered
                  ? AppColors.gold
                  : AppColors
                      .textSecondary,
              fontSize: 12,
              letterSpacing: 0.8,
              height: 1.4,
            ),
            child: Text(
              widget.label,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// FOOTER CONNECT
// ======================================================

class _FooterConnect
    extends StatelessWidget {
  final VoidCallback onContact;

  const _FooterConnect({
    required this.onContact,
  });

  @override
  Widget build(
      BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'CONNECT',
          style:
              TextStyle(
            color:
                AppColors.gold,
            fontSize: 10,
            letterSpacing: 2.5,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        const Text(
          'Follow the world of\n'
          'SHANO SHAN.',
          style:
              TextStyle(
            color:
                AppColors
                    .textSecondary,
            fontFamily:
                'Georgia',
            fontSize: 15,
            height: 1.6,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        Row(
          children: [
            _SocialButton(
              icon: Icons
                  .camera_alt_outlined,
              tooltip:
                  'Instagram',
              onPressed:
                  onContact,
            ),

            const SizedBox(
              width: 10,
            ),

            _SocialButton(
              icon:
                  Icons.music_note,
              tooltip:
                  'TikTok',
              onPressed:
                  onContact,
            ),

            const SizedBox(
              width: 10,
            ),

            _SocialButton(
              icon:
                  Icons.facebook,
              tooltip:
                  'Facebook',
              onPressed:
                  onContact,
            ),

            const SizedBox(
              width: 10,
            ),

            _SocialButton(
              icon:
                  Icons.mail_outline,
              tooltip:
                  'Email',
              onPressed:
                  onContact,
            ),
          ],
        ),

        const SizedBox(
          height: 20,
        ),

        GestureDetector(
          onTap: onContact,
          child: const Text(
            'GET IN TOUCH →',
            style:
                TextStyle(
              color:
                  AppColors.gold,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// SOCIAL BUTTON
// ======================================================

class _SocialButton
    extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_SocialButton> createState() =>
      _SocialButtonState();
}

class _SocialButtonState
    extends State<_SocialButton> {
  bool hovered = false;

  @override
  Widget build(
      BuildContext context) {
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
      child: Tooltip(
        message:
            widget.tooltip,
        child: GestureDetector(
          onTap:
              widget.onPressed,
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              border:
                  Border.all(
                color: hovered
                    ? AppColors.gold
                    : AppColors
                        .divider,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: hovered
                  ? AppColors.gold
                  : AppColors
                      .textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// MOBILE FOOTER
// ======================================================

class _MobileFooter
    extends StatelessWidget {
  const _MobileFooter();

  @override
  Widget build(
      BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:
          const BoxDecoration(
        color:
            AppColors.charcoal,
        border:
            Border(
          top: BorderSide(
            color:
                AppColors.divider,
            width: 1,
          ),
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        24,
        46,
        24,
        24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () =>
                context.go('/'),
            child: Column(
              children: [
                Image.asset(
                  AppAssets.logo,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  filterQuality:
                      FilterQuality.high,
                ),

                const SizedBox(
                  height: 12,
                ),

                const Text(
                  'SHANO SHAN',
                  style:
                      TextStyle(
                    color: Color(
                      0xFFE6B94F,
                    ),
                    fontFamily:
                        'Georgia',
                    fontSize: 21,
                    letterSpacing:
                        2.5,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                const Text(
                  'FRAGRANCE',
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .goldDark,
                    fontSize: 9,
                    letterSpacing:
                        3.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          const Text(
            'Every fragrance has a story.\n'
            'Make yours memorable.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors
                      .textSecondary,
              fontFamily:
                  'Georgia',
              fontSize: 15,
              height: 1.7,
            ),
          ),

          const SizedBox(
            height: 34,
          ),

          const Text(
            'EXPLORE',
            style:
                TextStyle(
              color:
                  AppColors.gold,
              fontSize: 10,
              letterSpacing: 2.5,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          _MobileFooterLink(
            label: 'SHOP',
            route: '/shop',
          ),

          _MobileFooterLink(
            label: 'FIND YOUR SCENT',
            route:
                '/find-your-scent',
          ),

          _MobileFooterLink(
            label: 'ABOUT',
            route: '/about',
          ),

          _MobileFooterLink(
            label: 'CONTACT',
            route: '/contact',
          ),

          _MobileFooterLink(
            label: 'TRACK MY ORDER',
            route:
                '/track-order',
          ),

          _MobileFooterLink(
            label: 'MY ACCOUNT',
            route:
                '/account',
          ),

          _MobileFooterLink(
            label: 'CART',
            route: '/cart',
          ),

          const SizedBox(
            height: 20,
          ),

          const Divider(
            color:
                AppColors.divider,
          ),

          const SizedBox(
            height: 22,
          ),

          const Text(
            'FOLLOW SHANO SHAN',
            style:
                TextStyle(
              color:
                  AppColors.gold,
              fontSize: 10,
              letterSpacing: 2.3,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Builder(
            builder: (context) {
              return Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  _SocialButton(
                    icon: Icons
                        .camera_alt_outlined,
                    tooltip:
                        'Instagram',
                    onPressed: () =>
                        context.go(
                      '/contact',
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _SocialButton(
                    icon:
                        Icons.music_note,
                    tooltip:
                        'TikTok',
                    onPressed: () =>
                        context.go(
                      '/contact',
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _SocialButton(
                    icon:
                        Icons.facebook,
                    tooltip:
                        'Facebook',
                    onPressed: () =>
                        context.go(
                      '/contact',
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _SocialButton(
                    icon:
                        Icons.mail_outline,
                    tooltip:
                        'Email',
                    onPressed: () =>
                        context.go(
                      '/contact',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(
            height: 28,
          ),

          const Divider(
            color:
                AppColors.divider,
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            '© SHANO SHAN FRAGRANCE',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors.textMuted,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          const Text(
            'CRAFTED FOR MEMORABLE MOMENTS.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors.textMuted,
              fontFamily:
                  'Georgia',
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MOBILE FOOTER LINK
// ======================================================

class _MobileFooterLink
    extends StatelessWidget {
  final String label;
  final String route;

  const _MobileFooterLink({
    required this.label,
    required this.route,
  });

  @override
  Widget build(
      BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.go(route),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
        ),
        child: Text(
          label,
          textAlign:
              TextAlign.center,
          style:
              AppTypography.navigation
                  .copyWith(
            color:
                AppColors
                    .textSecondary,
            letterSpacing: 1.6,
            fontSize: 11,
          ),
        ),
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
