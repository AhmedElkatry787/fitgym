class AppRoutes {
  // Root navigator.
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const layout = '/layout';

  // Navigator inside the exercises tab, so the bottom bar stays visible.
  // No leading slash: a slash would make the initial route a deep link.
  static const exercises = 'exercises';
  static const muscles = 'muscles';
  static const program = 'program';

  // In both navigators: from the exercises and program screens, and from the
  // progress tab.
  static const exerciseDetails = 'exercise_details';
}
