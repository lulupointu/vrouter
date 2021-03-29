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
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
  }) : super(
          widget: widget,
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
        ValueKey(vRouteElementNode.localPath),
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
}
