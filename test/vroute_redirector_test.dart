import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VRouteRedirector used in routes', (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        routes: [
          VWidget(
            path: '/login',
            widget: Text('VWidget1'),
            stackedRoutes: [
              VWidget(
                path: '/settings',
                widget: Text('VWidget2'),
              ),
            ],
          ),
          VRouteRedirector(
            path: ':_(.*)',
            redirectTo: '/login',
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should have been redirected to '/login' so only VWidget 1 should be visible

    final vWidget1Finder = find.text('VWidget1');
    final vWidget2Finder = find.text('VWidget2');

    expect(vWidget1Finder, findsOneWidget);
    expect(vWidget2Finder, findsNothing);
  });

  testWidgets('VRouteRedirector used in a stackedRoute',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        initialUrl: '/home',
        routes: [
          VWidget(
            path: '/home',
            widget: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  child: Text('VWidget1'),
                  onPressed: () => VRouter.of(context).to('/home/settings'),
                );
              },
            ),
            stackedRoutes: [
              VWidget(
                path: 'settings',
                widget: Builder(
                  builder: (BuildContext context) {
                    return TextButton(
                      child: Text('VWidget2'),
                      onPressed: () => VRouter.of(context).to('/home/other'),
                    );
                  },
                ),
              ),
              VRouteRedirector(path: 'other', redirectTo: '/home/settings'),
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
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);

    // Navigate to '/other', and since no match be redirected to '/settings'
    // Tap the add button.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Only VWidget2 should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);
  });
}
