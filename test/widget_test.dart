import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  /// Starts the app on Tuesday 2026-10-27, a chest and triceps day.
  Future<void> launch(WidgetTester tester, {bool onboardingSeen = false}) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': onboardingSeen});
    final storage = StorageService(await SharedPreferences.getInstance());
    await tester.pumpWidget(MyApp(controller: AppController(storage, () => DateTime(2026, 10, 27, 18))));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('first launch shows onboarding, then home', (tester) async {
    await launch(tester);
    expect(find.text('يلا نبدأ'), findsOneWidget);

    await tester.tap(find.text('يلا نبدأ'));
    await tester.pumpAndSettle();
    expect(find.text('دفتر التمرين'), findsOneWidget);
    expect(find.text('صدر و ترايبس'), findsOneWidget);
  });

  testWidgets('later launches skip onboarding', (tester) async {
    await launch(tester, onboardingSeen: true);
    expect(find.text('يلا نبدأ'), findsNothing);
    expect(find.text('دفتر التمرين'), findsOneWidget);
  });

  testWidgets('marking a set in the program updates home', (tester) async {
    final semantics = tester.ensureSemantics();
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('برنامج التمرين'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('المجموعة 1').first);
    await tester.pump();
    expect(find.text('1:59'), findsNothing, reason: 'rest starts at 2:00');
    expect(find.text('2:00'), findsOneWidget);

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    expect(find.text('كمّل التمرين'), findsOneWidget);
    expect(find.text('خلّصت 1 من 12 مجموعة'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a logged weight shows on the card and in records', (tester) async {
    final semantics = tester.ensureSemantics();
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('التقدم'));
    await tester.pumpAndSettle();
    expect(find.textContaining('لسه مسجّلتش أوزان'), findsOneWidget);

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ضغط بار مستوي'));
    await tester.pumpAndSettle();
    expect(find.text('وزن ضغط بار مستوي'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('زوّد الوزن'));
    await tester.pump();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    expect(find.text('22.5 كجم'), findsOneWidget);

    await tester.tap(find.text('التقدم'));
    await tester.pumpAndSettle();
    expect(find.text('ضغط بار مستوي'), findsOneWidget);
    expect(find.text('22.5 كجم'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('exercise card opens its muscle, and home still opens the program', (tester) async {
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('التمارين'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('سكوات'));
    await tester.tap(find.text('سكوات'));
    await tester.pumpAndSettle();
    expect(find.text('عضلات الجسم'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('رجل متعلّم')), findsNWidgets(2));

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('برنامج التمرين'), findsOneWidget);
    expect(find.text('عضلات الجسم'), findsNothing);
  });
}
