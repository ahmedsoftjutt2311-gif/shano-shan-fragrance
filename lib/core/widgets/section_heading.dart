import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final bool centered;

  const SectionHeading({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    final textAlign =
        centered ? TextAlign.center : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            textAlign: textAlign,
            style: AppTypography.overline,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          title,
          textAlign: textAlign,
          style: AppTypography.sectionTitle,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 620,
            ),
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: AppTypography.body,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 46,
          height: 1,
          color: AppColors.gold,
        ),
      ],
    );
  }
}