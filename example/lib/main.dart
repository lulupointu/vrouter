import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import 'UI/authentication_widget.dart';
import 'UI/in_app_widgets.dart';

void main() {
  runApp(
    VRouter(
      debugShowCheckedModeBanner: false, // VRouter acts as a MaterialApp
      mode: VRouterModes.history, // Remove the '#' from the url
      buildTransition: (animation, ___, child) {
        // We set a default transition to every route
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      routes: [
        VStacked(
          beforeLeave: (_, __, ___, ____) async {
            print('VRoute beforeLeave');
            return true;
          },
          beforeEnter: (_, __, ___) async {
            print('VRoute beforeEnter');
            return true;
          },
          afterEnter: (_, __, ___) {
            print('VRoute afterEnter');
            return;
          },
          path: '/login',
          widget: LoginWidget(),
        ),

        VStacked(
          key: ValueKey('MyScaffold'),
          widget: MyScaffold(),
          subroutes: [
            VChild(
              path: '/settings',
              name: 'settings',
              widget: SettingWidget(),

              // Custom transition
              buildTransition: (animation, ___, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
            VChild(
              path: '/profile/:username', // :username is a path parameter and can be any value
              name: 'profile', // We also give a name for easier navigation
              widget: ProfileWidget(),

              // The path '/profile' might also match this path
              // In this case, we must handle the empty pathParameter
              aliases: ['/profile'],
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
              onPressed: () => setState(() => (_formKey.currentState.validate())
                  ? VRouterData.of(context).push('/profile/$name')
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You are connected'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: (VRouteElementData.of(context).vChildName == 'settings') ? 1 : 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
        onTap: (int index) {
          if (index == 0) {
            // We use the name to navigate
            // We can specify the username in a map
            // Since we are on settings, the username is stored in the VRouter history state
            print('VRouterData.of(context).historyState: ${VRouterData.of(context).historyState}');
            VRouterData.of(context).pushNamed('profile',
                pathParameters: {'username': VRouterData.of(context).historyState});
          } else {
            // We push the settings and store the username in the VRouter history state
            // We can access this username via the global path parameters (stored in VRoute)
            print('VRouteData.of(context).pathParameters[\'username\']: ${VRouteData.of(context).pathParameters['username']}');
            VRouterData.of(context).push('/settings',
                routerState: VRouteData.of(context).pathParameters['username']);
          }
        },
      ),
      body: VRouteElementData.of(context).vChild,

      // This FAB is shared with login and shows hero animations working with no issues
      floatingActionButton: FloatingActionButton(
        onPressed: () => VRouterData.of(context).push('/login'),
        child: Icon(Icons.logout),
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
    print('VRouteData.of(context).pathParameters[\'username\']: ${VRouteData.of(context).pathParameters['username']}');
    print("VRouteElementData.of(context).pathParameters['username']: ${VRouteElementData.of(context).pathParameters['username']}");
    return VNavigationGuard(
      afterEnter: (context, __, ___) => getCountFromState(context),
      afterUpdate: (context, __, ___) => getCountFromState(context),
      beforeLeave: (context, __, ___, saveHistoryState) async {
        saveHistoryState('$count');
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
                'Hello ${VRouteElementData.of(context).pathParameters['username'] ?? 'stranger'}',
                style: textStyle.copyWith(fontSize: textStyle.fontSize + 2),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () => setState(() => count++),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blueAccent,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
      count = (VRouteElementData.of(context).historyState == null)
          ? 0
          : int.tryParse(VRouteElementData.of(context).historyState ?? '0');
    });
  }
}

final textStyle = TextStyle(color: Colors.black, fontSize: 16);
final buttonTextStyle = textStyle.copyWith(color: Colors.white);
