import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/vrouter.dart';

main() {
  testWidgets(
    'Keep navigatorEntry count on complex Navigator changes',
    (tester) async {
      await tester.pumpWidget(
        VRouter(
          routes: [
            HomeRoute(),
            ProfileRoute(),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Begin on home
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

      // Navigate to /item
      await tester.tap(find.text('Show Item'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Item'), findsOneWidget);

      // Navigate to /Profile (changing VNester instance but not Navigator.key)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

      // Navigate to /Home (changing VNester instance but not Navigator.key)
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

      // Navigate to /item to be able to pop later
      await tester.tap(find.text('Show Item'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Item'), findsOneWidget);

      // Pop to /Home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    },
  );
}

class HomeRoute extends VRouteElementBuilder {
  static final String home = '/';
  static final String item = home + 'item';

  @override
  List<VRouteElement> buildRoutes() {
    return [
      ScaffoldRouteElement(
        path: home,
        nestedRoute: VWidget(
          path: null,
          widget: BasicScreen(
            title: 'Home',
            action: BasicScreenAction(
              title: 'Show Item',
              action: (context) => context.vRouter.to(item),
            ),
          ),
          stackedRoutes: [
            VWidget(path: item, widget: BasicScreen(title: 'Item'))
          ],
        ),
      ),
    ];
  }
}

class ProfileRoute extends VRouteElementBuilder {
  static final String profile = '/profile';

  @override
  List<VRouteElement> buildRoutes() {
    return [
      ScaffoldRouteElement(
        path: profile,
        nestedRoute: VWidget(
          path: null,
          widget: BasicScreen(
            title: 'Profile',
          ),
        ),
      )
    ];
  }
}

class ScaffoldRouteElement extends VRouteElementBuilder {
  static final navigatorKey = GlobalKey<NavigatorState>();

  final String path;
  final VRouteElement nestedRoute;

  ScaffoldRouteElement({required this.path, required this.nestedRoute});

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VNester(
        key: ValueKey('MyScaffold'),
        navigatorKey: navigatorKey,
        path: path,
        widgetBuilder: (child) => MyScaffold(body: child),
        nestedRoutes: [nestedRoute],
      )
    ];
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex:
            context.vRouter.path.startsWith(ProfileRoute.profile) ? 1 : 0,
        onTap: (value) => context.vRouter
            .to(value == 0 ? HomeRoute.home : ProfileRoute.profile),
      ),
    );
  }
}

class BasicScreenAction {
  const BasicScreenAction({required this.title, required this.action});

  final String title;
  final Function(BuildContext) action;
}

class BasicScreen extends StatelessWidget {
  const BasicScreen({required this.title, this.action});

  final String title;
  final BasicScreenAction? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: action != null
            ? ElevatedButton(
                onPressed: () => action!.action(context),
                child: Text(action!.title),
              )
            : Container(),
      ),
    );
  }
}
