import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

final key = GlobalKey<VRouterState>();

void main() {
  runApp(
    VRouter(
      debugShowCheckedModeBanner: false, // VRouter acts as a MaterialApp
      mode: VRouterModes.history, // Remove the '#' from the url
      routes: [
        VWidget(
          path: '/login',
          widget: LoginWidget(),
          subroutes: [
            VGuard(
              beforeEnter: (_) async => print('MyScaffold beforeEnter'),
              beforeLeave: (_, __) async => print('MyScaffold beforeLeave'),
              beforeUpdate: (_) async => print('MyScaffold beforeUpdate'),
              afterUpdate: (_, __, ___) async =>
                  print('MyScaffold afterUpdate'),
              afterEnter: (_, __, ___) async => print('MyScaffold afterEnter'),
              subroutes: [
                VNester(
                  path: null,
                  name: 'VNester1',
                  widgetBuilder: (child) => MyScaffold(
                    child,
                    title: 'VNester1',
                  ),
                  nestedRoutes: [
                    VWidget(
                        path: '/settings',
                        widget: InfoWidget(),

                        // Custom transition
                        buildTransition: (animation, ___, child) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        subroutes: [
                          VNester(
                            path: null,
                            name: 'VNester2',
                            widgetBuilder: (child) => MyScaffold(
                              child,
                              title: 'VNester2',
                            ),
                            nestedRoutes: [
                              VGuard(
                                beforeEnter: (_) async =>
                                    print('ProfileWidget beforeEnter'),
                                beforeLeave: (_, __) async =>
                                    print('ProfileWidget beforeLeave'),
                                beforeUpdate: (_) async =>
                                    print('ProfileWidget beforeUpdate'),
                                afterUpdate: (_, __, ___) async =>
                                    print('ProfileWidget afterUpdate'),
                                afterEnter: (_, __, ___) async =>
                                    print('ProfileWidget afterEnter'),
                                subroutes: [
                                  VWidget(
                                    path: '/profile/:username',
                                    // :username is a path parameter and can be any value
                                    name: 'profile',
                                    // We also give a name for easier navigation
                                    widget: ProfileWidget(),

                                    // The path '/profile' might also match this path
                                    // In this case, we must handle the empty pathParameter
                                    aliases: ['/profile'],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                  ],
                ),
              ],
            ),
          ],
        ),
        // This redirect every unknown routes to /login
        VRouteRedirector(
          redirectTo: '/login',
          path: r':_(.*)',
        ),
      ],
    ),
  );
}

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  String name = 'bob';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Enter your name to connect: '),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                        textAlign: TextAlign.center,
                        onChanged: (value) => name = value,
                        initialValue: 'bob',
                        validator: (_) {
                          return (name == '')
                              ? 'Please enter your name'
                              : name.contains('/')
                                  ? 'Please don\'t put \'\\ in your name'
                                  : null;
                        }),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

            // This FAB is shared and shows hero animations working with no issues
            FloatingActionButton(
              heroTag: 'FAB',
              onPressed: () => setState(() => (_formKey.currentState.validate())
                  ? VRouter.of(context).push('/profile/$name')
                  : null),
              child: Icon(Icons.login),
            )
          ],
        ),
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget vChild;
  final String title;

  const MyScaffold(
    this.vChild, {
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIndex = (VRouter.of(context).url.contains('profile')) ? 0 : 1;

    return VNavigationGuard(
      beforeLeave: (_, __) async => print('ProfileWidget beforeLeave'),
      beforeUpdate: (_) async => print('ProfileWidget beforeUpdate'),
      afterUpdate: (_, __, ___) async => print('ProfileWidget afterUpdate'),
      afterEnter: (_, __, ___) async => print('ProfileWidget afterEnter'),
      child: Scaffold(
        appBar: AppBar(
          title: Text('You are connected | $title'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // We check the vChild name to known where we are
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_outline), label: 'Info'),
          ],
          onTap: (int index) {
            if (currentIndex != index) {
              if (index == 0) {
                // We use the name to navigate
                // We can specify the username in a map
                // Since we are on settings, the username is stored in the VRouter history state
                VRouter.of(context).pushNamed('profile', pathParameters: {
                  'username': VRouter.of(context).historyState['username']
                });
              } else if (index == 1 && currentIndex != 1) {
                // We push the settings and store the username in the VRouter history state
                // We can access this username via the global path parameters (stored in VRoute)
                VRouter.of(context).push('/settings', historyState: {
                  'username': VRouter.of(context).pathParameters['username']
                });
              }
            }
          },
        ),
        body: vChild,

        // This FAB is shared with login and shows hero animations working with no issues
        floatingActionButton: FloatingActionButton(
          heroTag: 'FAB',
          onPressed: () => VRouter.of(context).push('/login'),
          child: Icon(Icons.logout),
        ),
      ),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    // VNavigationGuard allows you to react to navigation events locally
    return VNavigationGuard(
      // When entering or updating the route, we try to get the count from the local history state
      // This history state will be NOT null if the user presses the back button for example
      afterEnter: (context, __, ___) => getCountFromState(context),
      afterUpdate: (context, __, ___) => getCountFromState(context),

      // Before leaving we save the count local history state
      beforeLeave: (_, saveHistoryState) async {
        print('ProfileWidget VNavigationGuard beforeLeave');
        saveHistoryState({'count': '$count'});
        return true; // We return true because we still want the redirect to happen
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // We can access this username via the local path parameters (stored in VRouteElement)
                'Hello ${VRouter.of(context).pathParameters['username'] ?? 'stranger'}',
                style: textStyle.copyWith(fontSize: textStyle.fontSize + 2),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  print('historyState: ${VRouter.of(context).historyState}');
                  VRouter.of(context).replaceHistoryState({
                    ...VRouter.of(context).historyState,
                    'count': '${count + 1}',
                  });
                  setState(() => count++);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blueAccent,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Your pressed this button $count times',
                    style: buttonTextStyle,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'This number is saved in the history state so if you are on the web leave this page and hit the back button to see this number restored!',
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getCountFromState(BuildContext context) {
    setState(() {
      count = (VRouter.of(context).historyState['count'] == null)
          ? 0
          : int.tryParse(VRouter.of(context).historyState['count'] ?? '0');
    });
  }
}

class InfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // We can access this username via the history state (stored in VRouter)
              'Here are you empty info, ${VRouter.of(context).historyState['username'] ?? 'stranger'}',
              style: textStyle.copyWith(fontSize: textStyle.fontSize + 2),
            ),
            SizedBox(height: 50),
            Text(
              'As you could see, the custom animation played when you went here',
              style: textStyle.copyWith(fontSize: textStyle.fontSize + 2),
            ),
          ],
        ),
      ),
    );
  }
}

