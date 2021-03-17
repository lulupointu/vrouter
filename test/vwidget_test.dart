import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VWidget used in stackedRoutes stack', (WidgetTester tester) async {
    await tester.pumpWidget(
      VRouter(
        routes: [
          VWidget(
            path: '/',
            widget: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Text('VWidget1'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => VRouter.of(context).push('/settings'),
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

    final vWidget1Finder1 = find.text('VWidget1');
    final vWidget2Finder1 = find.text('VWidget2');

    expect(vWidget1Finder1, findsOneWidget);
    expect(vWidget2Finder1, findsNothing);

    // Navigate to 'settings'
    // Tap the add button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    final vWidget1Finder2 = find.text('VWidget1');
    final vWidget2Finder2 = find.text('VWidget2');

    expect(vWidget1Finder2, findsNothing);
    expect(vWidget2Finder2, findsOneWidget);

    // Pop to '/'
    // Tap the add button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget1 should be visible
    final vWidget1Finder3 = find.text('VWidget1');
    final vWidget2Finder3 = find.text('VWidget2');

    expect(vWidget1Finder3, findsOneWidget);
    expect(vWidget2Finder3, findsNothing);
  });
}
