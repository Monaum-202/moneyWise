import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MoneywiseApp(),
      ),
    );

    // Verify that we are on the dashboard
    expect(find.text('Dashboard'), findsWidgets);
  });
}
