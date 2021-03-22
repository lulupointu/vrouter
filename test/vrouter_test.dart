import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VRouter', () {
    testWidgets('VRouter push', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
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
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.push('/settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
    });

    testWidgets('VRouter pop', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/settings',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget2'),
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

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
    });

    testWidgets('VRouter systemPop', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/settings',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget2'),
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

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.systemPop();
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
    });

    testWidgets('VRouter pushNamed', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(path: '/settings', widget: Text('VWidget2'), name: 'settings'),
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

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.pushNamed('settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
    });

    testWidgets('VRouter pushNamed with path parameters', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/:id',
                  widget: Text('VWidget2'),
                  name: 'settings',
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

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.pushNamed('settings', pathParameters: {'id': '1'});
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsOneWidget);
    });

    testWidgets('VRouter push with queryParameters', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(path: '/', widget: Text('VWidget1')),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.push('/', queryParameters: {'id': '3'});
      await tester.pumpAndSettle();

      expect(vRouterKey.currentState?.queryParameters['id'], '3');
    });
  });
}
