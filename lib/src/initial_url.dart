part of 'main.dart';

class InitialUrl {
  final String? url;
  final bool fromValidates;

  const InitialUrl({this.url, this.fromValidates = false})
      : assert(
          url == null || fromValidates == false,
          'You can either initialize the url from the state or from a custom one but not both.',
        ),
        assert(
          url != null || fromValidates != false,
          'If you use initialUrl, either provide a url of set fromValidates to true to infer the url from the state.',
        );
}
