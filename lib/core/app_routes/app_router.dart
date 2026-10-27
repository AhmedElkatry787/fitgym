import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/modules/layout/exercises/exercises_screen.dart';
import 'package:FitGym/modules/layout/layout_screen.dart';
import 'package:FitGym/modules/layout/muscles/muscles_screen.dart';
import 'package:FitGym/modules/layout/program/program_screen.dart';
import 'package:FitGym/modules/onbording/onbording_screen.dart';
import 'package:FitGym/modules/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.onboarding => const OnbordingScreen(),
      AppRoutes.layout => const LayoutScreen(),
      _ => const SplashScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> onGenerateExercisesRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.muscles => MusclesScreen(initialMuscle: settings.arguments as Muscle? ?? Muscle.shoulders),
      AppRoutes.program => const ProgramScreen(),
      _ => const ExercisesScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
