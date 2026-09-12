import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final value = index + 1;

          IconData icon;

          if (rating >= value) {
            icon = Icons.star;
          } else if (rating >= value - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return Icon(
            icon,
            size: size,
            color: AppColors.gold,
          );
        },
      ),
    );
  }
}