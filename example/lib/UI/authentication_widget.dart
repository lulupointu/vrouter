import 'package:complete_app/logic/routing.dart';
import 'package:complete_app/vrouter/main.dart';
import 'package:flutter/material.dart';

class MyAuthenticationWidget extends StatelessWidget {

  MyAuthenticationWidget() : super();

  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      beforeLeave: (_, __, ___, ____) async {
        print('VNavigationGuard beforeLeave');
        return true;
      },
      afterUpdate: (_, __, ___) async {
        print('VNavigationGuard afterUpdate');
        return;
      },
      afterEnter: (_, __, ___) {
        print('VNavigationGuard afterEnter');
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('You are NOT connected'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.greenAccent,
                  child: Text('Click me to connect.'),
                ),
                onPressed: () {
                  VRouterData.of(context).push('/ok/123');
                },
              ),
              Hero(
                tag: 'button',
                child: FlatButton(
                  color: Colors.redAccent,
                  child: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    return Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
