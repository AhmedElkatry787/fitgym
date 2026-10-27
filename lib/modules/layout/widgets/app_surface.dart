import 'package:FitGym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A rounded card. Pass [onTap] to make it a button with a ripple.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.radius = 18,
    this.borderColor,
    this.borderWidth = 1,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final Color color;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Read by screen readers; needed when [child] has no text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) content = InkWell(onTap: onTap, child: content);

    final surface = Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!, width: borderWidth),
      ),
      child: content,
    );

    if (onTap == null) return surface;
    return Semantics(button: true, label: semanticLabel, child: surface);
  }
}
