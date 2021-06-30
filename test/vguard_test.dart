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
                  beforeLeave: (vRedirector, _) async =>
                      vRedirector.stopRedirection(),
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');
      final vWidget3Finder = find.text('VWidget3');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.to('/settings');
      await tester.pumpAndSettle();

      // VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Try to navigate to '/other'
      // Tap the add button.
      vRouterKey.currentState!.to('/other');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('VGuard beforeUpdate', (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/random',
              widget: Container(),
              stackedRoutes: [
                VGuard(
                  beforeUpdate: (vRedirector) async =>
                      vRedirector.stopRedirection(),
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
                )
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

      // Try to navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.to('/settings');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget1 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
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
                  beforeEnter: (vRedirector) async =>
                      vRedirector.stopRedirection(),
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

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);

      // Try to navigate to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.to('/settings');
      await tester.pumpAndSettle();

      // The navigation must have been stopped, so VWidget1 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
    });

    testWidgets('VWidgetGuard afterUpdate', (WidgetTester tester) async {
      var count = 0;
      await tester.pumpWidget(
        VRouter(
          routes: [
            VGuard(
              afterEnter: (_, __, ___) => count = 1,
              afterUpdate: (_, __, ___) => count = 2,
              stackedRoutes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(path: 'settings', widget: Container()),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // We should start at '/' and afterEnter should be fired
      expect(count, 1);

      // We should go to '/settings' and afterUpdate should be fired
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(count, 2);
    });

    testWidgets('VWidgetGuard voidAfterUpdate', (WidgetTester tester) async {
      var count = 0;
      await tester.pumpWidget(
        VRouter(
          routes: [
            VGuard(
              afterEnter: (_, __, ___) => count = 1,
              stackedRoutes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(path: 'settings', widget: Container()),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // We should start at '/' and afterEnter should be fired
      expect(count, 1);

      // We should go to '/settings' and afterUpdate should be fired
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(count, 1);
    });
  });
}
