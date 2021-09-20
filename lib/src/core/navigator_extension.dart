import 'package:flutter/material.dart';

/// An extension on [NavigatorState] which allows us to check
/// whether the last route is nav1 pushed
extension NavigatorStateExtension on NavigatorState {
  /// Whether the last route is nav1 pushed
  bool get isLastRouteNav1 {
    late bool _isLastRouteNav1;
    this.popUntil((route) {
      _isLastRouteNav1 = !(route.settings is Page);
      return true;
    });
    return _isLastRouteNav1;
  }
}
