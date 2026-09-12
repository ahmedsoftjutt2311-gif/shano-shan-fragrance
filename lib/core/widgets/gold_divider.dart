import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class GoldDivider extends StatelessWidget {
  final double width;

  const GoldDivider({
    super.key,
    this.width = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      color: AppColors.gold,
    );
  }
}