import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/app_scope.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              AppIcon(Assets.icons.dumbbell, color: AppColors.primary, size: 96),
              const SizedBox(height: 24),
              Text('تابع تمرينك يوم بيوم', style: AppTextStyles.display(34), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'سجّل مجموعاتك وأوزانك، وشوف تقدمك كل أسبوع.',
                style: AppTextStyles.body(15, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTextStyles.body(16, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  AppScope.read(context).completeOnboarding();
                  Navigator.pushReplacementNamed(context, AppRoutes.layout);
                },
                child: const Text('يلا نبدأ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
