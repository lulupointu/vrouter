import 'package:vrouter/src/vrouter_widgets.dart';

abstract class VRouterData {
  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  String? get url;

  /// Previous url that was synced with the state
  String? get previousUrl;

  /// Path of [url]
  ///
  /// This is the same as the url WITHOUT the queryParameters
  String? get path => url != null ? Uri.parse(url!).path : null;

  /// Path of [previousUrl]
  ///
  /// This is the same as the url WITHOUT the queryParameters
  String? get previousPath =>
      previousUrl != null ? Uri.parse(previousUrl!).path : null;

  /// The hash of the url (a.k.a fragment)
  ///
  ///
  /// This can be used with [VAnchor] to easily create anchors
  String? get hash =>
      url != null ? Uri.decodeComponent(Uri.parse(url!).fragment) : null;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using
  /// [context.vRouter.to(context.vRouter.url!, historyState: newHistoryState, isReplacement: true)]
  Map<String, String> get historyState;

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  Map<String, String> get pathParameters;

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  Map<String, String> get queryParameters;

  /// A list of every names corresponding to the [VRouteElement]s in
  /// the current stack
  List<String> get names;
}
