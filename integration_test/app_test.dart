import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:winhalla_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Verify login',
            (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(milliseconds: 5000));

          final Finder fab = find.text("Welcome to");
          expect(fab, findsOneWidget);

          // Emulate a tap on the floating action button.
          for (int i=0; i<10; i++){
            await tester.tap(fab);
            await tester.pumpAndSettle();
          }

          // Trigger a frame.
          await tester.pumpAndSettle();

          // Verify the counter increments by 1.
          await Future.delayed(const Duration(milliseconds: 5000),(){
            expect(find.text('Balance'), findsOneWidget);
          });
        });
  });
}