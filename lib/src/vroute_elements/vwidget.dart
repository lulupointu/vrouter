import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/vpath.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vroute_elements/vwidget_base.dart';
import 'package:vrouter/src/vrouter_core.dart';

class VWidget extends VRouteElementBuilder {
  /// The path (relative or absolute) or this [VRouteElement]
  ///
  /// If the path of a subroute is exactly matched, this will be used in
  /// the route but might be covered by another [VRouteElement._rootVRouter]
  /// The value of the path ca have three form:
  ///     * starting with '/': The path will be treated as a route path,
  ///       this is useful to take full advantage of nested routes while
  ///       conserving the freedom of path naming
  ///     * not starting with '/': The path corresponding to this route
  ///       will be the path of the parent route + this path. If this is used
  ///       directly in the [VRouter] routes, a '/' will be added anyway
  ///     * be null: In this case this path will match the parent path
  ///
  /// Note we use the package [path_to_regexp](https://pub.dev/packages/path_to_regexp)
  /// so you can use naming such as /user/:id to get the id (see [VRouteElementData.pathParameters]
  /// You can also use more advance technique using regexp directly in your path, for example
  /// '*' will match any route, '/user/:id(\d+)' will match any route starting with user
  /// and followed by a digit. Here is a recap:
  /// |     pattern 	  | matched path | 	[VRouter.pathParameters]
  /// | /user/:username |  /user/evan  | 	 { username: 'evan' }
  /// | /user/:id(\d+)  |  /user/123   | 	     { id: '123' }
  /// |     *          |  every path  |             -
  final String? path;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  final String? name;

  /// Alternative paths that will be matched to this route
  ///
  /// Note that path is match first, then every aliases in order
  final List<String> aliases;

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

  VWidget({
    required this.path,
    required this.widget,
    this.stackedRoutes = const [],
    this.key,
    this.name,
    this.aliases = const [],
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.fullscreenDialog = false,
  });

  VWidget.builder({
    required String? path,
    required Widget Function(BuildContext context, VRouterData state) builder,
    List<VRouteElement> stackedRoutes = const [],
    LocalKey? key,
    String? name,
    List<String> aliases = const [],
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Widget Function(Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child)?
        buildTransition,
    bool fullscreenDialog = false,
  }) : this(
          path: path,
          widget: VRouterDataBuilder(builder: builder),
          stackedRoutes: stackedRoutes,
          key: key,
          name: name,
          aliases: aliases,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          buildTransition: buildTransition,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  List<VRouteElement> buildRoutes() => [
        VPath(
          path: path,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
          stackedRoutes: [
            VWidgetBase(
              widget: widget,
              key: key,
              name: name,
              stackedRoutes: stackedRoutes,
              buildTransition: buildTransition,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fullscreenDialog,
            ),
          ],
        ),
      ];

  /// A boolean to indicate whether this can be a valid [VRouteElement] of the [VRoute] if no
  /// [VRouteElement] in its [stackedRoute] is matched
  ///
  /// This is mainly useful for [VRouteElement]s which are NOT [VRouteElementWithPage]
  bool get mustMatchStackedRoute => false;
}
