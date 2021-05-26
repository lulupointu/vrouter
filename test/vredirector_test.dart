import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('vRedirector in VRouter beforeLeave', () {
    testWidgets('vRedirector.stopRedirection', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          beforeLeave: (vRedirector, _) async => vRedirector.stopRedirection(),
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => VRouter.of(context).push('/settings'),
                  child: Text('VWidget1'),
                ),
              ),
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

      // Try navigating to 'settings'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been stopped
      // so still only VWidget1 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
    });

    testWidgets('vRedirector.push', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          beforeLeave: (vRedirector, _) async =>
              (vRedirector.to != '/other') ? vRedirector.push('/other') : null,
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => VRouter.of(context).push('/settings'),
                  child: Text('VWidget1'),
                ),
              ),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Text('VWidget2'),
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

      // Try navigating to 'settings'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to /other
      // So only VWidget3 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);
    });

    testWidgets('vRedirector.pushSegments', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          beforeLeave: (vRedirector, _) async => (vRedirector.to != '/other')
              ? vRedirector.pushSegments(['other'])
              : null,
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => VRouter.of(context).push('/settings'),
                  child: Text('VWidget1'),
                ),
              ),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Text('VWidget2'),
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

      // Try navigating to 'settings'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to /other
      // So only VWidget3 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);
    });

    testWidgets('vRedirector.pop', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          initialUrl: '/settings',
          beforeLeave: (vRedirector, _) async =>
              (vRedirector.to != '/') ? vRedirector.pop() : null,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      onPressed: () => VRouter.of(context).push('/other'),
                      child: Text('VWidget2'),
                    ),
                  ),
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

      // At first we are on "/settings" (because we set initialUrl)
      // so only VWidget should be shown

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');
      final vWidget3Finder = find.text('VWidget3');

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Try navigating to '/other'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to / because we popped instead
      // So only VWidget should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('vRedirector.systemPop', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          initialUrl: '/settings',
          beforeLeave: (vRedirector, _) async =>
              (vRedirector.to != '/') ? vRedirector.systemPop() : null,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      onPressed: () => VRouter.of(context).push('/other'),
                      child: Text('VWidget2'),
                    ),
                  ),
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

      // At first we are on "/settings" (because we set initialUrl)
      // so only VWidget should be shown

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');
      final vWidget3Finder = find.text('VWidget3');

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Try navigating to '/other'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to / because we popped instead
      // So only VWidget1 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('vRedirector.pushNamed', (WidgetTester tester) async {

VLocations.tearDown();

      await tester.pumpWidget(
        VRouter(
          initialUrl: '/settings',
          beforeLeave: (vRedirector, _) async => (vRedirector.to != '/other')
              ? vRedirector.pushNamed('other')
              : null,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      onPressed: () => VRouter.of(context).push('/'),
                      child: Text('VWidget2'),
                    ),
                  ),
                ),
                VWidget(
                    path: '/other', widget: Text('VWidget3'), name: 'other'),
              ],
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/settings" (because we set initialUrl)
      // so only VWidget should be shown

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');
      final vWidget3Finder = find.text('VWidget3');

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Try navigating to '/'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to '/other'
      // So only VWidget should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);
    });
  });
}
