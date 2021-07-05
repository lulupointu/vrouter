import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:vrouter/src/core/route.dart';
import 'package:vrouter/src/core/vrouter_delegate.dart';
import 'package:vrouter/src/vlogs.dart';
import 'package:vrouter/src/vrouter_scope.dart';

import 'vurl_history/vrouter_modes.dart';
import 'vurl_history/vurl_history.dart';

/// Whether [_customUrlStrategy] has been set or not.
///
/// It is valid to set [_customUrlStrategy] to null, so we can't use a null
/// check to determine whether it was set or not. We need an extra boolean.
bool _isUrlStrategySet = false;

/// A top level widget which keeps the part of the state of [VRouter]
/// which needs to always persist
class VRouterScope extends StatefulWidget {
  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterMode vRouterMode;

  final Widget child;

  VRouterScope({
    Key? key,
    required this.child,
    this.vRouterMode = VRouterMode.hash,
  }) : super(key: key) {
    // Setup the url strategy (if hash, do nothing since it is the default)
    if (!_isUrlStrategySet && vRouterMode == VRouterMode.history) {
      try {
        setPathUrlStrategy();
      } catch (e) {
        VLogPrinter.show(VMultiUrlStrategyLog());
      }

      _isUrlStrategySet = true;
    }
  }

  @override
  _VRouterScopeState createState() =>
      _VRouterScopeState(vRouterMode: vRouterMode);

  static VRouterScopeData of(BuildContext context) {
    VRouterScopeData? vRouterScope =
        context.dependOnInheritedWidgetOfExactType<VRouterScopeData>();

    if (vRouterScope == null) {
      throw VRouterScopeNotFoundException(
          widgetType: context.widget.runtimeType);
    }

    return vRouterScope;
  }
}

class _VRouterScopeState extends State<VRouterScope> {
  final vUrlStrategy;

  _VRouterScopeState({required VRouterMode vRouterMode})
      : vUrlStrategy = VHistory.implementation(vRouterMode);

  @override
  Widget build(BuildContext context) {
    try {
      VRouterScope.of(context);
    } on VRouterScopeNotFoundException {
      return VRouterScopeData(
        child: widget.child,
        vRouterMode: widget.vRouterMode,
        vHistory: vUrlStrategy,
        vRoute: vRoute,
        setLatestVRoute: setLatestVRoute,
      );
    }

    throw _VRouterScopeDuplicateError(widgetType: widget.child.runtimeType);
  }

  /// This represent the latest [VRoute] that [VRouterDelegate] produced
  VRoute? vRoute;

  void setLatestVRoute(VRoute newVRoute) {
    setState(() {
      vRoute = newVRoute;
    });
  }
}

class VRouterScopeNotFoundException implements Exception {
  /// The type of the Widget requesting the value
  final Type widgetType;

  VRouterScopeNotFoundException({required this.widgetType});

  @override
  String toString() => '''
Error: Could not find VRouterScope above this $widgetType Widget.

If you are using ...App.router with VRouterDelegate, make sure that you wrap ...App.router
in VRouterScope.

If you are using VRouter, CupertinoVRouter or WidgetsVRouter directly, this is a bug, please fill an issue at https://github.com/lulupointu/vrouter/issues.
''';
}

class _VRouterScopeDuplicateError implements Exception {
  /// The type of the Widget requesting the value
  final Type widgetType;

  _VRouterScopeDuplicateError({required this.widgetType});

  @override
  String toString() => '''
Error: Multiple VRouterScope where found above this $widgetType Widget.

If you are using VRouter, CupertinoVRouter or WidgetsVRouter directly, VRouterScope is inserted automatically so remove the top one.

If you are using ...App.router with VRouterDelegate, make sure that you did not use multiple VRouterScope.
''';
}

class VRouterScopeData extends InheritedWidget {
  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterMode vRouterMode;

  /// Stores the encountered location of the lifecycle of this app
  final VHistory vHistory;

  VRouterScopeData({
    required Widget child,
    required this.vRouterMode,
    required this.vHistory,
    required this.vRoute,
    required this.setLatestVRoute,
  }) : super(child: child);

  @override
  bool updateShouldNotify(VRouterScopeData old) => false;

  final VRoute? vRoute;

  final void Function(VRoute newVRoute) setLatestVRoute;
}

class VMultiUrlStrategyLog extends VLog {
  @override
  VLogLevel get level => VLogLevel.warning;

  @override
  String get message =>
      'You tried to set the url strategy several time, this should never happen.\n'
      'If a package that you use (other than VRouter) sets the url strategy, please use the other package.';
}
