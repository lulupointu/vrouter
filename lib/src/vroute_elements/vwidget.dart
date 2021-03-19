part of '../main.dart';

/// A VRouteElement which enable to to map a [path] to a [widget] to display
///
/// You can stack widgets on top of each other by using the [stackedRoutes] argument
///
/// {@tool snippet}
///
/// For example if you want:
///    - The '/profile' path to display ProfileWidget
///    - The '/profile/settings' path to display the SettingsWidget on top on the ProfileWidget
///
/// ```dart
/// VWidget(
///   path: '/home',
///   widgetBuilder: ProfileWidget(),
///   stackedRoutes: [
///     VWidget(
///       path: 'settings',
///       widget: SettingsWidget(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// Also see [VNester] if you want to widget nesting instead of widget stacking
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
          mustMatchStackedRoute: mustMatchStackedRoute,
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
