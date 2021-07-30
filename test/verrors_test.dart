import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VError', () {
    testWidgets("InvalidPushVError", (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      var caughtError;
      FlutterError.onError = (e) => caughtError = e.exception;
      final vRouter = VRouter(
        initialUrl: 'settings',
        key: vRouterKey,
        routes: [
          VWidget(path: '/settings', widget: Text('VWidget1')),
        ],
      );
      await tester.pumpWidget(
        vRouter,
      );

      expect(caughtError.runtimeType, InvalidUrlVError);

      // Test the output error string
      expect(
          caughtError.toString(),
          "The current url is null but you are trying to access the path \"settings\" which does not start with '/'.\n"
          "This is likely because you set a initialUrl which does not start with '/'.");
    });

    testWidgets("UnknownUrlVError", (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(path: '/', widget: Text('VWidget1')),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!.to('/settings');
      }, (Object error, StackTrace stack) {
        // After toing, we should get a UnknownUrlVError
        expect(error, isInstanceOf<UnknownUrlVError>());

        // Test the output error string
        expect(
            error.toString(),
            "The url '/settings' has no matching route.\n"
            "Consider using VWidget(path: '*', widget: UnknownPathWidget()) at the bottom of your VRouter routes to catch any wrong route.");
      });
    });

    testWidgets("NotFoundErrorNameResult", (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(path: '/', widget: Text('VWidget1')),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!.toNamed('random');
      }, (Object error, StackTrace stack) {
        // After toing, we should get a NotFoundErrorNameResult
        expect(error, isInstanceOf<NotFoundErrorNameResult>());

        // Test the output error string
        expect(
            error.toString(), 'Could not find the VRouteElement named random.');
      });
    });

    testWidgets("PathParamsErrorsNameResult with MissingPathParamsError",
        (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(path: '/', widget: Text('VWidget1')),
              VWidget(path: '/:id', widget: Text('VWidget2'), name: 'id'),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!.toNamed('id');
      }, (Object error, StackTrace stack) {
        // After toing, we should get a PathParamsErrorsNameResult
        expect(error, isInstanceOf<PathParamsErrorsNameResult>());
        expect((error as PathParamsErrorsNameResult).values.length, 1);
        expect(error.values.first, isInstanceOf<MissingPathParamsError>());
        expect((error.values.first as MissingPathParamsError).missingPathParams,
            ['id']);
        expect((error.values.first as MissingPathParamsError).pathParams, []);

        // Test the output error string
        expect(
            error.toString(),
            'Could not find value route for name id because of path parameters. \n'
                    'Here are the possible path parameters that were expected compared to what you gave:\n' +
                '  - Path parameters given: [], missing: [id]');
      });
    });

    testWidgets("NullPathErrorNameResult", (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(path: '/', widget: Text('VWidget1')),
              VWidget(path: null, widget: Text('VWidget2'), name: 'id'),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!.toNamed('id');
      }, (Object error, StackTrace stack) {
        // After toing, we should get a PathParamsErrorsNameResult
        expect(error, isInstanceOf<NullPathErrorNameResult>());

        // Test the output error string
        expect(
            error.toString(),
            'The VRouteElement named id as a null path but no parent VRouteElement with a path.\n'
            'No valid path can therefore be formed.');
      });
    });

    testWidgets("PathParamsErrorsNameResult with OverlyPathParamsError",
        (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(path: '/', widget: Text('VWidget1')),
              VWidget(
                  path: '/settings',
                  widget: Text('VWidget2'),
                  name: 'settings'),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!
            .toNamed('settings', pathParameters: {'id': '1'});
      }, (Object error, StackTrace stack) {
        // After toing, we should get a PathParamsErrorsNameResult
        expect(error, isInstanceOf<PathParamsErrorsNameResult>());
        expect((error as PathParamsErrorsNameResult).values.length, 1);
        expect(error.values.first, isInstanceOf<OverlyPathParamsError>());
        expect((error.values.first as OverlyPathParamsError).expectedPathParams,
            []);
        expect(
            (error.values.first as OverlyPathParamsError).pathParams, ['id']);

        // Test the output error string
        expect(
            error.toString(),
            'Could not find value route for name settings because of path parameters. \n'
                    'Here are the possible path parameters that were expected compared to what you gave:\n' +
                '  - Path parameters given: [id], expected: []');
      });
    });

    testWidgets("PathParamsPopErrors", (WidgetTester tester) async {
      runZonedGuarded(() async {
        final vRouterKey = GlobalKey<VRouterState>();

        await tester.pumpWidget(
          VRouter(
            key: vRouterKey,
            routes: [
              VWidget(
                path: '/:id',
                widget: Text('VWidget2'),
                stackedRoutes: [
                  VWidget(path: '/', widget: Text('VWidget1')),
                ],
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        vRouterKey.currentState!.pop();
      }, (Object error, StackTrace stack) {
        // After toing, we should get a PathParamsErrorsNameResult
        expect(error, isInstanceOf<PathParamsPopErrors>());
        expect((error as PathParamsPopErrors).values.length, 1);
        expect(error.values.first, isInstanceOf<MissingPathParamsError>());
        expect(error.values.first.missingPathParams, ['id']);
        expect(error.values.first.pathParams, []);

        // Test the output error string
        expect(
            error.toString(),
            'Could not pop because some path parameters where missing. \n'
            'Here are the possible path parameters that were expected and the missing ones:\n'
            '  - Expected path parameters: [], missing ones: [id]');
      });
    });
  });
}
