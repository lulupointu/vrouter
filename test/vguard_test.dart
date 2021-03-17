import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VRouter', () {
    testWidgets('VGuard beforeLeave', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VGuard(
                  beforeLeave: (vRedirector, _) async => vRedirector.stopRedirection(),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Text('VWidget2'),
                    ),
                  ],
                ),
                VWidget(
                  path: '/other',
                  widget: Text('VWidget3'),
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');
      final vWidget3Finder1 = find.text('VWidget3');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);
      expect(vWidget3Finder1, findsNothing);

      // Navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.push('/settings');
      await tester.pumpAndSettle();

      // VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');
      final vWidget3Finder2 = find.text('VWidget3');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
      expect(vWidget3Finder2, findsNothing);

      // Try to navigate to '/other'
      // Tap the add button.
      vRouterKey.currentState!.push('/other');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget2 should be visible
      final vWidget1Finder3 = find.text('VWidget1');
      final vWidget2Finder3 = find.text('VWidget2');
      final vWidget3Finder3 = find.text('VWidget3');

      expect(vWidget1Finder3, findsNothing);
      expect(vWidget2Finder3, findsOneWidget);
      expect(vWidget3Finder3, findsNothing);
    });

    testWidgets('VGuard beforeUpdate', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VGuard(
              beforeUpdate: (vRedirector) async => vRedirector.stopRedirection(),
              stackedRoutes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget1'),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
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

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);

      // Try to navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.push('/settings');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget1 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
    });

    testWidgets('VGuard beforeEnter', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VGuard(
                  beforeEnter: (vRedirector) async => vRedirector.stopRedirection(),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Text('VWidget2'),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);

      // Try to navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.push('/settings');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget1 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
    });
  });
}
