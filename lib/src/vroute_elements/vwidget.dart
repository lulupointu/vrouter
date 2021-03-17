part of '../main.dart';

@immutable
class VWidget extends VPage {
  VWidget({
    required String? path,
    required Widget widget,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
  }) : super(
          pageBuilder: (Widget child) => VBasePage.fromPlatform(
            key: ValueKey(path),
            child: child,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            buildTransition: buildTransition,
          ),
          widget: widget,
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchSubRoute: mustMatchStackedRoute,
        );

  /// The duration of [VWidget.buildTransition]
  final Duration? transitionDuration;

  /// The reverse duration of [VWidget.buildTransition]
  final Duration? reverseTransitionDuration;

  /// Create a custom transition effect when coming to and
  /// going to this route
  /// This has the priority over [VRouter.buildTransition]
  ///
  /// Also see:
  ///   * [VRouter.buildTransition] for default transitions for all routes
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;
}
