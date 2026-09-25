import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AdaptiveLogo extends StatelessWidget {
  const AdaptiveLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.06).clamp(28.0, 56.0);
    return _F1Mark(size: size);
  }
}

class _F1Mark extends StatelessWidget {
  const _F1Mark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        'F1',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.38,
          height: 1,
        ),
      ),
    );
  }
}
