import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  group(
    'The following tests are used to test [VRouteElement.getPathFromName]',
    () {
      test('Basic named', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              name: 'home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: '/other',
                  name: 'other',
                ),
              ],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'home',
          remainingPathParameters: {},
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, ValidNameResult);
        expect((newPath as ValidNameResult).path, '/home');
      });

      test('Nested named', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              name: 'home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: 'other',
                  name: 'other',
                  stackedRoutes: [
                    VWidget(
                      widget: Container(),
                      path: 'settings',
                      name: 'settings',
                    ),
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: 'random',
                ),
              ],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'other',
          remainingPathParameters: {},
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, ValidNameResult);
        expect((newPath as ValidNameResult).path, '/home/other');
      });

      test('Named with path parameters', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home/:id',
              name: 'home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: 'settings/:settingsId',
                  name: 'settings',
                )
              ],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'settings',
          remainingPathParameters: {'id': '2', 'settingsId': '3'},
          pathParameters: {'id': '2', 'settingsId': '3'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, ValidNameResult);
        expect((newPath as ValidNameResult).path, '/home/2/settings/3');
      });

      test('Named with missing path parameters', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home/:id',
              name: 'home',
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'home',
          remainingPathParameters: {},
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, PathParamsErrorsNameResult);
        expect((newPath as PathParamsErrorsNameResult).values.length, 1);
        expect(newPath.values.first.runtimeType, MissingPathParamsError);
        expect((newPath.values.first as MissingPathParamsError).pathParams, []);
        expect(
            (newPath.values.first as MissingPathParamsError).missingPathParams,
            ['id']);
      });

      test('Named with missing path parameters in two stacked VRouteElement',
          () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home/:id',
              stackedRoutes: [
                VWidget(
                    widget: Container(),
                    path: '/settings/:otherId',
                    name: 'settings'),
              ],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'settings',
          remainingPathParameters: {'id': '2'},
          pathParameters: {'id': '2'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, PathParamsErrorsNameResult);
        expect((newPath as PathParamsErrorsNameResult).values.length, 1);
        expect(newPath.values.first.runtimeType, MissingPathParamsError);
        expect((newPath.values.first as MissingPathParamsError).pathParams,
            ['id']);
        expect(
            (newPath.values.first as MissingPathParamsError).missingPathParams,
            ['otherId']);
      });

      test('Named with too much path parameters', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              name: 'home',
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'home',
          remainingPathParameters: {'id': '2'},
          pathParameters: {'id': '2'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, PathParamsErrorsNameResult);
        expect((newPath as PathParamsErrorsNameResult).values.length, 1);
        expect(newPath.values.first.runtimeType, OverlyPathParamsError);
        expect(
            (newPath.values.first as OverlyPathParamsError).pathParams, ['id']);
        expect(
            (newPath.values.first as OverlyPathParamsError).expectedPathParams,
            []);
      });

      test('Named with too much path parameters with absolute stacked route',
          () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home/:id',
              name: 'home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: '/settings/:settingsId',
                  name: 'settings',
                )
              ],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'settings',
          remainingPathParameters: {'id': '2', 'settingsId': '3'},
          pathParameters: {'id': '2', 'settingsId': '3'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, PathParamsErrorsNameResult);
        expect((newPath as PathParamsErrorsNameResult).values.length, 1);
        expect(newPath.values.first.runtimeType, OverlyPathParamsError);
        expect(
          (newPath.values.first as OverlyPathParamsError).pathParams,
          ['id', 'settingsId'],
        );
        expect(
          (newPath.values.first as OverlyPathParamsError).expectedPathParams,
          ['settingsId'],
        );
      });

      test('Named and aliases', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              name: 'home',
              aliases: ['/:id/:otherId', '/:id'],
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'home',
          remainingPathParameters: {'id': '2'},
          pathParameters: {'id': '2'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, ValidNameResult);
        expect((newPath as ValidNameResult).path, '/2');
      });

      test('Absent name', () {
        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              name: 'home',
            ),
          ],
        );

        final newPath = vRouter.getPathFromName(
          'random',
          remainingPathParameters: {'id': '2'},
          pathParameters: {'id': '2'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPath.runtimeType, NotFoundErrorNameResult);
      });
    },
  );
}
