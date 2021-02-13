import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import 'UI/authentication_widget.dart';
import 'UI/in_app_widgets.dart';


void main() {
  // window.onPopState.listen((event) async {
  //
  //   // print('ONPOPSTATE ${event.state}, ${event.type}, ${event.cancelable}');
  //   // print('I: $i');
  //   // i.add(i.last+1);
  //   // print('I: $i');
  // });
  runApp(
    VRouter(
      onPop: (_) async {
        print('ON VRouter POP');
        return true;
      },
      onSystemPop: (_) async {
        print('ON VRouter SystemPOP');
        return true;
      },
      mode: VRouterModes.hash,
      buildTransition: (animation, ___, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      beforeLeave: (_, __, ___, ____) async {
        print('Router beforeLeave');
        return true;
      },
      beforeEnter: (_, __, ___) async {
        print('Router beforeEnter');
        return true;
      },
      afterEnter: (_, __, ___) {
        print('Router afterEnter');
        return;
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
          widget: MyAuthenticationWidget(),
          subroutes: [
            VStacked(
              key: ValueKey('MyScaffold'),
              widget: MyScaffold(),
              onPop: (_) async {
                print('ON MyScaffold POP');
                return true;
              },
              subroutes: [
                VChild(
                  path: '/settings',
                  name: 'settings',
                  widget: SettingWidget(),
                  subroutes: [
                    VStacked(
                        path: ':id',
                        widget: OtherWidget(),
                        aliases: ['/ok/:id']
                    ),
                  ],
                ),
                VChild(
                  onSystemPop: (_) async {
                    print('onSystemPop profile');
                    return true;
                  },
                  onPop: (_) async {
                    print('onPop profile');
                    return true;
                  },
                  path: '/profile',
                  widget: ProfileWidget(),
                  buildTransition: (animation, ___, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              ],
            )
          ],
        ),
        VStacked(
          path: '/other',
          widget: OtherWidget(),
          beforeLeave: (_, __, ___, ____) async {
            print('Other beforeLeave');
            return true;
          },
        ),
        VRouteRedirector(
          redirectTo: '/login',
          path: r':_(.*)',
        ),
      ],
    ),
  );
}
