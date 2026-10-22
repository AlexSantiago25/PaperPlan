import 'package:flutter_test/flutter_test.dart';
import 'package:loot_room/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PaperPlanApp renders HubScreen with title and stats', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PaperPlanApp());
    // Pump frames to let provider load seed data and finish loading state
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('PaperPlan 📝'), findsOneWidget);
    expect(find.text('+ Nueva Zona'), findsOneWidget);
    expect(find.text('Zonas y Planos Dibujados'), findsOneWidget);
    expect(find.text('🗺️ Ver Plano de la Casa'), findsOneWidget);
  });

  testWidgets('Can navigate into HouseBlueprintScreen and toggle modes', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PaperPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // Tap on blueprint banner
    await tester.tap(find.text('🗺️ Ver Plano de la Casa'));
    await tester.pumpAndSettle();

    expect(find.text('Plano de la Casa'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);

    // Toggle to architect mode
    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();

    expect(find.text('Arquitecto'), findsOneWidget);
  });
}
