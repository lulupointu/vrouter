import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VRouteRedirector used in routes', (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        routes: [
          VPage(
            path: '/',
            pageBuilder: (Widget child) => MaterialPage(child: child),
            widget: Builder(
              builder: (BuildContext context) => TextButton(
                child: Text('VWidget1'),
                onPressed: () => VRouter.of(context).push('/settings'),
              ),
            ),
            stackedRoutes: [
              VPage(
                path: '/settings',
                pageBuilder: (Widget child) => MaterialPage(child: child),
                widget: Text('VWidget2'),
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/'

    final vWidget1Finder1 = find.text('VWidget1');
    final vWidget2Finder1 = find.text('VWidget2');

    expect(vWidget1Finder1, findsOneWidget);
    expect(vWidget2Finder1, findsNothing);

    // Try navigating to '/settings'
    // Tap the add button.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // The navigation should have been redirected to / because we popped instead
    // So only VWidget should be visible
    final vWidget1Finder2 = find.text('VWidget1');
    final vWidget2Finder2 = find.text('VWidget2');

    expect(vWidget1Finder2, findsNothing);
    expect(vWidget2Finder2, findsOneWidget);
  });
}
