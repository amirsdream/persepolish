import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/design_tokens.dart';

class StarBurstAnimation extends StatelessWidget {
  const StarBurstAnimation({
    super.key,
    required this.starCount,
    this.size = 48,
  });

  final int starCount; // 1–3
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$starCount star${starCount == 1 ? '' : 's'} earned',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final isFilled = index < starCount;
          final delay = Duration(milliseconds: index * 180);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: isFilled ? AppColors.starGold : AppColors.starEmpty,
              size: size,
            )
                .animate(delay: delay)
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1.0, 1.0),
                  duration: Durations.medium,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: Durations.fast),
          );
        }),
      ),
    );
  }
}
