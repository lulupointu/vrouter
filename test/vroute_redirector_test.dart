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

    final vWidget1Finder1 = find.text('VWidget1');
    final vWidget2Finder1 = find.text('VWidget2');

    expect(vWidget1Finder1, findsOneWidget);
    expect(vWidget2Finder1, findsNothing);
  });

  testWidgets('VRouteRedirector used in a subRoute', (WidgetTester tester) async {
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
                  onPressed: () => VRouter.of(context).push('/home/settings'),
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
                      onPressed: () => VRouter.of(context).push('/home/other'),
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

    final vWidget1Finder1 = find.text('VWidget1');
    final vWidget2Finder1 = find.text('VWidget2');

    expect(vWidget1Finder1, findsOneWidget);
    expect(vWidget2Finder1, findsNothing);

    // Navigate to 'settings'
    // Tap the add button.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    final vWidget1Finder2 = find.text('VWidget1');
    final vWidget2Finder2 = find.text('VWidget2');

    expect(vWidget1Finder2, findsNothing);
    expect(vWidget2Finder2, findsOneWidget);

    // Navigate to '/other', and since no match be redirected to '/settings'
    // Tap the add button.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Only VWidget2 should be visible
    final vWidget1Finder3 = find.text('VWidget1');
    final vWidget2Finder3 = find.text('VWidget2');

    expect(vWidget1Finder3, findsNothing);
    expect(vWidget2Finder3, findsOneWidget);
  });
}
