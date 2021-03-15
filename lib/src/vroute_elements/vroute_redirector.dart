part of '../main.dart';

class VRouteRedirector extends VRouteElementWithPath {
  final String redirectTo;

  VRouteRedirector({
    required this.redirectTo,
    required String path,
  }) : super(path: path);

  @override
  List<VRouteElement> get subroutes => [];

  @override
  Future<void> Function(VRedirector vRedirector) get beforeEnter =>
      (vRedirector) async {
        vRedirector.pushReplacement(redirectTo);
      };
}
