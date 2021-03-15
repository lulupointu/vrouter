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
                      name: 'other'
                    ),
                  ],
                ),
              ],
            );

            final newPath = vRouter
                .getPathFromName(
              elementToPop,
              remainingPathParameters: {},
              pathParameters: {},
              parentPath: null,
            )
                ?.path;

            expect(newPath, '/home');
          });


          test('Nested named', () {
            final elementToPop = VWidget(
              widget: Container(),
              path: '/settings',
              subroutes: [],
            );

            final vRouter = VRouter(
              routes: [
                VWidget(
                  widget: Container(),
                  path: '/home',
                  subroutes: [
                    elementToPop,
                    VWidget(
                      widget: Container(),
                      path: '/other',
                    ),
                  ],
                ),
              ],
            );

            final newPath = vRouter
                .getPathFromPop(
              elementToPop,
              pathParameters: {},
              parentPath: null,
            )
                ?.path;

            expect(newPath, '/home');
          });

    },
  );
}
