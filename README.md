<p align="center" xmlns="http://www.w3.org/1999/html">
<img src="https://raw.githubusercontent.com/lulupointu/vrouter_website/master/assets/logo_whole.svg" alt="VRouter logo" height="100"/>
</p>

---

This branch is dedicated to vrouter nesting study. The main question is whether a "out of the widget tree" nesting is good (enough).

Other things that are not directly linked to nesting but are tested are:
1. Navigation by type rather than navigation by name
2. `VNesterProvider` to be used as the old VStacked(VChild) combo


The main things we are trying to achieve here are:
* Allowing large project to split the work
* Enabling recursive path
* Being non-breaking w.r.t v1.1

## VRouter nesting

Here is the main idea on how this would work:
```dart
final settingsRouter = VRouter(
  routes: [
    VWidget(path: 'basic', widget: BasicSettingsScreen()),
    VWidget(path: 'network', widget: NetworkSettingsScreen()),
    VWidget(path: 'advanced', widget: AdvancedSettingsScreen()),
  ],
);

// Recursive path creation
final friendsRouter = VRouter(
  routes: [
    VWidget(
      path: '/friends/:id',
      widget: FriendsScreen(),
      stackedRoutes: [friendsRouter],
    ),
  ],
);

final mainRouter = VRouter(
  routes: [
    VWidget(path: '/login', widget: LoginScreen()),
    VNester(
      path: '/home',
      widgetBuilder: (child) => HomeScreen(child),
      nestedRoutes: [homeRouter],
    ),
    VNester(
      path: '/settings', 
      widgetBuilder: (child) => SettingsScreen(child),
      nestedRoutes: [settingsRouter],
    ),
  ]
);
```

Important things to note:
* No change should have to be made when nesting a router in mainRouter vs when using the router alone
* `Named` navigation should be scoped, see "navigation by type" to solve this
* The base path of each router is the path of the parent VRouteElement + '/' (here settingsRouter will have a basePath of '/settings' when put in main, and a basePath of '/' when used in isolation)


## Navigation by type

The idea here is to promote type over Strings.
1. String are easy to get wrong
2. Types are auto-completed
3. Types are easy to change everywhere in a project
4. Flutter devs are used to them thanks to provider

## `VNesterProvider`
The idea is that, instead of forcing child to be used in the widgetBuilder of `VNester`, the child could be accessible using `InheritedWidget`.
1. This makes things easier for deeply nested widget
2. This is more elegant when you see the route configuration

Here is an example of how this would work:
```dart
final mainRouter = VRouter(
  routes: [
    VNesterProvider<MyScaffold>(
      path: null, 
      widget: MyScaffold(), // Note that we use a widget instead of widgetBuilder
      nestedRoutes: [
        VWidget<HomeScreen>(path: 'home', widget: HomeScreen()),
        VWidget<SettingsScreen>(path: 'settings', widget: SettingsScreen()),
      ],
    ),
  ],
);

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: context.findVNesterProvider<MyScaffold>().child);
  }
}

```
