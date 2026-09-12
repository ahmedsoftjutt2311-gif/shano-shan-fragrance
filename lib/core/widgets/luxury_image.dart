import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class LuxuryImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LuxuryImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surface,
        child: Image.asset(
          asset,
          fit: fit,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textMuted,
              ),
            );
          },
        ),
      ),
    );
  }
}