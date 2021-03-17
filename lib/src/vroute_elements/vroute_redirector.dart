part of '../main.dart';

class VRouteRedirector extends VRouteElementWithPath {
  final String redirectTo;

  VRouteRedirector({
    required String path,
    required this.redirectTo,
  }) : super(path: path);

  @override
  List<VRouteElement> get stackedRoutes => [];

  @override
  Future<void> Function(VRedirector vRedirector) get beforeEnter =>
      (vRedirector) async {
        vRedirector.pushReplacement(redirectTo);
      };
}
