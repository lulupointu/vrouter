import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  group('Testing VNavigator.to through VRouterState.to', () {
    final routerKey = GlobalKey<VRouterState>();

    testWidgets('to', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          key: routerKey,
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VWidget(
                  path: '/settings',
                  widget: Text('VWidget2'),
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
      routerKey.currentState!.to('/settings');
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets(
      'to with query parameters with to.queryParameters',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          VRouter(
            key: routerKey,
            routes: [
              VWidget(
                path: '/',
                widget: Container(),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Use to.queryParameters
        routerKey.currentState!.to(
          '/',
          queryParameters: {'foo': 'bar'},
        );
        await tester.pumpAndSettle();

        // expect
        expect(
            routerKey.currentState!.queryParameters.containsKey('foo'), true);
        expect(routerKey.currentState!.queryParameters['foo'], 'bar');
      },
    );

    testWidgets(
      'to with query parameters included in path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          VRouter(
            key: routerKey,
            routes: [
              VWidget(
                path: '/',
                widget: Container(),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Use to.queryParameters
        routerKey.currentState!.to('/?foo=bar');
        await tester.pumpAndSettle();

        // expect
        expect(
            routerKey.currentState!.queryParameters.containsKey('foo'), true);
        expect(routerKey.currentState!.queryParameters['foo'], 'bar');
      },
    );

    testWidgets(
      'to with query parameters in to.queryParameters AND included in path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          VRouter(
            key: routerKey,
            routes: [
              VWidget(
                path: '/',
                widget: Container(),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Use to.queryParameters
        void to() => routerKey.currentState!
            .to('/?foo=bar', queryParameters: {'foo2': 'bar2'});

        // expect
        expect(to, throwsA(isA<AssertionError>()));
      },
    );
  });
}
