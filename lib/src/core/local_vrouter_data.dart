import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/navigator_extension.dart';
import 'package:vrouter/src/core/vpop_data.dart';
import 'package:vrouter/src/core/vroute_element.dart';
import 'package:vrouter/src/core/vroute_element_node.dart';
import 'package:vrouter/src/core/vrouter_delegate.dart';
import 'package:vrouter/src/vrouter_widgets.dart';

import 'vrouter_sailor/vrouter_sailor.dart';

/// An [InheritedWidget] accessible via [VRouter.of(context)]
///
/// [LocalVRouterData] is placed on top of each [VRouteElement._rootVRouter], the main goal of having
/// local classes compared to a single one is that:
///   1. [_vRouteElementNode] is specific to the local [VRouteElement] to allow a different
///   _  pop event based on where the [VRouteElement] is in the [VRoute]
///   2. When a [VRouteElement] is no longer in the route, it has a page animation out. During
///   _  this, the old VRouterData should be used, which this [LocalVRouterData] holds
class LocalVRouterData extends InheritedWidget with InitializedVRouterSailor {
  /// The [VRouteElementNode] of the associated [VRouteElement]
  final VRouteElementNode _vRouteElementNode;

  /// A [BuildContext] which can be used to access the [RootVRouterData]
  final BuildContext _context;

  LocalVRouterData({
    Key? key,
    required Widget child,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
    required VRouteElementNode vRouteElementNode,
    required BuildContext context,
  })  : _vRouteElementNode = vRouteElementNode,
        _context = context,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(LocalVRouterData old) {
    return (old.url != url ||
        old.previousUrl != previousUrl ||
        old.historyState != historyState ||
        old.pathParameters != pathParameters ||
        old.queryParameters != queryParameters ||
        old.hash != hash);
  }

  @override
  final String url;

  @override
  final String? previousUrl;

  @override
  final Map<String, String> historyState;

  @override
  final Map<String, String> pathParameters;

  @override
  final Map<String, String> queryParameters;

  @override
  List<String> get names => VRouter.of(_context).names;

  @override
  @Deprecated('Use to (vRouter.to) instead')
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        historyState: historyState,
      );

  @override
  @Deprecated('Use toSegments instead')
  void pushSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toSegments(
        segments,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
      );

  @override
  @Deprecated('Use toNamed instead')
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
      );

  @override
  @Deprecated('Use vRouter.to(..., isReplacement: true) instead')
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: true,
      );

  @override
  @Deprecated('Use vRouter.toNamed(..., isReplacement: true) instead')
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: true,
      );

  @override
  @Deprecated('Use toExternal instead')
  void pushExternal(String newUrl, {bool openNewTab = false}) => toExternal(
        newUrl,
        openNewTab: openNewTab,
      );

  @override
  void to(
    String path, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) =>
      RootVRouterData.of(_context).to(
        path,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) =>
      RootVRouterData.of(_context).toSegments(
        segments,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    bool isReplacement = false,
  }) =>
      RootVRouterData.of(_context).toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toExternal(String newUrl, {bool openNewTab = false}) =>
      RootVRouterData.of(_context).toExternal(
        newUrl,
        openNewTab: openNewTab,
      );

  @override
  void historyForward() => RootVRouterData.of(_context).historyForward();

  @override
  void historyBack() => RootVRouterData.of(_context).historyBack();

  @override
  void historyGo(int delta) => RootVRouterData.of(_context).historyGo(delta);

  @override
  bool historyCanForward() => RootVRouterData.of(_context).historyCanForward();

  @override
  bool historyCanBack() => RootVRouterData.of(_context).historyCanBack();

  @override
  bool historyCanGo(int delta) =>
      RootVRouterData.of(_context).historyCanGo(delta);

  @override
  void pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) {
    Navigator.of(_context).pop(
      VPopData(
        elementToPop: _vRouteElementNode.getVRouteElementToPop(),
        pathParameters: {
          ...pathParameters,
          ...this
              .pathParameters, // Include the previous path parameters when poping
        },
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      ),
    );
  }

  @override
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) async {
    // Try to pop a Nav1 page, if successful return
    if (Navigator.of(_context).isLastRouteNav1) {
      Navigator.of(_context).pop();
      return; // We handled it
    }
    return RootVRouterData.of(_context).systemPopFromElement(
      _vRouteElementNode.getVRouteElementToSystemPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      hash: hash,
      newHistoryState: newHistoryState,
    );
  }

  @override
  void replaceHistoryState(Map<String, String> historyState) => to(
        url,
        historyState: historyState,
        isReplacement: true,
      );

  static LocalVRouterData of(BuildContext context) {
    final localVRouterData =
        context.dependOnInheritedWidgetOfExactType<LocalVRouterData>();
    if (localVRouterData == null) {
      throw FlutterError(
          'LocalVRouter.of(context) was called with a context which does not contain a LocalVRouterData.\n'
          'The context used to retrieve LocalVRouterData must be that of a widget that '
          'is a descendant of a LocalVRouterData widget.');
    }
    return localVRouterData;
  }
}
