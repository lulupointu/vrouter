import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group(
    'historyBack',
    () {
      testWidgets(
        'LocalVRouterData historyBack should go -1 in the History if it is possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) => TextButton(
                          child: Text('VWidget2'),
                          onPressed: () => VRouter.of(context).to('/'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final vWidget1Finder = find.text('VWidget1');
          final vWidget2Finder = find.text('VWidget2');

          await tester.pumpAndSettle();

          // At first we are on "/" so only VWidget1 should be shown

          // Navigate to 'settings' to populate the history
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          // Try to call historyBack
          vRouterKey.currentState!.historyBack();
          await tester.pumpAndSettle();

          // Now we should be on '/' again
          expect(vRouterKey.currentState!.url, '/');
          expect(vWidget1Finder, findsOneWidget);
          expect(vWidget2Finder, findsNothing);
        },
      );

      testWidgets(
        'LocalVRouterData historyCanBack should return true if going -1 in the History IS possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) => TextButton(
                          child: Text('VWidget2'),
                          onPressed: () => VRouter.of(context).to('/'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // At first we are on "/" so only VWidget1 should be shown

          // Navigate to 'settings' to populate the history
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          expect(vRouterKey.currentState!.historyCanBack(), true);
        },
      );

      testWidgets(
        'LocalVRouterData historyCanBack should return false if going -1 in the History IS possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget1'),
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // Try to call historyBack
          expect(vRouterKey.currentState!.historyCanBack(), false);
        },
      );

      testWidgets(
        'LocalVRouterData historyBack should throw an error when going -1 in the History is NOT possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget1'),
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // Try to call historyBack
          expect(() => vRouterKey.currentState!.historyBack(),
              throwsA(isA<HistoryNavigationError>()));
        },
      );
    },
  );

  group(
    'historyForward',
    () {
      testWidgets(
        'LocalVRouterData historyForward should go +1 in the History if it is possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) => TextButton(
                          child: Text('VWidget2'),
                          onPressed: () => VRouter.of(context).to('/'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final vWidget1Finder = find.text('VWidget1');
          final vWidget2Finder = find.text('VWidget2');

          await tester.pumpAndSettle();

          // At first we are on "/" so only VWidget1 should be shown

          // Navigate to 'settings' to populate the history
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          // Call historyBack to go -1 in the history
          vRouterKey.currentState!.historyBack();
          await tester.pumpAndSettle();

          // Call historyForward to go +1 in the history
          vRouterKey.currentState!.historyForward();
          await tester.pumpAndSettle();

          // Now we should be on '/settings' again
          expect(vRouterKey.currentState!.url, '/settings');
          expect(vWidget1Finder, findsNothing);
          expect(vWidget2Finder, findsOneWidget);
        },
      );

      testWidgets(
        'LocalVRouterData historyForward should return true if going +1 in the History IS possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Builder(
                    builder: (BuildContext context) => TextButton(
                      child: Text('VWidget1'),
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  ),
                  stackedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) => TextButton(
                          child: Text('VWidget2'),
                          onPressed: () => VRouter.of(context).to('/'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // At first we are on "/" so only VWidget1 should be shown

          // Navigate to 'settings' to populate the history
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          // Call historyBack to go -1 in the history
          vRouterKey.currentState!.historyBack();
          await tester.pumpAndSettle();

          expect(vRouterKey.currentState!.historyCanForward(), true);
        },
      );

      testWidgets(
        'LocalVRouterData historyForward should throw an error when going +1 in the History is NOT possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget1'),
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // Try to call historyForward
          expect(() => vRouterKey.currentState!.historyForward(),
              throwsA(isA<HistoryNavigationError>()));
        },
      );

      testWidgets(
        'LocalVRouterData historyForward should return false if going +1 in the History is NOT possible',
        (WidgetTester tester) async {
          final vRouterKey = GlobalKey<VRouterState>();

          await tester.pumpWidget(
            VRouter(
              key: vRouterKey,
              routes: [
                VWidget(
                  path: '/',
                  widget: Text('VWidget1'),
                ),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // Try to call historyForward
          expect(vRouterKey.currentState!.historyCanForward(), false);
        },
      );
    },
  );
}
