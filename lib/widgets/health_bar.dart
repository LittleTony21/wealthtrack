import 'package:flutter/material.dart';
import '../config/theme.dart';

class HealthBar extends StatelessWidget {
  final double percent;
  final double height;

  const HealthBar({super.key, required this.percent, this.height = 6});

  Color get _color {
    if (percent > 60) return AppColors.primary;
    if (percent > 30) return const Color(0xFFFFB340);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.surfaceHighlight,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: height,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percent.toStringAsFixed(0)}% health',
          style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
