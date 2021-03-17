import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VRouter', () {
    testWidgets('VGuard onPop', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/settings',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VPopHandler(
                  onPop: (vRedirector) async => vRedirector.stopRedirection(),
                  stackedRoutes: [
                    VWidget(
                      path: '/',
                      widget: Text('VWidget2'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget2 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsNothing);
      expect(vWidget2Finder1, findsOneWidget);

      // Try to pop
      // Tap the add button.
      vRouterKey.currentState!.pop();
      await tester.pumpAndSettle();

      // pop should have been prevented, to VWidget2 should still be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
    });

    testWidgets('VGuard onSystemPop', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/settings',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VPopHandler(
                  onSystemPop: (vRedirector) async => vRedirector.stopRedirection(),
                  stackedRoutes: [
                    VWidget(
                      path: '/',
                      widget: Text('VWidget2'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget2 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsNothing);
      expect(vWidget2Finder1, findsOneWidget);

      // Try to pop
      // Tap the add button.
      vRouterKey.currentState!.systemPop();
      await tester.pumpAndSettle();

      // pop should have been prevented, to VWidget2 should still be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
    });
  });
}
