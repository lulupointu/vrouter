part of 'main.dart';

class VRedirector {
  final BuildContext _context;

  VRedirector({
    @required BuildContext context,
    @required this.from,
    @required this.to,
    @required this.previousVRouteData,
    @required this.newVRouteData,
  }) : _context = context;

  VoidCallback redirectFunction;

  bool _shouldUpdate = true;

  bool get shouldUpdate => _shouldUpdate;

  final String from;
  final String to;
  final VRouteData previousVRouteData;
  final VRouteData newVRouteData;

  void stopRedirection() {
    if (!shouldUpdate) {
      throw 'You already stopped the redirection. You can only use one such action on VRedirector.';
    }
    _shouldUpdate = false;
  }

  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context)
        .push(newUrl, queryParameters: queryParameters, routerState: routerState);
  }

  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context).pushNamed(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        routerState: routerState);
  }

  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context)
        .pushReplacement(newUrl, queryParameters: queryParameters, routerState: routerState);
  }

  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context).pushReplacementNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState,
        );
  }

  void pushExternal(String newUrl, {bool openNewTab = false}) {
    stopRedirection();
    redirectFunction =
        () => VRouterData.of(_context).pushExternal(newUrl, openNewTab: openNewTab);
  }

  void pop() {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context).pop(_context);
  }

  Future<void> systemPop() async {
    stopRedirection();
    redirectFunction = () => VRouterData.of(_context).systemPop(_context);
  }
}
