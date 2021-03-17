import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VNesterPage test', (WidgetTester tester) async {
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
                    onPressed: () => VRouter.of(context).push('/other'),
                  ),
                );
              },
            ),
            stackedRoutes: [
              VNesterPage(
                pageBuilder: (Widget child) => MaterialPage(child: child),
                path: null,
                widgetBuilder: (child) => Builder(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(title: Text('Scaffold VNester')),
                      body: child,
                    );
                  },
                ),
                nestedRoutes: [
                  VWidget(
                    path: '/settings',
                    widget: Builder(
                      builder: (BuildContext context) {
                        return OutlinedButton(
                          onPressed: () => VRouter.of(context).pop(),
                          child: Text('VWidget2'),
                        );
                      },
                    ),
                    stackedRoutes: [
                      VWidget(
                        path: '/other',
                        widget: Builder(
                          builder: (BuildContext context) {
                            return OutlinedButton(
                              onPressed: () => VRouter.of(context).pop(),
                              child: Text('VWidget3'),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
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
    final vNesterFinder1 = find.text('Scaffold VNester');

    expect(vWidget1Finder1, findsOneWidget);
    expect(vNesterFinder1, findsNothing);
    expect(vWidget2Finder1, findsNothing);
    expect(vWidget3Finder1, findsNothing);

    // Navigate to '/other'
    // Tap the add button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    final vWidget1Finder2 = find.text('VWidget1');
    final vWidget2Finder2 = find.text('VWidget2');
    final vWidget3Finder2 = find.text('VWidget3');
    final vNesterFinder2 = find.text('Scaffold VNester');

    expect(vWidget1Finder2, findsNothing);
    expect(vNesterFinder2, findsOneWidget);
    expect(vWidget2Finder2, findsNothing);
    expect(vWidget3Finder2, findsOneWidget);

    // Pop to '/settings'
    // Tap the add button.
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    final vWidget1Finder3 = find.text('VWidget1');
    final vWidget2Finder3 = find.text('VWidget2');
    final vWidget3Finder3 = find.text('VWidget3');
    final vNesterFinder3 = find.text('Scaffold VNester');

    expect(vWidget1Finder3, findsNothing);
    expect(vNesterFinder3, findsOneWidget);
    expect(vWidget2Finder3, findsOneWidget);
    expect(vWidget3Finder3, findsNothing);

    // Pop to '/'
    // Tap the add button.
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    final vWidget1Finder4 = find.text('VWidget1');
    final vWidget2Finder4 = find.text('VWidget2');
    final vWidget3Finder4 = find.text('VWidget3');
    final vNesterFinder4 = find.text('Scaffold VNester');

    expect(vWidget1Finder4, findsOneWidget);
    expect(vNesterFinder4, findsNothing);
    expect(vWidget2Finder4, findsNothing);
    expect(vWidget3Finder4, findsNothing);
  });
}
