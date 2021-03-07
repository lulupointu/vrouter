import 'package:flutter/widgets.dart';
import 'package:simple_url_handler/simple_url_handler.dart';
import 'package:vrouter/src/new_vrouter/vroute_element.dart';

/// The widget which handles the general information about the url
class VRouterScope extends StatefulWidget {
  final Widget child;

  const VRouterScope({Key? key, required this.child}) : super(key: key);

  @override
  _VRouterScopeState createState() => _VRouterScopeState();
}

class _VRouterScopeState extends State<VRouterScope> {
  String url = '/';

  String get path => Uri.parse(url).path;

  late BuildContext simpleUrlHandlerContext;

  @override
  Widget build(BuildContext context) {
    return SimpleUrlHandler(
      urlToAppState: (context, routeInformation) async {
        if (routeInformation.location != null) {
          setState(() => this.url = routeInformation.location!);
        }
      },
      appStateToUrl: () => RouteInformation(location: url),
      child: Builder(
        builder: (BuildContext context) {
          simpleUrlHandlerContext = context;

          return VRouterScopeData(
            child: widget.child,
            push: push,
            notifyUrlChange: notifyUrlChange,
            url: url,
          );
        },
      ),
    );
  }

  void push(String url) {
    this.url = url;
    SimpleUrlNotifier.of(simpleUrlHandlerContext).notify();
    setState(() {});
  }

  void notifyUrlChange(String newUrl) {
    this.url = newUrl;
    SimpleUrlNotifier.of(simpleUrlHandlerContext).notify();
  }
}

/// The widget which holds general information about the url
class VRouterScopeData extends InheritedWidget {
  const VRouterScopeData({
    Key? key,
    required Widget child,
    required this.url,
    required this.push,
    required this.notifyUrlChange,
  }) : super(key: key, child: child);

  final String url;

  String get path => Uri.parse(url).path;

  final void Function(String url) push;

  final void Function(String newUrl) notifyUrlChange;

  static VRouterScopeData of(BuildContext context) {
    final vRouterScopeData = context.dependOnInheritedWidgetOfExactType<VRouterScopeData>();
    if (vRouterScopeData == null) {
      throw FlutterError(
          'vRouterScopeData.of(context) was called with a context which does not contain a vRouterScope.\n'
          'The context used to retrieve vRouterScope must be that of a widget that '
          'is a descendant of a vRouterScope widget.');
    }
    return vRouterScopeData;
  }

  @override
  bool updateShouldNotify(VRouterScopeData old) {
    return url != old.url;
  }
}
