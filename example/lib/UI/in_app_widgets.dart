import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      onPop: (_) async {
        print('ON PROFILE POP');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('You are connected'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              (VRouteElementData.of(context).vChildName == 'settings') ? 1 : 0,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          onTap: (int index) {
            VRouterData.of(context)
                .push((index == 0) ? '/profile' : '/settings');
          },
        ),
        body: VRouteElementData.of(context).vChild,
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
    return VNavigationGuard(
      afterEnter: (context, __, ___) => getCountFromState(context),
      afterUpdate: (context, __, ___) => getCountFromState(context),
      beforeLeave: (context, __, ___, saveHistoryState) async {
        saveHistoryState('$count');
        return true;
      },
      child: Center(
        child: Column(
          children: [
            Hero(
              tag: 'button',
              child: FlatButton(
                color: Colors.redAccent,
                child: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    count++;
                  });
                  print(
                      'VRouteData.of(context).historyState: ${VRouteData.of(context).historyState}');
                  VRouteData.of(context).replaceHistoryState('$count');
                  // print('PUSH');
                  // var state = window.history.state;
                  // state['state'] = '${jsonEncode({'2': '500'})}';
                  // window.history.replaceState(state, 'flutter', null);
                },
              ),
            ),
            Text('Your profile'),
            Text('Count: $count')
          ],
        ),
      ),
    );
  }

  void getCountFromState(BuildContext context) {
    print('Route history state: ${VRouteData.of(context).historyState}');
    setState(() {
      count = (VRouteElementData.of(context).historyState == null)
          ? 0
          : int.tryParse(VRouteElementData.of(context).historyState ?? '') ?? 0;
    });
  }
}

class SettingWidget extends StatefulWidget {
  @override
  _SettingWidgetState createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  int count = 0;
  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      afterEnter: (_, __, ___) {
        setState(() {
          _scrollController = ScrollController(initialScrollOffset: 200);
        });
      },
      onPop: (_) async {
        print('ON SETTINGS POP');
        return true;
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your settings $count'),
                Hero(
                  tag: 'button',
                  child: FlatButton(
                    color: Colors.redAccent,
                    child: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      print('OK');
                      VRouterData.of(context).push('/settings/settings');
                      // return Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  height: 300,
                  color: Colors.blue,
                ),
                Container(
                  height: 300,
                  color: Colors.redAccent,
                ),
                Container(
                  height: 300,
                  color: Colors.greenAccent,
                ),
                Container(
                  height: 300,
                  color: Colors.grey,
                ),
                Container(
                  height: 300,
                  color: Colors.yellowAccent,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
        ),
      ),
    );
  }
}

class OtherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      afterEnter: (context, _, __) {
        print(VRouteElementData.of(context).pathParameters);
      },
      child: Center(
        child: Text('OTHER WIDGET'),
      ),
    );
  }
}
