import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class LuxuryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;

  const LuxuryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.icon,
  });

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final background = widget.filled
        ? (hovered ? AppColors.goldLight : AppColors.gold)
        : Colors.transparent;

    final foreground = widget.filled
        ? AppColors.black
        : (hovered ? AppColors.goldLight : AppColors.gold);

    return MouseRegion(
      cursor: enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) {
          setState(() => hovered = true);
        }
      },
      onExit: (_) {
        if (enabled) {
          setState(() => hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: widget.filled
                ? AppColors.gold
                : (hovered
                    ? AppColors.goldLight
                    : AppColors.gold),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.button.copyWith(
                      color: foreground,
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      widget.icon,
                      size: 16,
                      color: foreground,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}