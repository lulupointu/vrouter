import 'package:flutter/material.dart';
import 'package:vrouter/src/core/vlocations.dart';

class VRouterScope extends InheritedWidget {
  final VLocations vLocations;

  VRouterScope({
    required Widget child,
  })   : vLocations = VLocations(),
        super(child: child);

  static VRouterScope of(BuildContext context) {
    VRouterScope? vRouterScope =
        context.dependOnInheritedWidgetOfExactType<VRouterScope>();

    if (vRouterScope == null) {
      throw VRouterScopeNotFoundException(
          widgetType: context.widget.runtimeType);
    }

    return vRouterScope;
  }

  @override
  bool updateShouldNotify(VRouterScope old) => false;
}

class VRouterScopeNotFoundException implements Exception {
  /// The type of the Widget requesting the value
  final Type widgetType;

  VRouterScopeNotFoundException({required this.widgetType});

  @override
  String toString() => '''
Error: Could not find VRouterScope above this $widgetType Widget

If you are using ...App.router with VRouterDelegate, make sure that you wrap ...App.router
in VRouterScope.

If you are using VRouter, CupertinoVRouter or WidgetsVRouter directly, this is a bug, please fill an issue at https://github.com/lulupointu/vrouter/issues
''';
}
