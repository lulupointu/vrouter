part of '../main.dart';

class VNester extends VNesterPage {
  VNester({
    required Widget Function(Widget) widgetBuilder,
    required String? path,
    required List<VRouteElement> nestedRoutes,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchSubRoute = false,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Widget Function(Animation<double>, Animation<double>, Widget)?
        buildTransition,
  }) : super(
          nestedRoutes: nestedRoutes,
          pageBuilder: (LocalVRouterData child) => VBasePage.fromPlatform(
            key: ValueKey(path),
            child: child,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            buildTransition: buildTransition,
          ),
          widgetBuilder: widgetBuilder,
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchSubRoute: mustMatchSubRoute,
        );
}
