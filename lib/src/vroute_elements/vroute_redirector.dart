part of '../main.dart';

/// Use this route to redirect from [path] to [redirectTo]
///
/// Note that this uses [pushReplacement] so if you are on the web, [path] will not
/// appear in the web history once redirected
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
