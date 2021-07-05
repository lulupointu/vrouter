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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.to('/settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VRouter pushSegments', (WidgetTester tester) async {
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.toSegments(['settings']);
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VRouter push relative', (WidgetTester tester) async {
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.to('settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VRouter pushSegments with encoding needed',
        (WidgetTester tester) async {
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
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.toSegments(['bob marley']);
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);

      // The url should be properly encoded
      expect(vRouterKey.currentState!.url, '/bob%20marley');

      // The path parameter should be decoded
      expect(vRouterKey.currentState!.pathParameters['id'], 'bob marley');
    });

    testWidgets('VRouter pop', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              key: ValueKey('VWidget1'),
              path: '/settings',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  key: ValueKey('VWidget2'),
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.systemPop();
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
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
                VWidget(
                    path: '/settings',
                    widget: Text('VWidget2'),
                    name: 'settings'),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.toNamed('settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VRouter pushNamed with path parameters',
        (WidgetTester tester) async {
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Navigate to 'settings'
      // Tap the add button.
      vRouterKey.currentState!.toNamed('settings', pathParameters: {'id': '1'});
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VRouter push with queryParameters',
        (WidgetTester tester) async {
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
      vRouterKey.currentState!.to('/', queryParameters: {'id': '3'});
      await tester.pumpAndSettle();

      expect(vRouterKey.currentState?.queryParameters['id'], '3');
    });
  });
}
