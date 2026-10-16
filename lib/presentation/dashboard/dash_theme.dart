import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DashColors {
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color text(BuildContext context) => isDark(context) ? AppColors.textDark : AppColors.text;

  static Color muted(BuildContext context) => isDark(context) ? AppColors.mutedDark : AppColors.muted;

  static Color line(BuildContext context) => isDark(context) ? AppColors.lineDark : AppColors.line;

  static Color raised(BuildContext context) =>
      isDark(context) ? AppColors.panelRaised : const Color(0xFFF4F6F8);
}

class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 240),
      child: widget.child,
    );
  }
}
