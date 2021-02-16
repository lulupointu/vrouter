part of 'main.dart';

/// This exception is raised when a user tries to navigate to a path which is unspecified
class InvalidUrlException implements Exception {
  final String url;

  InvalidUrlException({@required this.url});

  @override
  String toString() =>
      "The url '$url' has no matching route.\nConsider using VRoute(path: '.*', widget: UnknownPathWidget()) at the bottom of your VRouter routes to catch any wrong route.";
}
