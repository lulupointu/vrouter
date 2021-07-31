import 'vrouter_data.dart';

/// A concrete implementation of [VRouterData]
class VRouterDataImpl extends VRouterData {
  @override
  Map<String, String> historyState;

  @override
  List<String> names;

  @override
  Map<String, String> pathParameters;

  @override
  String? previousUrl;

  @override
  Map<String, String> queryParameters;

  @override
  String url;

  @override
  String get path => Uri.parse(url).path;

  VRouterDataImpl({
    required this.previousUrl,
    required this.url,
    required this.pathParameters,
    required this.queryParameters,
    required this.historyState,
    required this.names,
  });
}
