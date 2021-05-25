import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A routerDelegate which automatically creates a Navigator
/// See the details of each attribute to see what they can be used for
class VRouterDelegateHelper<T extends Object> extends RouterDelegate<T>
    with ChangeNotifier {
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver>? observers;
  final Widget? child;
  final List<Page>? pages;
  final bool Function(Route<dynamic>, dynamic)? onPopPage;
  final Future<bool> Function()? onSystemPopPage;

  VRouterDelegateHelper({
    this.child,
    this.pages,
    this.navigatorKey,
    this.observers,
    this.onPopPage,
    this.onSystemPopPage,
  }) : assert(pages != null || child != null);

  @override
  Widget build(BuildContext context) {
    if (pages != null) {
      return Navigator(
        key: navigatorKey,
        observers: observers ?? [],
        pages: pages!,
        onPopPage: onPopPage,
      );
    }
    if (child != null) {
      return child!;
    }

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;

  @override
  Future<bool> popRoute() async {
    if (onSystemPopPage != null) {
      return onSystemPopPage!();
    }
    return false;
  }
}
