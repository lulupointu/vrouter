import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/vnester_page_base.dart';
import 'package:vrouter/src/vroute_elements/vpath.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// A [VRouteElement] similar to [VNester] but which allows you to specify your own page
/// thanks to [pageBuilder]
class VNesterPage extends VRouteElementBuilder {
  /// A list of routes which:
  ///   - path NOT starting with '/' will be relative to [path]
  ///   - widget or page will be nested inside [widgetBuilder]
  final List<VRouteElement> nestedRoutes;

  /// A list of routes which:
  ///   - path NOT starting with '/' will be relative to [path]
  ///   - widget or page will be stacked on top of [_rootVRouter]
  final List<VRouteElement> stackedRoutes;

  /// A function which allows you to use your own custom page
  ///
  /// You must use [child] as the child of your page (though you can wrap it in other widgets)
  ///
  /// [child] will basically be whatever you put in [_rootVRouter]
  final Page Function(
      LocalKey key, Widget child, String? name, VRouterData state) pageBuilder;

  /// A function which creates the [VRouteElement._rootVRouter] associated to this [VRouteElement]
  ///
  /// [child] will be the [VRouteElement._rootVRouter] of the matched [VRouteElement] in
  /// [nestedRoutes]
  final Widget Function(Widget child) widgetBuilder;

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

  /// A LocalKey that will be given to the page which contains the given [_rootVRouter]
  ///
  /// This key mostly controls the page animation. If a page remains the same but the key is changes,
  /// the page gets animated
  /// The key is by default the value of the current [path] (or [aliases]) with
  /// the path parameters replaced
  ///
  /// Do provide a constant [key] if you don't want this page to animate even if [path] or
  /// [aliases] path parameters change
  final LocalKey? key;

  /// A key for the nested navigator
  /// It is created automatically
  ///
  /// Using this is useful if you create two different [VNesterPage] that should
  /// actually be the same. This happens if you use two different [VRouteElementBuilder]
  /// to represent two different routes which should share a common [VNesterPage]
  /// In that case give the [VNesterPage]s the same [key] and the same [navigatorKey]
  /// and the animations will be as expected
  final GlobalKey<NavigatorState>? navigatorKey;

  VNesterPage({
    required this.path,
    required Page Function(LocalKey key, Widget child, String? name)
        pageBuilder,
    required this.widgetBuilder,
    required this.nestedRoutes,
    this.key,
    this.name,
    this.stackedRoutes = const [],
    this.aliases = const [],
    this.navigatorKey,
  }) : this.pageBuilder =
            ((LocalKey key, Widget child, String? name, VRouterData state) =>
                pageBuilder(key, child, name));

  /// Provides a [state] from which to access [VRouter] data in [widgetBuilder]
  VNesterPage.builder({
    required String? path,
    required Page Function(
            LocalKey key, Widget child, String? name, VRouterData state)
        pageBuilder,
    required Widget Function(
            BuildContext context, VRouterData state, Widget child)
        widgetBuilder,
    required List<VRouteElement> nestedRoutes,
    LocalKey? key,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    GlobalKey<NavigatorState>? navigatorKey,
  })  : this.path = path,
        this.pageBuilder = pageBuilder,
        this.widgetBuilder = ((child) => VRouterDataBuilder(
            builder: (context, state) => widgetBuilder(context, state, child))),
        this.nestedRoutes = nestedRoutes,
        this.key = key,
        this.name = name,
        this.stackedRoutes = stackedRoutes,
        this.aliases = aliases,
        this.navigatorKey = navigatorKey;

  @override
  List<VRouteElement> buildRoutes() => [
        VPath(
          path: path,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
          stackedRoutes: [
            VNesterPageBase(
              key: key,
              name: name,
              nestedRoutes: nestedRoutes,
              stackedRoutes: stackedRoutes,
              widgetBuilder: widgetBuilder,
              pageBuilder: pageBuilder,
              navigatorKey: navigatorKey,
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
