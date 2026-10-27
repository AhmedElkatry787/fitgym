import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final onboardingSeen = AppScope.read(context).onboardingSeen;
      Navigator.pushReplacementNamed(context, onboardingSeen ? AppRoutes.layout : AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Assets.images.splash.image(
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
