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
              subroutes: [
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
              subroutes: [
                VWidget(
                  widget: Container(),
                  path: 'other',
                  name: 'other',
                  subroutes: [
                    VWidget(
                      widget: Container(),
                      path: 'settings',
                      name: 'settings',
                    ),
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: 'aa',
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
    },
  );
}
