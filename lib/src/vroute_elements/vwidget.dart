part of '../main.dart';

@immutable
class VWidget extends VPage {
  VWidget({
    required Widget widget,
    required String path,
    String? name,
    List<VRouteElement> subroutes = const [],
    List<String> aliases = const [],
    bool mustMatchSubRoute = false,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
  }) : super(
          pageBuilder: (LocalVRouterData child) => VBasePage.fromPlatform(
            key: ValueKey(path),
            child: child,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            buildTransition: buildTransition,
          ),
          widget: widget,
          path: path,
          name: name,
          subroutes: subroutes,
          aliases: aliases,
          mustMatchSubRoute: mustMatchSubRoute,
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
