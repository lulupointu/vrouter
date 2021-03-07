// import 'package:flutter/material.dart';
// import 'package:vrouter/src/new_vrouter/vroute_element.dart';
// import 'package:vrouter/src/new_vrouter/vrouter.dart';
// import 'package:vrouter/src/new_vrouter/vrouter_scope.dart';
//
// main() {
//   runApp(VRouterScope(child: RootWidget()));
// }
//
// class RootWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return VRouter(
//       routes: [
//         VRouteElement(
//           path: '/',
//           child: HomeWidget(),
//         ),
//         VRouteElement(
//           path: '/settings',
//           child: SettingsWidget(),
//         ),
//       ],
//     );
//   }
// }
//
// class HomeWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text('Home'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => VRouterScopeData.of(context).push('/settings'),
//       ),
//     );
//   }
// }
//
// class SettingsWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             Container(color:Colors.red, child: Text('Settings')),
//             Container(
//               height: 50,
//               child: VRouter(
//                 routes: [
//                   VRouteElement(
//                     path: '/',
//                     child: HomeWidget(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => VRouterScopeData.of(context).push('/'),
//       ),
//     );
//   }
// }

// main() {
//   String path = '/test/:id/:ok*';
//   final string = '/test/12/ij/456';
//
//   List<String> pathParametersKeys = [];
//
//   // Check if there is no "*" in the middle of the path
//   final firstAsteriskIndex = path.indexOf('*');
//   if (firstAsteriskIndex != -1 && firstAsteriskIndex != path.length - 1) {
//     throw Exception('Trailing param should only be at the end of a path');
//   }
//
//   // Change all path parameters to ([^:.?])
//   final pathParametersToRegexp = RegExp(r'(:.*?)(?=[\/]|$)');
//   path = path.replaceAllMapped(pathParametersToRegexp, (match) {
//     pathParametersKeys.add(match.group(1).substring(1));
//     return r'(.*?)(?=[\/]|$)';
//   });
//
//   // Change any trailing * to (.*)
//   final splatRegExp = RegExp(r'\*$');
//   path = path.replaceAllMapped(splatRegExp, (match) {
//     pathParametersKeys.add('*');
//     return '(.*)';
//   });
//
//   print('pathParametersKeys: $pathParametersKeys');
//
//   print('path: $path');
//
//   final bool hasSubroutes = true;
//
//   if (hasSubroutes) {
//     final match = RegExp(path).matchAsPrefix(string);
//     if (match != null) {
//       print('Match');
//       Map<String, String> pathParameters = {
//         for (var keyIndex = 0; keyIndex < pathParametersKeys.length; keyIndex++)
//           pathParametersKeys[keyIndex]: match.group(keyIndex + 1)
//       };
//       print('pathParameters: $pathParameters');
//     } else {
//       print('No match');
//     }
//   } else {
//     final match = RegExp(path + r'$').matchAsPrefix(string);
//     if (match != null) {
//       print('Match');
//       Map<String, String> pathParameters = {
//         for (var keyIndex = 0; keyIndex < pathParametersKeys.length; keyIndex++)
//           pathParametersKeys[keyIndex]: match.group(keyIndex + 1)
//       };
//       print('pathParameters: $pathParameters');
//     } else {
//       print('No match');
//     }
//   }
//
//   // print('match: ${RegExp(path).matchAsPrefix(string).groups([1])}');
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/src/new_vrouter/vroute_element.dart';
import 'package:vrouter/src/new_vrouter/vrouter.dart';
import 'package:vrouter/src/new_vrouter/vrouter_scope.dart';

main() {
  runApp(
    BaseWidget(),
  );
}

class BaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VRouterScope(
      child: Material(
        child: VRouter(
          routes: [
            VWidget(
              path: '/',
              child: MyWidget('login'),
            ),
            VWidget(
              path: 'inapp/*',
              child: MyScaffold(),
            ),
          ],
        ),
      ),
    );
  }
}

class MyScaffold extends StatefulWidget {
  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  int? index;

  @override
  Widget build(BuildContext context) {
    index = VRouterScopeData.of(context).url.startsWith('/inapp/home')
        ? 0
        : VRouterScopeData.of(context).url.startsWith('/inapp/settings')
            ? 1
            : index;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index ?? 0,
        onTap: (index) =>
            VRouterScopeData.of(context).push(index == 0 ? '/inapp/home' : '/inapp/settings'),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'settings'),
        ],
      ),
      body: VRouter(
        routes: [
          VWidget(
            path: '',
            child: MyWidget('home'),
            subroutes: [
              VWidget(
                path: '*',
                child: MyWidget('home'),
              ),
            ],
          ),
          VWidget(
            path: 'settings',
            child: MyWidget('settings'),
          ),
          VRedirector(path: '*', to: '/home'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => VRouterScopeData.of(context).push('/'),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  final String title;

  const MyWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
