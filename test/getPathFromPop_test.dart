import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  group(
    'The following tests are used to test [VRouteElement.getPathFromPop]',
    () {
      test('Pop from absolute path to absolute path', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: '/settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/',
              stackedRoutes: [
                elementToPop,
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/');
      });

      test('Pop from relative path to absolute path', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: 'settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              stackedRoutes: [
                elementToPop,
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/home');
      });

      test('Pop from absolute path to relative path', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: '/settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: 'profile',
                  stackedRoutes: [
                    elementToPop,
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/home/profile');
      });

      test('Pop from relative path to relative path', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: 'settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: 'profile',
                  stackedRoutes: [
                    elementToPop,
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/home/profile');
      });

      test('Pop last element', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: '/home',
        );

        final vRouter = VRouter(
          routes: [
            elementToPop,
            VWidget(
              widget: Container(),
              path: '/other',
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, PoppingPopResult);
      });

      test('Pop with right pathParameters', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: 'settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: ':profileId',
                  stackedRoutes: [
                    elementToPop,
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {'profileId': '2'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/home/2');
      });

      test('Pop with wrong pathParameters', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: 'settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/home',
              stackedRoutes: [
                VWidget(
                  widget: Container(),
                  path: ':profileId',
                  stackedRoutes: [
                    elementToPop,
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, PathParamsPopErrors);
        expect((newPathResult as PathParamsPopErrors).values.length, 1);
        expect(newPathResult.values.first.pathParams, []);
        expect(newPathResult.values.first.missingPathParams, ['profileId']);
      });

      test('Pop through VNester with wrong pathParameters', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: 'settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: ':userId',
              stackedRoutes: [
                VNester(
                  widgetBuilder: (_) => Container(),
                  path: '/home',
                  nestedRoutes: [
                    elementToPop,
                  ],
                ),
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, PathParamsPopErrors);
        expect((newPathResult as PathParamsPopErrors).values.length, 1);
        expect(newPathResult.values.first.pathParams, []);
        expect(newPathResult.values.first.missingPathParams, ['userId']);
      });

      test(
        'Pop though VGuard'
        'Every VRouteElement which does not have a page to display should pop along side its subroute VRouteElement',
        () {
          final elementToPop = VWidget(
            widget: Container(),
            path: 'settings',
          );

          final vRouter = VRouter(
            routes: [
              VWidget(
                widget: Container(),
                path: '/home',
                stackedRoutes: [
                  VGuard(
                    stackedRoutes: [
                      elementToPop,
                    ],
                  ),
                  VWidget(
                    widget: Container(),
                    path: '/other',
                  ),
                ],
              ),
            ],
          );

          final newPathResult = vRouter.getPathFromPop(
            elementToPop,
            pathParameters: {},
            parentPathResult:
                ValidParentPathResult(path: null, pathParameters: {}),
          );

          expect(newPathResult.runtimeType, ValidPopResult);
          expect((newPathResult as ValidPopResult).path, '/home');
        },
      );

      test(
        'Pop though VPopHandler'
        'Every VRouteElement which does not have a page to display should pop along side its subroute VRouteElement',
        () {
          final elementToPop = VWidget(
            widget: Container(),
            path: 'settings',
          );

          final vRouter = VRouter(
            routes: [
              VWidget(
                widget: Container(),
                path: '/home',
                stackedRoutes: [
                  VPopHandler(
                    stackedRoutes: [
                      elementToPop,
                    ],
                  ),
                  VWidget(
                    widget: Container(),
                    path: '/other',
                  ),
                ],
              ),
            ],
          );

          final newPathResult = vRouter.getPathFromPop(
            elementToPop,
            pathParameters: {},
            parentPathResult:
                ValidParentPathResult(path: null, pathParameters: {}),
          );

          expect(newPathResult.runtimeType, ValidPopResult);
          expect((newPathResult as ValidPopResult).path, '/home');
        },
      );

      test(
        'Pop though VNester'
        'VNester should pop if it does not have a nested child',
        () {
          final elementToPop = VWidget(
            widget: Container(),
            path: 'settings',
          );

          final vRouter = VRouter(
            routes: [
              VWidget(
                widget: Container(),
                path: '/home',
                stackedRoutes: [
                  VNester(
                    path: 'nested',
                    widgetBuilder: (child) => Container(child: child),
                    nestedRoutes: [
                      elementToPop,
                    ],
                  ),
                  VWidget(
                    widget: Container(),
                    path: '/other',
                  ),
                ],
              ),
            ],
          );

          final newPathResult = vRouter.getPathFromPop(
            elementToPop,
            pathParameters: {},
            parentPathResult:
                ValidParentPathResult(path: null, pathParameters: {}),
          );

          expect(newPathResult.runtimeType, ValidPopResult);
          expect((newPathResult as ValidPopResult).path, '/home');
        },
      );

      test('Pop and aliases', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: '/settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: ':id',
              aliases: ['/home'],
              stackedRoutes: [
                elementToPop,
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/home');
      });

      test('Pop and pathParameters', () {
        final elementToPop = VWidget(
          widget: Container(),
          path: '/settings',
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/:id',
              aliases: ['/home'],
              stackedRoutes: [
                elementToPop,
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {'id': '1'},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/1');
      });

      test('Pop which includes a null path', () {
        final elementToPop = VWidget(
          path: '/other',
          widget: Container(),
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Container(),
              stackedRoutes: [
                VNester(
                  path: null,
                  widgetBuilder: (child) => Container(
                    child: child,
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Container(),
                      stackedRoutes: [
                        elementToPop,
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/settings');
      });

      test('Pop VNester', () {
        final elementToPop = VNester(
          widgetBuilder: (child) => Container(),
          path: null,
          nestedRoutes: [
            VWidget(path: '/settings', widget: Container()),
          ],
        );

        final vRouter = VRouter(
          routes: [
            VWidget(
              widget: Container(),
              path: '/',
              stackedRoutes: [
                elementToPop,
                VWidget(
                  widget: Container(),
                  path: '/other',
                ),
              ],
            ),
          ],
        );

        final newPathResult = vRouter.getPathFromPop(
          elementToPop,
          pathParameters: {},
          parentPathResult:
              ValidParentPathResult(path: null, pathParameters: {}),
        );

        expect(newPathResult.runtimeType, ValidPopResult);
        expect((newPathResult as ValidPopResult).path, '/');
      });
    },
  );
}
