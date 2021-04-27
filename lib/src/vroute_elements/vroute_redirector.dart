part of '../main.dart';

/// Use this route to redirect from [path] to [redirectTo]
///
/// Note that this uses [pushReplacement] so if you are on the web, [path] will not
/// appear in the web history once redirected
class VRouteRedirector extends VRouteElementBuilder {
  /// The path that should be matched
  final String path;

  /// The path where the user will be redirected
  final String redirectTo;

  VRouteRedirector({
    required this.path,
    required this.redirectTo,
  });

  @override
  Future<void> beforeEnter(VRedirector vRedirector) async =>
      vRedirector.pushReplacement(redirectTo);

  @override
  List<VRouteElement> buildRoutes() => [
        VPath(path: path, stackedRoutes: []),
      ];
}
