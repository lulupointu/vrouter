import 'dart:io' as io show Platform;

class Platform extends io.Platform {
  /// Whether the operating system is a version of
  /// [Linux](https://en.wikipedia.org/wiki/Linux).
  ///
  /// This value is `false` if the operating system is a specialized
  /// version of Linux that identifies itself by a different name,
  /// for example Android (see [isAndroid]).
  static final bool isLinux = io.Platform.isLinux;

  /// Whether the operating system is a version of
  /// [macOS](https://en.wikipedia.org/wiki/MacOS).
  static final bool isMacOS = io.Platform.isMacOS;

  /// Whether the operating system is a version of
  /// [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows).
  static final bool isWindows = io.Platform.isWindows;

  /// Whether the operating system is a version of
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29).
  static final bool isAndroid = io.Platform.isAndroid;

  /// Whether the operating system is a version of
  /// [iOS](https://en.wikipedia.org/wiki/IOS).
  static final bool isIOS = io.Platform.isIOS;

  /// Whether the operating system is a version of
  /// [Fuchsia](https://en.wikipedia.org/wiki/Google_Fuchsia).
  static final bool isFuchsia = io.Platform.isFuchsia;

  /// Whether the operating system is a version of
  /// [Web](https://en.wikipedia.org/wiki/Web).
  static final bool isWeb = false;
}
