import 'package:FitGym/core/app_routes/app_routes.dart';
import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:FitGym/model/exercise_model.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:FitGym/modules/layout/layout_screen.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:FitGym/modules/layout/widgets/icon_box.dart';
import 'package:FitGym/modules/layout/widgets/section_header.dart';
import 'package:FitGym/modules/layout/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  static const _filters = <Muscle?>[null, ...Muscle.values];

  late final ValueNotifier<Muscle?> _filter;
  final _scroll = ScrollController();
  final _chipKeys = {for (final muscle in _filters) muscle: GlobalKey()};
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _filter = LayoutScreen.of(context).exerciseFilter..addListener(_showFilterFromTop);
  }

  @override
  void dispose() {
    _filter.removeListener(_showFilterFromTop);
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// A new muscle starts at its first exercise, with its chip in view, even
  /// when picked from the home screen.
  void _showFilterFromTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chip = _chipKeys[_filter.value]?.currentContext;
      if (chip != null && chip.mounted) Scrollable.ensureVisible(chip, alignment: 0.5);
    });
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _searchController.clear();
    });
  }

  void _openExercise(ExerciseModel exercise) {
    Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: exercise);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Muscle?>(
      valueListenable: _filter,
      builder: (context, filter, _) {
        final query = _searchController.text.trim();
        // Every muscle in its own section, or just the chosen one.
        final sections = [
          for (final muscle in filter == null ? Muscle.values : [filter])
            (muscle: muscle, exercises: WorkoutService.exercisesFor(muscle, query: query)),
        ].where((section) => section.exercises.isNotEmpty).toList();

        return TabPage(
          controller: _scroll,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(child: Text('اختر التمرين', style: AppTextStyles.pageTitle)),
                IconBox(
                  icon: Assets.icons.person,
                  background: AppColors.surface,
                  iconColor: AppColors.primary,
                  label: 'عضلات الجسم',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.muscles),
                ),
                IconBox(
                  icon: _searching ? Assets.icons.close : Assets.icons.search,
                  background: AppColors.primary,
                  iconColor: AppColors.background,
                  label: _searching ? 'إغلاق البحث' : 'بحث',
                  onPressed: _toggleSearch,
                ),
              ],
            ),
            if (_searching)
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body(15),
                decoration: InputDecoration(
                  hintText: 'دوّر على تمرين',
                  hintStyle: AppTextStyles.body(15, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.surfaceRaised),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.surfaceRaised),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  for (final muscle in _filters)
                    _FilterChip(
                      key: _chipKeys[muscle],
                      label: muscle?.label ?? 'الكل',
                      selected: muscle == filter,
                      onTap: () => _filter.value = muscle,
                    ),
                ],
              ),
            ),
            if (sections.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('مفيش تمارين بالاسم ده', style: AppTextStyles.caption, textAlign: TextAlign.center),
              ),
            for (final section in sections)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  if (filter == null)
                    SectionHeader(
                      title: section.muscle.label,
                      trailing: Text(
                        WorkoutService.exercisesCountLabel(section.exercises.length),
                        style: AppTextStyles.caption,
                      ),
                    ),
                  _ExercisesGrid(exercises: section.exercises, onTap: _openExercise),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AppSurface(
        color: selected ? AppColors.primary : AppColors.surface,
        radius: 12,
        borderColor: selected ? null : AppColors.surfaceRaised,
        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 14),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Center(
            widthFactor: 1,
            child: Text(
            label,
            style: AppTextStyles.body(
              14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExercisesGrid extends StatelessWidget {
  const _ExercisesGrid({required this.exercises, required this.onTap});

  final List<ExerciseModel> exercises;
  final ValueChanged<ExerciseModel> onTap;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - _gap) / 2;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final exercise in exercises)
              SizedBox(
                width: cardWidth,
                child: _ExerciseCard(exercise: exercise, onTap: () => onTap(exercise)),
              ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final ExerciseModel exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      borderColor: AppColors.surfaceRaised,
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 104,
                color: AppColors.surfaceRaised,
                alignment: Alignment.center,
                child: AppIcon(Assets.icons.person, color: AppColors.textSecondary, size: 44),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(exercise.name, style: AppTextStyles.body(15, fontWeight: FontWeight.w700)),
                    Text(exercise.muscle.label, style: AppTextStyles.body(12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (exercise.featured)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  'مميز',
                  style: AppTextStyles.body(11, fontWeight: FontWeight.w700, color: AppColors.background),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
