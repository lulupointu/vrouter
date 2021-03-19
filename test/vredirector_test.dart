import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('vRedirector in VRouter beforeLeave', () {
    testWidgets('vRedirector.stopRedirection', (WidgetTester tester) async {
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

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);

      // Try navigating to 'settings'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been stopped
      // so still only VWidget1 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
    });

    testWidgets('vRedirector.push', (WidgetTester tester) async {
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

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');
      final vWidget3Finder1 = find.text('VWidget3');

      expect(vWidget1Finder1, findsOneWidget);
      expect(vWidget2Finder1, findsNothing);
      expect(vWidget3Finder1, findsNothing);

      // Try navigating to 'settings'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to /other
      // So only VWidget3 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');
      final vWidget3Finder2 = find.text('VWidget3');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsNothing);
      expect(vWidget3Finder2, findsOneWidget);
    });

    testWidgets('vRedirector.pop', (WidgetTester tester) async {
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

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');
      final vWidget3Finder1 = find.text('VWidget3');

      expect(vWidget1Finder1, findsNothing);
      expect(vWidget2Finder1, findsOneWidget);
      expect(vWidget3Finder1, findsNothing);

      // Try navigating to '/other'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to / because we popped instead
      // So only VWidget should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');
      final vWidget3Finder2 = find.text('VWidget3');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
      expect(vWidget3Finder2, findsNothing);
    });

    testWidgets('vRedirector.systemPop', (WidgetTester tester) async {
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

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');
      final vWidget3Finder1 = find.text('VWidget3');

      expect(vWidget1Finder1, findsNothing);
      expect(vWidget2Finder1, findsOneWidget);
      expect(vWidget3Finder1, findsNothing);

      // Try navigating to '/other'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to / because we popped instead
      // So only VWidget1 should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');
      final vWidget3Finder2 = find.text('VWidget3');

      expect(vWidget1Finder2, findsOneWidget);
      expect(vWidget2Finder2, findsNothing);
      expect(vWidget3Finder2, findsNothing);
    });

    testWidgets('vRedirector.pushNamed', (WidgetTester tester) async {
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

      final vWidget1Finder1 = find.text('VWidget1');
      final vWidget2Finder1 = find.text('VWidget2');
      final vWidget3Finder1 = find.text('VWidget3');

      expect(vWidget1Finder1, findsNothing);
      expect(vWidget2Finder1, findsOneWidget);
      expect(vWidget3Finder1, findsNothing);

      // Try navigating to '/'
      // Tap the add button.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The navigation should have been redirected to '/other'
      // So only VWidget should be visible
      final vWidget1Finder2 = find.text('VWidget1');
      final vWidget2Finder2 = find.text('VWidget2');
      final vWidget3Finder2 = find.text('VWidget3');

      expect(vWidget1Finder2, findsNothing);
      expect(vWidget2Finder2, findsNothing);
      expect(vWidget3Finder2, findsOneWidget);
    });
  });
}
