import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/src/vrouter_scope.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group(
    'urlHistoryBack',
    () {
      testWidgets(
        'LocalVRouterData urlHistoryBack should go -1 in the UrlHistory if it is possible',
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

          // Navigate to 'settings' to populate the urlHistory
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          // Try to call urlHistoryBack
          vRouterKey.currentState!.urlHistoryBack();
          await tester.pumpAndSettle();

          // Now we should be on '/' again
          expect(vRouterKey.currentState!.url, '/');
          expect(vWidget1Finder, findsOneWidget);
          expect(vWidget2Finder, findsNothing);
        },
      );

      testWidgets(
        'LocalVRouterData urlHistoryCanBack should return true if going -1 in the UrlHistory IS possible',
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

          // Navigate to 'settings' to populate the urlHistory
          // Tap the add button.
          await tester.tap(find.byType(TextButton));
          await tester.pumpAndSettle();

          expect(vRouterKey.currentState!.urlHistoryCanBack(), true);
        },
      );

      testWidgets(
        'LocalVRouterData urlHistoryCanBack should return false if going -1 in the UrlHistory IS possible',
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

          // Try to call urlHistoryBack
          expect(vRouterKey.currentState!.urlHistoryCanBack(), false);
        },
      );

      testWidgets(
        'LocalVRouterData urlHistoryBack should throw an error when going -1 in the UrlHistory is NOT possible',
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

          // Try to call urlHistoryBack
          expect(() => vRouterKey.currentState!.urlHistoryBack(), throwsA(isA<UrlHistoryNavigationError>()));
        },
      );
    },
  );

  group(
    'urlHistoryForward',
        () {
          testWidgets(
            'LocalVRouterData urlHistoryForward should go +1 in the UrlHistory if it is possible',
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

              // Navigate to 'settings' to populate the urlHistory
              // Tap the add button.
              await tester.tap(find.byType(TextButton));
              await tester.pumpAndSettle();

              // Call urlHistoryBack to go -1 in the urlHistory
              vRouterKey.currentState!.urlHistoryBack();
              await tester.pumpAndSettle();

              // Call urlHistoryForward to go +1 in the urlHistory
              vRouterKey.currentState!.urlHistoryForward();
              await tester.pumpAndSettle();

              // Now we should be on '/settings' again
              expect(vRouterKey.currentState!.url, '/settings');
              expect(vWidget1Finder, findsNothing);
              expect(vWidget2Finder, findsOneWidget);
            },
          );

          testWidgets(
            'LocalVRouterData urlHistoryForward should return true if going +1 in the UrlHistory IS possible',
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

              // Navigate to 'settings' to populate the urlHistory
              // Tap the add button.
              await tester.tap(find.byType(TextButton));
              await tester.pumpAndSettle();

              // Call urlHistoryBack to go -1 in the urlHistory
              vRouterKey.currentState!.urlHistoryBack();
              await tester.pumpAndSettle();

              expect(vRouterKey.currentState!.urlHistoryCanForward(), true);
            },
          );

      testWidgets(
        'LocalVRouterData urlHistoryForward should throw an error when going +1 in the UrlHistory is NOT possible',
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

          // Try to call urlHistoryForward
          expect(() => vRouterKey.currentState!.urlHistoryForward(), throwsA(isA<UrlHistoryNavigationError>()));
        },
      );

      testWidgets(
        'LocalVRouterData urlHistoryForward should return false if going +1 in the UrlHistory is NOT possible',
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

          // Try to call urlHistoryForward
          expect(vRouterKey.currentState!.urlHistoryCanForward(), false);
        },
      );
    },
  );
}
