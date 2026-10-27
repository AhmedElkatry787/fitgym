import 'dart:async';

import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Counts down the rest between sets. Buzzes when it's over.
class RestTimer extends ChangeNotifier {
  Duration _remaining = WorkoutService.restDuration;
  Timer? _ticker;

  bool get running => _ticker != null;

  /// e.g. `1:45`.
  String get label {
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '${_remaining.inMinutes}:$seconds';
  }

  /// Starts a full rest, as after finishing a set.
  void start() {
    _remaining = WorkoutService.restDuration;
    _run();
  }

  void toggle() {
    if (running) {
      _stopTicking();
      notifyListeners();
    } else if (_remaining == Duration.zero) {
      start();
    } else {
      _run();
    }
  }

  void reset() {
    _stopTicking();
    _remaining = WorkoutService.restDuration;
    notifyListeners();
  }

  void _run() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    _remaining -= const Duration(seconds: 1);
    if (_remaining <= Duration.zero) {
      _remaining = Duration.zero;
      _stopTicking();
      HapticFeedback.heavyImpact();
    }
    notifyListeners();
  }

  void _stopTicking() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicking();
    super.dispose();
  }
}

/// "الراحة" with a play/pause countdown and a reset button.
class RestBar extends StatelessWidget {
  const RestBar({super.key, required this.timer});

  final RestTimer timer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(18)),
          child: Row(
            spacing: 12,
            children: [
              IconBox(
                icon: Assets.icons.close,
                background: AppColors.primary,
                iconColor: AppColors.background,
                iconSize: 14,
                size: 28,
                label: 'إلغاء الراحة',
                onPressed: timer.reset,
              ),
              Expanded(child: Text('الراحة', style: AppTextStyles.body(15, fontWeight: FontWeight.w600))),
              AppSurface(
                color: AppColors.primary,
                radius: 999,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: timer.toggle,
                semanticLabel: timer.running ? 'إيقاف الراحة' : 'ابدأ الراحة',
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    spacing: 6,
                    children: [
                      AppIcon(
                        timer.running ? Assets.icons.pause : Assets.icons.play,
                        color: AppColors.background,
                        size: 14,
                      ),
                      Text(
                        timer.label,
                        style: AppTextStyles.body(15, fontWeight: FontWeight.w700, color: AppColors.background),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shown in place of the rest bar once everything planned is done.
class DoneBar extends StatelessWidget {
  const DoneBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        spacing: 12,
        children: [
          const CheckCircle(size: 28, iconSize: 15),
          Expanded(child: Text(text, style: AppTextStyles.body(15, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
