import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
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
          parentPath: null,
        );

        expect(newPath, '/home');
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
          parentPath: null,
        );

        expect(newPath, '/home/other');
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
          parentPath: null,
        );

        expect(newPath, '/home/2/settings/3');
      });

      test('Named with wrong path parameters', () {
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
          parentPath: null,
        );

        expect(newPath, null);

        final vRouter2 = VRouter(
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

        final newPath2 = vRouter2.getPathFromName(
          'settings',
          remainingPathParameters: {'id': '2', 'settingsId': '3'},
          pathParameters: {'id': '2', 'settingsId': '3'},
          parentPath: null,
        );

        expect(newPath2, null);
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
          parentPath: null,
        );

        expect(newPath, '/2');
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
          parentPath: null,
        );

        expect(newPath, null);
      });
    },
  );
}
