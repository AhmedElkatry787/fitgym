import 'package:FitGym/core/services/app_controller.dart';
import 'package:flutter/widgets.dart';

/// Hands the [AppController] down the tree and rebuilds dependents when it
/// changes.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child})
    : super(notifier: controller);

  /// Use in `build`: the widget rebuilds when the data changes.
  static AppController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }

  /// Use in callbacks, where rebuilding isn't needed.
  static AppController read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}