final textStyle = TextStyle(color: Colors.black, fontSize: 16);
final buttonTextStyle = textStyle.copyWith(color: Colors.white);

//
// VRouter(
//   subroute: VSwitcher(
//     subroutes: [
//       VPath(
//         path: '/login',
//         subroute: VWidget(
//           widget: LoginPage(),
//         ),
//       ),
//       VChildGetter(
//         widgetBuilder: (vChild) => MyScaffold(vChild)
//         subroute: VSwitcher(
//           subroutes: [
//             VPath(
//               path: '/home',
//               subroute: VWidget(
//                 widget: HomePage(),
//               ),
//             ),
//             VPath(
//               path: '/settings',
//               subroute: VWidget(
//                 widget: SettingsPage(),
//               ),
//             ),
//           ]
//         ),
//       ),
//     ],
//   ),
// );
//
// VRouter(
//   subroute: VStacker(
//     subroutes: [
//       VChildGetter(
//         widgetBuilder: (vChild) => MyScaffold(vChild)
//         subroute: VSwitcher(
//           subroutes: [
//             VPath(
//               path: '/home',
//               subroute: VWidget(
//                 widget: HomePage(),
//               ),
//             ),
//             VPath(
//               path: '/settings',
//               subroute: VWidget(
//                 widget: SettingsPage(),
//               ),
//             ),
//           ]
//         ),
//       ),
//       VPath(
//         path: '/comments/:id',
//           subroute: VWidget(
//           widget: LoginPage(),
//         ),
//       ),
//     ],
//   ),
// );
//
//
// void f() {
//   VRouter(
//     subroute: [
//       VStacked(
//         path: '/login',
//         widget: LoginWidget(),
//       ),
//       VStacked(
//         widgetBuilder: (vChild) => MyScaffold(vChild),
//         subroutes: [
//           VChild(
//             path: '/home',
//             widget: HomePage(),
//           ),
//           VChild(
//             path: '/settings',
//             widget: SettingsPage(),
//           ),
//         ]
//       ),
//     ],
//   );
// }
