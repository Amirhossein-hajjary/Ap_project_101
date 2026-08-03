import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double effectiveRadius = borderRadius ?? AppTheme.radiusLg;
    final Color baseColor = isDark ? Colors.white : Colors.black;

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingXl),
          decoration: BoxDecoration(
            color: baseColor.withAlpha((opacity * 255).toInt()),
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(
              color: baseColor.withAlpha(30),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(isDark ? 30 : 50),
                Colors.white.withAlpha(isDark ? 5 : 10),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
