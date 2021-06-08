import 'package:flutter/material.dart';
import 'package:vrouter/src/core/vrouter_delegate.dart';
import 'package:vrouter/vrouter.dart';

/// This [NavigatorObserver] is used to observe the events caused by the Navigator 1.0 API
///
/// It helps us determine what to do when pop is called
class VNavigatorObserver extends NavigatorObserver {
  /// Whether or not a route was pushed using the Navigator 1.0 API
  ///
  /// This is useful when calling pop or systemPop. Since when such a route exists,
  /// it should be popped and [VRouterDelegate.pop] should not.
  bool get hasNavigator1Pushed =>
      (navigator == null) ? false : _pushCount != (navigator!.widget.pages.length);

  /// How much time Navigator.push was used in the context of this [navigator]
  ///
  /// This is useful to know how much time to call pop in order to pop every navigator 1.0 push
  int get navigator1PushCount {
    return (navigator != null && hasNavigator1Pushed)
        ? _pushCount - navigator!.widget.pages.length
        : 0;
  }

  @override
  void didPush(Route route, Route? previousRoute) => _pushCount++;

  @override
  void didPop(Route route, Route? previousRoute) => _pushCount--;

  @override
  void didRemove(Route route, Route? previousRoute) => _pushCount--;

  int __pushCount = 0;

  int get _pushCount => __pushCount;

  set _pushCount(int newPushCount) {
    // The delta should be kept
    final delta = newPushCount - __pushCount;

    // Reset [_pushCount] to 0 is needed
    resetIfNeeded();

    // In any case, add the delta
    __pushCount += delta;
  }

  /// Reset [_pushCount] to 0 if the navigator has changed
  ///
  /// This should be called before updating [_pushCount]
  void resetIfNeeded() {
    if (_oldNavigator != navigator) {
      _oldNavigator = navigator;
      __pushCount = 0;
    }
  }

  /// The previous [NavigatorState] associated to this [VNavigatorObserver]
  ///
  /// This is used to know whether [_pushCount] should be reset or not
  NavigatorState? _oldNavigator;
}
