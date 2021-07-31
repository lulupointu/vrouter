import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/vpage_base.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_helpers.dart';

class VWidgetBase extends VRouteElementBuilder {
  /// A list of routes which:
  ///   - path NOT starting with '/' will be relative to [path]
  ///   - widget or page will be stacked on top of [widget]
  final List<VRouteElement> stackedRoutes;

  /// The widget which will be displayed for this [VRouteElement]
  final Widget widget;

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

  /// Whether this page route is a full-screen dialog.
  ///
  /// In Material and Cupertino, being fullscreen has the effects of making the app bars
  /// have a close button instead of a back button. On iOS, dialogs transitions animate
  /// differently and are also not closeable with the back swipe gesture.
  final bool fullscreenDialog;

  VWidgetBase({
    required this.widget,
    this.stackedRoutes = const [],
    this.key,
    this.name,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.fullscreenDialog = false,
  });

  VWidgetBase.builder({
    required Widget Function(BuildContext context, VRouterData state) builder,
    List<VRouteElement> stackedRoutes = const [],
    LocalKey? key,
    String? name,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Widget Function(Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child)?
        buildTransition,
    bool fullscreenDialog = false,
  }) : this(
          widget: VRouterDataBuilder(builder: builder),
          stackedRoutes: stackedRoutes,
          key: key,
          name: name,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          buildTransition: buildTransition,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  List<VRouteElement> buildRoutes() => [
        VPageBase(
          pageBuilder: (key, child, name) => VDefaultPage.fromPlatform(
            key: key,
            child: child,
            name: name,
            buildTransition: buildTransition,
            transitionDuration: transitionDuration,
            reverseTransitionDuration: reverseTransitionDuration,
            fullscreenDialog: fullscreenDialog,
          ),
          widget: widget,
          key: key,
          name: name,
          stackedRoutes: stackedRoutes,
        ),
      ];
}
