import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class PageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PageContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1440,
        ),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
          child: child,
        ),
      ),
    );
  }
}