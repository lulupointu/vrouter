import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('Stacked VWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        routes: [
          VPage(
            path: '/',
            pageBuilder: (LocalKey key, Widget child, String? name) =>
                MaterialPage(key: key, child: child, name: name),
            widget: Builder(
              builder: (BuildContext context) => TextButton(
                child: Text('VWidget1'),
                onPressed: () => VRouter.of(context).to('/settings'),
              ),
            ),
            stackedRoutes: [
              VPage(
                path: '/settings',
                pageBuilder: (LocalKey key, Widget child, String? name) =>
                    MaterialPage(key: key, child: child, name: name),
                widget: Text('VWidget2'),
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/'

    final vWidget1Finder = find.text('VWidget1');
    final vWidget2Finder = find.text('VWidget2');

    expect(vWidget1Finder, findsOneWidget);
    expect(vWidget2Finder, findsNothing);

    // Try navigating to '/settings'
    // Tap the add button.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // The navigation should have been redirected to / because we popped instead
    // So only VWidget should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);
  });
}
