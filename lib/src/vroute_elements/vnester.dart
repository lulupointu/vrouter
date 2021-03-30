part of '../main.dart';

/// A [VRouteElement] which enable nesting
///
/// [widgetBuilder] gives you a [Widget] which is what you should use as the child to nest
/// This [Widget] will be the one present in the [VRouteElement] in [nestedRoutes] corresponding
/// to the current route
///
/// {@tool snippet}
///
/// If you want to nest ProfileWidget in MyScaffold at the path '/home/profile',
/// here is what you can do:
///
/// ```dart
/// VNester(
///   path: '/home',
///   widgetBuilder: (child) => MyScaffold(child: child),
///   nestedRoutes: [
///     VWidget(
///       path: 'profile',
///       widget: ProfileWidget(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
///
/// {@tool snippet}
///
/// Note that you can also use stackedRoutes if you want to nest AND stack by using nestedRoutes
/// AND stackedRoutes:
///
/// ```dart
/// VNester(
///   path: '/home',
///   widgetBuilder: (child) => MyScaffold(child: child),
///   nestedRoutes: [
///     VWidget(
///       path: 'profile',
///       alias: [':_(settings)'] // This is used because we want to display ProfileWidget while SettingsWidgets is on top of MyScaffold
///       widget: ProfileWidget(),
///     ),
///   ],
///   stackedRoutes: [
///     VWidget(
///       path: 'settings',
///       widget: SettingsWidget(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
class VNester extends VNesterPage {
  VNester({
    required String? path,
    required Widget Function(Widget) widgetBuilder,
    required List<VRouteElement> nestedRoutes,
    LocalKey? key,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
  }) : super(
          nestedRoutes: nestedRoutes,
          pageBuilder: (LocalKey key, Widget child) => VBasePage.fromPlatform(
            key: key,
            child: child,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            buildTransition: buildTransition,
          ),
          widgetBuilder: widgetBuilder,
          key: key,
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
