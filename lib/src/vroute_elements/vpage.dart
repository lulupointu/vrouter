import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/vpage_base.dart';
import 'package:vrouter/src/vroute_elements/vpath.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vrouter_core.dart';

class VPage extends VRouteElementBuilder {
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
  /// |     *           |  every path  |             -
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

  /// A boolean to indicate whether this can be a valid [VRouteElement] of the [VRoute] if no
  /// [VRouteElement] in its [stackedRoute] is matched
  ///
  /// This is mainly useful for [VRouteElement]s which are NOT [VRouteElementWithPage]
  final bool mustMatchStackedRoute;

  final List<VRouteElement> stackedRoutes;

  /// Function which returns a page that will wrap [widget]
  ///   - key and name should be given to your [Page]
  ///   - child should be placed as the last child in [Route]
  final Page Function(LocalKey key, Widget child, String? name) pageBuilder;

  /// The widget which will be displayed for this [VRouteElement]
  /// inside the given page
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

  VPage({
    required this.path,
    required this.pageBuilder,
    required this.widget,
    this.stackedRoutes = const [],
    this.key,
    this.name,
    this.aliases = const [],
    this.mustMatchStackedRoute = false,
  });

  VPage.builder({
    required String? path,
    required Page<dynamic> Function(LocalKey, Widget, String?) pageBuilder,
    required Widget Function(BuildContext context, VRouterData state) builder,
    List<VRouteElement> stackedRoutes = const [],
    LocalKey? key,
    String? name,
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
  }) : this(
          path: path,
          pageBuilder: pageBuilder,
          widget: VRouterDataBuilder(builder: builder),
          stackedRoutes: stackedRoutes,
          key: key,
          name: name,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
        );

  @override
  List<VRouteElement> buildRoutes() => [
        VPath(
          path: path,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
          stackedRoutes: [
            VPageBase(
              pageBuilder: pageBuilder,
              widget: widget,
              key: key,
              name: name,
              stackedRoutes: stackedRoutes,
            ),
          ],
        )
      ];
}
