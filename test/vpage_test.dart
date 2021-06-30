import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VPage used in stackedRoutes stack', (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        routes: [
          VPage(
            path: '/',
            pageBuilder: (LocalKey key, Widget child, String? name) =>
                MaterialPage(key: key, child: child, name: name),
            widget: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Text('VWidget1'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => VRouter.of(context).to('/settings'),
                  ),
                );
              },
            ),
            stackedRoutes: [
              VWidget(
                path: '/settings',
                widget: Builder(
                  builder: (BuildContext context) {
                    return Scaffold(
                      body: Text('VWidget2'),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () => VRouter.of(context).pop(),
                      ),
                    );
                  },
                ),
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
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);

    // Pop to '/'
    // Tap the add button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget1 should be visible
    expect(vWidget1Finder, findsOneWidget);
    expect(vWidget2Finder, findsNothing);
  });
}
