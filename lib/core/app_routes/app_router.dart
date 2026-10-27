import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/modules/layout/exercise_details/exercise_details_screen.dart';
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
      AppRoutes.exerciseDetails => ExerciseDetailsScreen(exercise: settings.arguments! as ExerciseModel),
      _ => const SplashScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> onGenerateExercisesRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.muscles => const MusclesScreen(),
      AppRoutes.program => const ProgramScreen(),
      AppRoutes.exerciseDetails => ExerciseDetailsScreen(exercise: settings.arguments! as ExerciseModel),
      _ => const ExercisesScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
