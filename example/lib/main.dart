import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  runApp(
    VRouter(
      routes: [
        VNester(
          path: '/settings',
          widgetBuilder: (child) => Scaffold(
            body: child,
            bottomNavigationBar: Text('BottomNavigationBar'),
          ),
          nestedRoutes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (context) => Material(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InkWell(
                          onTap: () => context.vRouter.systemPop(),
                          child: Text('MaterialPageRoute'),
                        ),
                      ),
                    ),
                    child: Text('VWidget1'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Extend VRouteElementBuilder to create your own VRouteElement
class ConnectedRoutes extends VRouteElementBuilder {
  static final String profile = 'profile';

  static void toProfile(BuildContext context, String username) =>
      context.vRouter.push('/$username/$profile');

  static final String settings = 'settings';

  static void toSettings(BuildContext context, String username) =>
      context.vRouter.push('/$username/$settings');

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VNester(
        path:
            '/:username', // :username is a path parameter and can be any value
        widgetBuilder: (child) => MyScaffold(child),
        nestedRoutes: [
          VWidget(
            path: profile,
            widget: ProfileWidget(),
          ),
          VWidget(
            path: settings,
            widget: SettingsWidget(),

            // Custom transition
            buildTransition: (animation, ___, child) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
          ),
        ],
      ),
    ];
  }
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
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => InkWell(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => Text('OTHER (2nd)\nshowModalBottomSheet'),
            ),
            child: Text('showModalBottomSheet'),
          ),
        ),
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
                      ),
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
                onPressed: () {
                  setState(() => (_formKey.currentState!.validate())
                      ? ConnectedRoutes.toProfile(context, name)
                      : null);
                },
                child: Icon(Icons.login),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget child;

  const MyScaffold(this.child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You are connected'),
        leading: BackButton(onPressed: () => VRouter.of(context).pop()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // We can access the url with VRouter.of(context).url
        currentIndex:
            (VRouter.of(context).url!.contains(ConnectedRoutes.profile))
                ? 0
                : 1,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'Info'),
        ],
        onTap: (int index) {
          // We can access this username via the local path parameters (stored in VRouteElement)
          final username = VRouter.of(context).pathParameters['username']!;
          if (index == 0) {
            ConnectedRoutes.toProfile(context, username);
          } else {
            ConnectedRoutes.toSettings(context, username);
          }
        },
      ),
      body: child,

      // This FAB is shared with login and shows hero animations working with no issues
      floatingActionButton: FloatingActionButton(
        heroTag: 'FAB',
        onPressed: () => VRouter.of(context).push('/login'),
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
    // VNavigationGuard allows you to react to navigation events locally
    return VWidgetGuard(
      // When entering or updating the route, we try to get the count from the local history state
      // This history state will be NOT null if the user presses the back button for example
      afterEnter: (context, __, ___) => getCountFromState(context),
      afterUpdate: (context, __, ___) => getCountFromState(context),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => InkWell(
              onTap: () => Navigator.pop(context, 'TEST'),
              child: Text('showModalBottomSheet')),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    VRouter.of(context)
                        .replaceHistoryState({'count': '${count + 1}'});
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
      ),
    );
  }

  void getCountFromState(BuildContext context) {
    setState(() {
      count = (VRouter.of(context).historyState['count'] == null)
          ? 0
          : int.tryParse(VRouter.of(context).historyState['count'] ?? '') ?? 0;
    });
  }
}

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (_) => Text('OTHER (2nd)\nshowModalBottomSheet'),
            useRootNavigator: true,
          ),
          child: Text('showModalBottomSheet'),
        ),
        useRootNavigator: true,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Did you see the custom animation when coming here?',
                style: textStyle.copyWith(fontSize: textStyle.fontSize! + 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final textStyle = TextStyle(color: Colors.black, fontSize: 16);
final buttonTextStyle = textStyle.copyWith(color: Colors.white);
