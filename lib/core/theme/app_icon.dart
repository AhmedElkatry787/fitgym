import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:flutter/widgets.dart';

/// Draws one of the single-colour SVG icons in `assets/icons/` in [color].
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, required this.color, this.size = 24});

  final SvgGenImage icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return icon.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
