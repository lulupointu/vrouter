part of '../main.dart';

/// A [VRouteElement] similar to [VWidget] but which allows you to specify your own page
/// thanks to [pageBuilder]
class VPage extends VRouteElementWithPage {
  /// A function which allows you to use your own custom page
  ///
  /// You must use [child] as the child of your page (though you can wrap it in other widgets)
  ///
  /// [child] will basically be whatever you put in [widget]
  final Page Function(LocalKey key, Widget child) pageBuilder;

  VPage({
    required String? path,
    required this.pageBuilder,
    required Widget widget,
    LocalKey? key,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
  }) : super(
          widget: widget,
          key: key,
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
        );

  @override
  Page buildPage({
    required Widget widget,
    required VPathRequestData vPathRequestData,
    required Map<String, String> pathParameters,
    required VRouteElementNode vRouteElementNode,
  }) =>
      pageBuilder(
        key ??
            ValueKey((vRouteElementNode.localPath != null)
                ? vRouteElementNode.localPath
                : getConstantLocalPath()),
        LocalVRouterData(
          child: NotificationListener<VWidgetGuardMessage>(
            // This listen to [VWidgetGuardNotification] which is a notification
            // that a [VWidgetGuard] sends when it is created
            // When this happens, we store the VWidgetGuard and its context
            // This will be used to call its afterUpdate and beforeLeave in particular.
            onNotification: (VWidgetGuardMessage vWidgetGuardMessage) {
              VWidgetGuardMessageRoot(
                vWidgetGuard: vWidgetGuardMessage.vWidgetGuard,
                localContext: vWidgetGuardMessage.localContext,
                associatedVRouteElement: this,
              ).dispatch(vPathRequestData.rootVRouterContext);

              return true;
            },
            child: widget,
          ),
          vRouteElementNode: vRouteElementNode,
          url: vPathRequestData.url,
          previousUrl: vPathRequestData.previousUrl,
          historyState: vPathRequestData.historyState,
          pathParameters: pathParameters,
          queryParameters: vPathRequestData.queryParameters,
          context: vPathRequestData.rootVRouterContext,
        ),
      );

  /// If this [VRouteElement] is in the route but its localPath is null
  /// we try to find a local path in [path, ...aliases]
  ///
  /// This is used in [buildPage] to form the LocalKey
  /// Note that
  ///   - We can't use this because animation won't play if path parameters change for example
  ///   - Using null is not ideal because if we pop from a absolute path, this won't animate as expected
  String? getConstantLocalPath() {
    if (pathParametersKeys.isEmpty) {
      return path;
    }
    for (var i = 0; i < aliasesPathParametersKeys.length; i++) {
      if (aliasesPathParametersKeys[i].isEmpty) {
        return aliases[i];
      }
    }
    return null;
  }
}
