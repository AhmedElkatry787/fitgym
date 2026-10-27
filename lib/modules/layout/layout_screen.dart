import 'package:FitGym/core/app_routes/app_router.dart';
import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/modules/layout/home/home_screen.dart';
import 'package:FitGym/modules/layout/progress/progress_screen.dart';
import 'package:FitGym/modules/layout/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The bottom-bar shell. The exercises tab has its own navigator so the
/// muscles and program screens open with the bar still showing.
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  static LayoutScreenState of(BuildContext context) => context.findAncestorStateOfType<LayoutScreenState>()!;

  @override
  State<LayoutScreen> createState() => LayoutScreenState();
}

class LayoutScreenState extends State<LayoutScreen> {
  static const homeTab = 0;
  static const progressTab = 1;
  static const exercisesTab = 2;

  /// Muscle chip selected on the exercises screen; null shows every muscle.
  final exerciseFilter = ValueNotifier<Muscle?>(null);

  final _exercisesNavigatorKey = GlobalKey<NavigatorState>();
  int _currentTab = homeTab;

  @override
  void dispose() {
    exerciseFilter.dispose();
    super.dispose();
  }

  void changeTab(int tab) {
    // Tapping the active exercises tab goes back to its first screen.
    if (tab == exercisesTab && _currentTab == exercisesTab) {
      _exercisesNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _currentTab = tab);
  }

  void openExercises({Muscle? muscle}) {
    exerciseFilter.value = muscle;
    _exercisesNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => _currentTab = exercisesTab);
  }

  void openProgram() {
    _exercisesNavigatorKey.currentState
      ?..popUntil((route) => route.isFirst)
      ..pushNamed(AppRoutes.program);
    setState(() => _currentTab = exercisesTab);
  }

  void _handleBack() {
    final exercisesNavigator = _exercisesNavigatorKey.currentState;
    if (_currentTab == exercisesTab && exercisesNavigator != null && exercisesNavigator.canPop()) {
      exercisesNavigator.pop();
    } else if (_currentTab != homeTab) {
      setState(() => _currentTab = homeTab);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentTab,
          children: [
            const HomeScreen(),
            const ProgressScreen(),
            Navigator(
              key: _exercisesNavigatorKey,
              initialRoute: AppRoutes.exercises,
              onGenerateRoute: AppRouter.onGenerateExercisesRoute,
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(currentIndex: _currentTab, onTap: changeTab),
      ),
    );
  }
}
