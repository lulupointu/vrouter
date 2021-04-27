import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
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
                    onPressed: () => VRouter.of(context).push('/other'),
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
                    onPressed: () => VRouter.of(context).push('/settings'),
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

    // Now, only VWidget2 should be visible
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
                    onPressed: () => VRouter.of(context).push('/other'),
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
                        VRouter.of(context).push('/settings/other'),
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
                    onPressed: () => VRouter.of(context).pushNamed('settings'),
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

  testWidgets('VNester named with alias default', (WidgetTester tester) async {
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
                    onPressed: () => VRouter.of(context).pushNamed('settings'),
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
                    onPressed: () => VRouter.of(context).push('/settings/2'),
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

    // Navigate to '/settings/2' by push
    // Tap the add button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now, only VWidget2 should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vNesterFinder, findsOneWidget);
    expect(vWidget2Finder, findsOneWidget);
  });
}
