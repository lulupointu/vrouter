import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  group('VNester', () {
    testWidgets('VNester pop', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).to('/other'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: null,
                  aliases: ['scaffold'],
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => VRouter.of(context).pop(),
                            child: Text('VWidget2'),
                          );
                        },
                      ),
                      stackedRoutes: [
                        VWidget(
                          path: '/other',
                          widget: Builder(
                            builder: (BuildContext context) {
                              return OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('VWidget3'),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
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
      final vWidget3Finder = find.text('VWidget3');
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/other'
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);

      // Pop to '/settings'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Pop to '/'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('VNester systemPop', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).to('/settings'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: null,
                  aliases: ['scaffold'],
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => VRouter.of(context).systemPop(),
                            child: Text('VWidget2'),
                          );
                        },
                      ),
                    ),
                  ],
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
      final vWidget3Finder = find.text('VWidget3');
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/settings'
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // systemPop to '/'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget1 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('VNester pop on alias', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).to('/other'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: ':id(\d+)',
                  // key: ValueKey('/settings'),
                  aliases: ['/settings'],
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: null,
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => VRouter.of(context).pop(),
                            child: Text('VWidget2'),
                          );
                        },
                      ),
                      stackedRoutes: [
                        VWidget(
                          path: '/other',
                          widget: Builder(
                            builder: (BuildContext context) {
                              return OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('VWidget3'),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
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
      final vWidget3Finder = find.text('VWidget3');
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/other'
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);

      // Pop to '/settings'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Pop to '/'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('VNester with stacked route', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () =>
                          VRouter.of(context).to('/settings/other'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: '/settings',
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: null,
                      aliases: [':_(.*)'],
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('VWidget2'),
                          );
                        },
                      ),
                    ),
                  ],
                  stackedRoutes: [
                    VWidget(
                      path: 'other',
                      widget: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            onPressed: () => VRouter.of(context).pop(),
                            child: Text('VWidget3'),
                          );
                        },
                      ),
                    )
                  ],
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
      final vWidget3Finder = find.text('VWidget3');
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);

      // Navigate to '/settings/other'
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);

      // Pop to '/settings'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);

      // Pop to '/'
      // Tap the add button.
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('VNester named', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).toNamed('settings'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: '/settings',
                  name: 'settings',
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: null,
                      widget: Text('VWidget2'),
                    ),
                  ],
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
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);

      // Navigate to '/settings' by name
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VNester named with alias default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).toNamed('settings'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: '/:id',
                  name: 'settings',
                  aliases: ['/settings'],
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: null,
                      widget: Text('VWidget2'),
                    ),
                  ],
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
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);

      // Navigate to '/settings' by name
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets('VNester with alias', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: Text('VWidget1'),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () => VRouter.of(context).to('/settings/2'),
                    ),
                  );
                },
              ),
              stackedRoutes: [
                VNester(
                  path: '/settings',
                  aliases: ['/settings/:id'],
                  widgetBuilder: (child) => Builder(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Scaffold VNester')),
                        body: child,
                      );
                    },
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: null,
                      widget: Text('VWidget2'),
                    ),
                  ],
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
      final vNesterFinder = find.text('Scaffold VNester');

      expect(vWidget1Finder, findsOneWidget);
      expect(vNesterFinder, findsNothing);
      expect(vWidget2Finder, findsNothing);

      // Navigate to '/settings/2' by to
      // Tap the add button.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
    });

    testWidgets(
        'systemPop with stack in nested stacked.\n The last element of nested stack should pop',
        (WidgetTester tester) async {
      final vRouterKey = GlobalKey<VRouterState>();

      await tester.pumpWidget(
        VRouter(
          key: vRouterKey,
          initialUrl: '/other',
          routes: [
            VWidget(
              path: '/',
              widget: Text('VWidget1'),
              stackedRoutes: [
                VNester(
                  path: null,
                  aliases: ['scaffold'],
                  widgetBuilder: (child) => Scaffold(
                    appBar: AppBar(title: Text('Scaffold VNester')),
                    body: child,
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: '/settings',
                      widget: Text('VWidget2'),
                      stackedRoutes: [
                        VWidget(
                          path: '/other',
                          widget: Text('VWidget3'),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      final vWidget1Finder = find.text('VWidget1');
      final vWidget2Finder = find.text('VWidget2');
      final vWidget3Finder = find.text('VWidget3');
      final vNesterFinder = find.text('Scaffold VNester');

      await tester.pumpAndSettle();

      // At first we are on '/other' so only VWidget3 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
      expect(vWidget3Finder, findsOneWidget);

      // Pop to '/settings'
      // Tap the add button.
      vRouterKey.currentState!.systemPop();
      await tester.pumpAndSettle();

      // Now, only VWidget2 should be visible
      expect(vWidget1Finder, findsNothing);
      expect(vNesterFinder, findsOneWidget);
      expect(vWidget2Finder, findsOneWidget);
      expect(vWidget3Finder, findsNothing);
    });

    testWidgets('Pop on VNester from VNester.stackedRoutes',
        (WidgetTester tester) async {
      late final BuildContext context;

      await tester.pumpWidget(
        VRouter(
          initialUrl: '/lists/0',
          routes: [
            VNesterPage(
              path: '/lists',
              pageBuilder: (key, child, name) =>
                  MaterialPage(key: key, child: child, name: name),
              widgetBuilder: (child) => child,
              nestedRoutes: [
                VWidget(
                  path: null,
                  aliases: [r':_(.+)'],
                  widget: Text('/lists'),
                  key: ValueKey('lists'),
                ),
              ],
              stackedRoutes: [
                VPage(
                  path: '/lists/:listName',
                  pageBuilder: (_, child, ___) => MaterialPage(child: child),
                  widget: Builder(
                    builder: (ctx) {
                      context = ctx;
                      return Text('/lists/:listName');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final vWidget1Finder = find.text('/lists');
      final vWidget2Finder = find.text('/lists/:listName');

      await tester.pumpAndSettle();

      expect(vWidget1Finder, findsNothing);
      expect(vWidget2Finder, findsOneWidget);

      // Pop with VNester stackedRoutes context
      Navigator.of(context).pop();

      await tester.pumpAndSettle();

      expect(vWidget1Finder, findsOneWidget);
      expect(vWidget2Finder, findsNothing);
    });

    testWidgets('BackButton appears if VNester can pop',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VWidget(
              path: '/whatever',
              widget: Text('whatever'),
              stackedRoutes: [
                VNester(
                  path: null,
                  widgetBuilder: (child) => Scaffold(
                    appBar: AppBar(
                      title: Text('title'),
                    ),
                    body: child,
                  ),
                  nestedRoutes: [
                    VWidget(
                      path: '/',
                      widget: Text('ok'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      final appBar = find.byType(BackButton);

      await tester.pumpAndSettle();
      expect(appBar, findsOneWidget);
    });

    testWidgets('BackButton does NOT appears if VNester can NOT pop',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            VNester(
              path: null,
              widgetBuilder: (child) => Scaffold(
                appBar: AppBar(
                  title: Text('title'),
                ),
                body: child,
              ),
              nestedRoutes: [
                VWidget(
                  path: '/',
                  widget: Text('ok'),
                ),
              ],
            ),
          ],
        ),
      );

      final backButton = find.byType(BackButton);

      await tester.pumpAndSettle();
      expect(backButton, findsNothing);
    });
  });

  testWidgets('Unused VNester child should not be an issue',
      (WidgetTester tester) async {
    final vRouterKey = GlobalKey<VRouterState>();

    await tester.pumpWidget(
      VRouter(
        key: vRouterKey,
        routes: [
          VWidget(path: '/settings', widget: Text('Settings')),
          VNester(
            path: null,
            widgetBuilder: (child) => Scaffold(
              appBar: AppBar(
                title: Text('title'),
              ),
              body: Container(), // We don't use the child
            ),
            nestedRoutes: [
              VWidget(
                path: '/',
                widget: Text('Home'),
              ),
            ],
          ),
        ],
      ),
    );

    final appBar = find.byType(AppBar);
    final home = find.text('Home');
    final settings = find.text('Settings');

    await tester.pumpAndSettle();

    // We should be on VNester but the body (home)
    // should not be used
    expect(appBar, findsOneWidget);
    expect(home, findsNothing);
    expect(settings, findsNothing);

    // Navigate to '/settings', this should not be an issue
    vRouterKey.currentState!.to('/settings');
    await tester.pumpAndSettle();

    // We should now be on settings
    expect(appBar, findsNothing);
    expect(home, findsNothing);
    expect(settings, findsOneWidget);
  });
}
