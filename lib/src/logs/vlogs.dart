import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// The log level of every log from VRouter
///
///
/// Here is examples of the meanings:
///   - info: Successful navigation
///   - warning: Tried to set url strategy several time
///   - error: Failed navigation
enum VLogLevel {
  info,
  warning,
}

/// The base class for every VRouter logs
@immutable
abstract class VLog {
  /// The severity level of the log
  VLogLevel get level;

  /// The message to print when printing this log
  ///
  ///
  /// Note that this is the pure message and is not
  /// concerned with color
  String get message;

  @override
  @nonVirtual
  String toString() => message;
}

/// Enum of all possible method to navigate that
/// [VRouterNavigator] has
enum VNavigationMethod {
  to,
  toNamed,
  toExternal,
  toSegments,
  pop,
  systemPop,
  browserPush,
  browserHistory,
  vHistory,
}

/// The base log for any navigation log (successful, stopped or failed)
abstract class VNavigationToLog extends VLog {
  /// The navigation method which was used to navigate
  VNavigationMethod get vNavigationMethod;

  /// The url this navigation log is concerned with
  String? get url;
}

/// A log to display when successfully navigating to [url]
class VSuccessfulNavigationTo extends VNavigationToLog {
  @override
  final VNavigationMethod vNavigationMethod;

  /// The url to navigate to
  final String url;

  VSuccessfulNavigationTo({
    required this.vNavigationMethod,
    required this.url,
  });

  @override
  VLogLevel get level => VLogLevel.info;

  @override
  String get message =>
      'Successfully navigated to "$url" using VRouter.${vNavigationMethod.toString().substring('VNavigationMethod.'.length)}';
}

/// A log to display when one tried to navigating to [url]
/// be was stopped
class VStoppedNavigationTo extends VNavigationToLog {
  @override
  final VNavigationMethod vNavigationMethod;

  /// The url one tried to navigate to before being stopped
  final String url;

  VStoppedNavigationTo({
    required this.vNavigationMethod,
    required this.url,
  });

  @override
  VLogLevel get level => VLogLevel.info;

  @override
  String get message =>
      'Stopped the navigation to $url which used VRouter.${vNavigationMethod.toString().substring('VNavigationMethod.'.length)}';
}
