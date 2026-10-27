import 'package:FitGym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Scrollable page body shared by the screens above the bottom bar.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.children, this.spacing = 18});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );
  }
}
