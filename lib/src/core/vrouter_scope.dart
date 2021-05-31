import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:vrouter/src/core/vlocations.dart';
import 'package:vrouter/src/core/vrouter_modes.dart';

/// Whether [_customUrlStrategy] has been set or not.
///
/// It is valid to set [_customUrlStrategy] to null, so we can't use a null
/// check to determine whether it was set or not. We need an extra boolean.
bool _isUrlStrategySet = false;

class VRouterScope extends StatefulWidget {
  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterModes vRouterMode;

  final Widget child;

  VRouterScope({
    Key? key,
    required this.child,
    this.vRouterMode = VRouterModes.hash,
  }) : super(key: key) {
    // Setup the url strategy (if hash, do nothing since it is the default)
    if (!_isUrlStrategySet && vRouterMode == VRouterModes.history) {
      setPathUrlStrategy();
      _isUrlStrategySet = true;
    }
  }

  @override
  _VRouterScopeState createState() =>
      _VRouterScopeState(vRouterMode: vRouterMode);

  static _VRouterScopeData of(BuildContext context) {
    _VRouterScopeData? vRouterScope =
        context.dependOnInheritedWidgetOfExactType<_VRouterScopeData>();

    if (vRouterScope == null) {
      throw VRouterScopeNotFoundException(
          widgetType: context.widget.runtimeType);
    }

    return vRouterScope;
  }
}

class _VRouterScopeState extends State<VRouterScope> {
  final vLocations;

  _VRouterScopeState({required VRouterModes vRouterMode})
      : vLocations = VLocations(vRouterMode: vRouterMode);

  @override
  Widget build(BuildContext context) {
    try {
      VRouterScope.of(context);
    } on VRouterScopeNotFoundException {
      return _VRouterScopeData(
        child: widget.child,
        vRouterMode: widget.vRouterMode,
        vLocations: vLocations,
      );
    }

    throw _VRouterScopeDuplicateError(widgetType: widget.child.runtimeType);
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

class _VRouterScopeData extends InheritedWidget {
  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterModes vRouterMode;

  /// Stores the encountered location of the lifecycle of this app
  final VLocations vLocations;

  _VRouterScopeData({
    required Widget child,
    required this.vRouterMode,
    required this.vLocations,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_VRouterScopeData old) => false;
}
