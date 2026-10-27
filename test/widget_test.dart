import 'package:FitGym/core/services/app_controller.dart';
import 'package:FitGym/core/services/storage_service.dart';
import 'package:FitGym/core/services/workout_service.dart';
import 'package:FitGym/main.dart';
import 'package:flutter/material.dart';
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
    await tester.pumpAndSettle();
    expect(find.text('المجموعة 1'), findsOneWidget, reason: 'the set sheet is open');
    await tester.tap(find.text('حفظ المجموعة'));
    await tester.pumpAndSettle();
    expect(find.text(WorkoutService.ltr('20×10')), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:59'), findsOneWidget, reason: 'rest started counting down');

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    expect(find.text('كمّل التمرين'), findsOneWidget);
    expect(find.text('خلّصت 1 من 12 مجموعة'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('weights typed per set show in records and exercise progress', (tester) async {
    final semantics = tester.ensureSemantics();
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('التقدم'));
    await tester.pumpAndSettle();
    expect(find.textContaining('لسه مسجّلتش أوزان'), findsOneWidget);

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();

    // Arabic digits and decimal mark, as a phone's Arabic keyboard types them.
    await tester.tap(find.bySemanticsLabel('المجموعة 1').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '٦٢٫٥');
    await tester.enterText(find.byType(TextField).last, '8');
    await tester.tap(find.text('حفظ المجموعة'));
    await tester.pumpAndSettle();

    // The second set starts from the first.
    await tester.tap(find.bySemanticsLabel('المجموعة 2').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('زوّد الوزن'));
    await tester.tap(find.text('حفظ المجموعة'));
    await tester.pumpAndSettle();
    expect(find.text(WorkoutService.ltr('62.5×8')), findsOneWidget);
    expect(find.text(WorkoutService.ltr('65×8')), findsOneWidget);

    await tester.tap(find.text('التقدم'));
    await tester.pumpAndSettle();
    expect(find.text('65 كجم'), findsOneWidget);

    await tester.tap(find.text('ضغط بار مستوي'));
    await tester.pumpAndSettle();
    expect(find.text('كل المرات'), findsOneWidget);
    // Once in today's sets and once in the history.
    expect(find.text(WorkoutService.ltr('65×8')), findsNWidgets(2));
    expect(find.text('مجموعتين'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('any picked exercise can be trained from its page', (tester) async {
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('التمارين'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('سكوات بلغاري'));
    await tester.tap(find.text('سكوات بلغاري'));
    await tester.pumpAndSettle();
    expect(find.text('تمرين النهارده'), findsOneWidget);

    await tester.tap(find.text('ابدأ · سجّل المجموعة 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ المجموعة'));
    await tester.pumpAndSettle();
    expect(find.text(WorkoutService.ltr('20×8')), findsWidgets);
    expect(find.text('سجّل المجموعة 2'), findsOneWidget);
    expect(find.text('الراحة'), findsOneWidget);

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    expect(find.text('ابدأ التمرين'), findsOneWidget, reason: "today's workout itself isn't started");
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('زيادة النهارده'), findsOneWidget);
    expect(find.text('سكوات بلغاري'), findsOneWidget);
  });

  testWidgets('a done set can be removed', (tester) async {
    final semantics = tester.ensureSemantics();
    await launch(tester, onboardingSeen: true);
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('المجموعة 1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ المجموعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('المجموعة 1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('شيل المجموعة'));
    await tester.pumpAndSettle();

    expect(find.text(WorkoutService.ltr('20×10')), findsNothing);
    expect(find.text('دوس على الدايرة وسجّل الوزن'), findsNWidgets(4));
    semantics.dispose();
  });

  testWidgets('a muscle on home opens only its exercises', (tester) async {
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('رجل'));
    await tester.pumpAndSettle();
    expect(find.text('اختر التمرين'), findsOneWidget);
    expect(find.text('سكوات'), findsOneWidget);
    expect(find.text('ضغط بار مستوي'), findsNothing);
    expect(find.text('ترايبس بالكابل'), findsNothing);
  });

  testWidgets('a muscle on the body screen opens its exercises straight away', (tester) async {
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();
    expect(find.text('عضلات الجسم'), findsOneWidget);

    await tester.ensureVisible(find.text('تمرين البطن'));
    await tester.tap(find.text('تمرين البطن'));
    await tester.pumpAndSettle();
    expect(find.text('عضلات الجسم'), findsNothing);
    expect(find.text('البلانك'), findsOneWidget);
    expect(find.text('سكوات'), findsNothing);
  });

  testWidgets('an exercise opens its own page, and home still opens the program', (tester) async {
    await launch(tester, onboardingSeen: true);

    await tester.tap(find.text('التمارين'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('سكوات'));
    await tester.tap(find.text('سكوات'));
    await tester.pumpAndSettle();
    expect(find.text('في برنامجك يوم اتنين · رجل'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('رجل متعلّم')), findsNWidgets(2));
    expect(find.text('عضلات الجسم'), findsNothing);

    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ التمرين'));
    await tester.pumpAndSettle();
    expect(find.text('برنامج التمرين'), findsOneWidget);
  });
}
