import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/modules/layout/muscles/body_map.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/check_circle.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:FitGym/modules/layout/widgets/sets_label.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class MusclesScreen extends StatefulWidget {
  const MusclesScreen({super.key, this.initialMuscle = Muscle.shoulders});

  final Muscle initialMuscle;

  @override
  State<MusclesScreen> createState() => _MusclesScreenState();
}

class _MusclesScreenState extends State<MusclesScreen> {
  late Muscle _selected = widget.initialMuscle;

  @override
  Widget build(BuildContext context) {
    return TabPage(
      spacing: 16,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(child: Text('عضلات الجسم', style: AppTextStyles.pageTitle)),
            IconBox(
              icon: Assets.icons.arrowBack,
              background: AppColors.surface,
              iconColor: AppColors.textPrimary,
              label: 'رجوع',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        AppSurface(
          radius: 22,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              _BodyView(side: BodySide.front, highlight: _selected, label: 'أمام'),
              _BodyView(side: BodySide.back, highlight: _selected, label: 'خلف'),
            ],
          ),
        ),
        for (final muscle in Muscle.values)
          _MuscleTile(
            muscle: muscle,
            selected: muscle == _selected,
            onTap: () => setState(() => _selected = muscle),
          ),
      ],
    );
  }
}

class _BodyView extends StatelessWidget {
  const _BodyView({required this.side, required this.highlight, required this.label});

  final BodySide side;
  final Muscle highlight;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        BodyMap(side: side, highlight: highlight),
        Text(label, style: AppTextStyles.body(12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MuscleTile extends StatelessWidget {
  const _MuscleTile({required this.muscle, required this.selected, required this.onTap});

  final Muscle muscle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AppSurface(
        color: selected ? AppColors.surfaceRaised : AppColors.surface,
        borderColor: selected ? AppColors.primary : null,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text('تمرين ال${muscle.label}', style: AppTextStyles.body(16, fontWeight: FontWeight.w700)),
                  SetsLabel(muscle.setsLabel),
                ],
              ),
            ),
            if (selected)
              const CheckCircle(size: 36, iconSize: 18)
            else
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: AppIcon(Assets.icons.chevron, color: AppColors.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
