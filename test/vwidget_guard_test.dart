import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets('VWidgetGuard afterEnter', (WidgetTester tester) async {
    var count = 0;
    await tester.pumpWidget(
      VRouter(
        routes: [
          VWidget(
            path: '/',
            widget: Builder(
              builder: (BuildContext context) => VWidgetGuard(
                afterEnter: (_, __, ___) => count = 1,
                child: TextButton(
                  child: Text('VWidget1'),
                  onPressed: () => VRouter.of(context).to('/settings'),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/' and afterEnter should be fired
    expect(count, 1);
  });

  testWidgets('VWidgetGuard afterUpdate', (WidgetTester tester) async {
    var count = 0;
    await tester.pumpWidget(
      VRouter(
        routes: [
          VWidget(
            path: '/',
            widget: Builder(
              builder: (BuildContext context) => VWidgetGuard(
                afterEnter: (_, __, ___) => count = 1,
                afterUpdate: (_, __, ___) => count = 2,
                child: TextButton(
                  child: Text('VWidget1'),
                  onPressed: () => VRouter.of(context).to('/settings'),
                ),
              ),
            ),
            stackedRoutes: [
              VWidget(path: 'settings', widget: Container()),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/' and afterEnter should be fired
    expect(count, 1);

    // We should go to '/settings' and afterUpdate should be fired
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(count, 2);
  });

  testWidgets('VWidgetGuard beforeUpdate', (WidgetTester tester) async {
    var count = 0;
    await tester.pumpWidget(
      VRouter(
        routes: [
          VWidget(
            path: '/',
            widget: Builder(
              builder: (BuildContext context) => VWidgetGuard(
                afterEnter: (_, __, ___) => count = 1,
                afterUpdate: (_, __, ___) => count = 2,
                beforeUpdate: (vRedirector) async =>
                    vRedirector.stopRedirection(),
                child: TextButton(
                  child: Text('VWidget1'),
                  onPressed: () => VRouter.of(context).to('/settings'),
                ),
              ),
            ),
            stackedRoutes: [
              VWidget(path: 'settings', widget: Container()),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/' and afterEnter should be fired
    expect(count, 1);

    // We should go to '/settings' and beforeUpdate should stop us
    // afterUpdate should NOT be fired
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(count, 1);
  });

  testWidgets('VWidgetGuard beforeLeave', (WidgetTester tester) async {
    final vRouterKey = GlobalKey<VRouterState>();

    await tester.pumpWidget(
      VRouter(
        key: vRouterKey,
        initialUrl: '/settings',
        routes: [
          VWidget(
            path: '/',
            widget: Text('VWidget1'),
            stackedRoutes: [
              VWidget(
                path: '/settings',
                widget: VWidgetGuard(
                  beforeLeave: (vRedirector, _) async =>
                      vRedirector?.stopRedirection(),
                  child: Text('VWidget2'),
                ),
              ),
              VWidget(
                path: '/other',
                widget: Text('VWidget3'),
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // At first we are on "/settings" so only VWidget2 should be shown

    final vWidget1Finder = find.text('VWidget1');
    final vWidget2Finder = find.text('VWidget2');
    final vWidget3Finder = find.text('VWidget3');

    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);
    expect(vWidget3Finder, findsNothing);

    // Try to navigate to '/other'
    // Tap the add button.
    vRouterKey.currentState!.to('/other');
    await tester.pumpAndSettle();

    // The navigation must have been stopped, so VWidget2 should be visible
    expect(vWidget1Finder, findsNothing);
    expect(vWidget2Finder, findsOneWidget);
    expect(vWidget3Finder, findsNothing);
  });

  testWidgets('VWidgetGuard in VNester', (WidgetTester tester) async {
    var count = 0;
    await tester.pumpWidget(
      VRouter(
        routes: [
          VNesterBase(
            widgetBuilder: (child) => VWidgetGuard(
              afterEnter: (_, __, ___) => count = 1,
              child: child,
            ),
            nestedRoutes: [
              VWidget(
                path: '/',
                widget: Text('VWidget1'),
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // We should start at '/' and afterEnter should be fired
    expect(count, 1);
  });
}
