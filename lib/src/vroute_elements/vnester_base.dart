import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/vnester_page_base.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_helpers.dart';

/// A [VRouteElement] which enable nesting
///
/// [widgetBuilder] gives you a [Widget] which is what you should use as the child to nest
/// This [Widget] will be the one present in the [VRouteElement] in [nestedRoutes] corresponding
/// to the current route
///
/// {@tool snippet}
///
/// If you want to nest ProfileWidget in MyScaffold at the path '/profile',
/// here is what you can do:
///
/// ```dart
/// VNester(
///   widgetBuilder: (child) => MyScaffold(child: child),
///   nestedRoutes: [
///     VWidget(
///       path: '/profile',
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
///
/// Also see:
///   * [VNester] for a [VRouteElement] similar to [VNesterBase] but which take path information
/// {@end-tool}
class VNesterBase extends VRouteElementBuilder {
  /// A list of [VRouteElement] which widget will be accessible in [widgetBuilder]
  final List<VRouteElement> nestedRoutes;

  /// A list of routes which:
  ///   - path NOT starting with '/' will be relative to [path]
  ///   - widget or page will be stacked on top of [_rootVRouter]
  final List<VRouteElement> stackedRoutes;

  /// A function which creates the [VRouteElement._rootVRouter] associated to this [VRouteElement]
  ///
  /// [child] will be the [VRouteElement._rootVRouter] of the matched [VRouteElement] in
  /// [nestedRoutes]
  final Widget Function(Widget child) widgetBuilder;

  /// A LocalKey that will be given to the page which contains the given [widget]
  ///
  /// This key mostly controls the page animation. If a page remains the same but the key is changes,
  /// the page gets animated
  /// The key is by default the value of the current [path] (or [aliases]) with
  /// the path parameters replaced
  ///
  /// Do provide a constant [key] if you don't want this page to animate even if [path] or
  /// [aliases] path parameters change
  final LocalKey? key;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  final String? name;

  /// The duration of [VWidgetBase.buildTransition]
  final Duration? transitionDuration;

  /// The reverse duration of [VWidgetBase.buildTransition]
  final Duration? reverseTransitionDuration;

  /// Create a custom transition effect when coming to and
  /// going to this route
  /// This has the priority over [VRouter.buildTransition]
  ///
  /// Also see:
  ///   * [VRouter.buildTransition] for default transitions for all routes
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// A key for the nested navigator
  /// It is created automatically
  ///
  /// Using this is useful if you create two different [VNesterBase] that should
  /// actually be the same. This happens if you use two different [VRouteElementBuilder]
  /// to represent two different routes which should share a common [VNesterBase]
  /// In that case give the [VNesterBase]s the same [key] and the same [navigatorKey]
  /// and the animations will be as expected
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Whether this page route is a full-screen dialog.
  ///
  /// In Material and Cupertino, being fullscreen has the effects of making the app bars
  /// have a close button instead of a back button. On iOS, dialogs transitions animate
  /// differently and are also not closeable with the back swipe gesture.
  final bool fullscreenDialog;

  VNesterBase({
    required this.widgetBuilder,
    required this.nestedRoutes,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.stackedRoutes = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  });

  /// Provides a [state] from which to access [VRouter] data in [widgetBuilder]
  VNesterBase.builder({
    required Widget Function(
            BuildContext context, VRouterData state, Widget child)
        widgetBuilder,
    required List<VRouteElement> nestedRoutes,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Widget Function(Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child)?
        buildTransition,
    LocalKey? key,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    GlobalKey<NavigatorState>? navigatorKey,
    fullscreenDialog = false,
  }) : this(
          widgetBuilder: (child) => VRouterDataBuilder(
            builder: (context, state) => widgetBuilder(context, state, child),
          ),
          nestedRoutes: nestedRoutes,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          buildTransition: buildTransition,
          key: key,
          name: name,
          stackedRoutes: stackedRoutes,
          navigatorKey: navigatorKey,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  List<VRouteElement> buildRoutes() => [
        VNesterPageBase(
          key: key,
          name: name,
          nestedRoutes: nestedRoutes,
          stackedRoutes: stackedRoutes,
          widgetBuilder: widgetBuilder,
          navigatorKey: navigatorKey,
          pageBuilder:
              (LocalKey key, Widget child, String? name, VRouterData state) =>
                  VDefaultPage.fromPlatform(
            key: key,
            child: child,
            name: name,
            buildTransition: buildTransition,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            fullscreenDialog: fullscreenDialog,
          ),
        ),
      ];
}
