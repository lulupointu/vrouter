import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group(
      'Navigator 1 tests\n'
      'Test whether actions that used Navigator 1 are registered and that VRouter interact appropriately with them',
      () {
    testWidgets("Navigator.to", (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (context) => Material(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Text('MaterialPageRoute'),
                      ),
                    ),
                    child: Text('VWidget1'),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // At first we are on "/" so only VWidget1 should be shown

      final vWidget1Finder = find.text('VWidget1');
      final materialPageRouteFinder = find.text('MaterialPageRoute');

      expect(vWidget1Finder, findsOneWidget);
      expect(materialPageRouteFinder, findsNothing);

      // Reveal the MaterialPageRoute
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Only MaterialPageRoute should now be visible
      expect(vWidget1Finder, findsNothing);
      expect(materialPageRouteFinder, findsOneWidget);

      // Simulate a back button press
      await vRouterKey.currentState!.systemPop();
      await tester.pumpAndSettle();

      // MaterialPageRoute should have popped, revealing VWidget1
      expect(vWidget1Finder, findsOneWidget);
      expect(materialPageRouteFinder, findsNothing);
    });

    // testWidgets("Navigator.to in nested route", (WidgetTester tester) async {
    //   final vRouterKey = GlobalKey<VRouterState>();
    //
    //   await tester.pumpWidget(
    //     VRouter(
    //       key: vRouterKey,
    //       routes: [
    //         VNester(
    //           path: '/settings',
    //           widgetBuilder: (child) => Scaffold(
    //             body: child,
    //             bottomNavigationBar: Text('BottomNavigationBar'),
    //           ),
    //           nestedRoutes: [
    //             VWidget(
    //               path: '/',
    //               widget: Builder(
    //                 builder: (context) => Material(
    //                   child: InkWell(
    //                     onTap: () => Navigator.of(context).to(
    //                       MaterialPageRoute(
    //                         builder: (context) => Text('MaterialPageRoute'),
    //                       ),
    //                     ),
    //                     child: Text('VWidget1'),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   );
    //
    //   await tester.pumpAndSettle();
    //
    //   // At first we are on "/" so VWidget1 and the BNB should be shown
    //
    //   final vWidget1Finder = find.text('VWidget1');
    //   final bottomNavigationBarFinder = find.text('BottomNavigationBar');
    //   final materialPageRouteFinder = find.text('MaterialPageRoute');
    //
    //   expect(vWidget1Finder, findsOneWidget);
    //   expect(bottomNavigationBarFinder, findsOneWidget);
    //   expect(materialPageRouteFinder, findsNothing);
    //
    //   // Reveal the MaterialPageRoute
    //   await tester.tap(find.byType(InkWell));
    //   await tester.pumpAndSettle();
    //
    //   // The MaterialPageRoute should hide the scaffold body
    //   expect(vWidget1Finder, findsNothing);
    //   expect(bottomNavigationBarFinder, findsOneWidget);
    //   expect(materialPageRouteFinder, findsOneWidget);
    //
    //   // Simulate a back button press
    //   await vRouterKey.currentState!.systemPop();
    //   await tester.pumpAndSettle();
    //
    //   // MaterialPageRoute should have popped, revealing VWidget1
    //   expect(vWidget1Finder, findsOneWidget);
    //   expect(bottomNavigationBarFinder, findsOneWidget);
    //   expect(materialPageRouteFinder, findsNothing);
    // });

    // testWidgets(
    //   "Navigator.to in nested route using rootNavigator",
    //   (WidgetTester tester) async {
    //   },
    // );
  });
}
