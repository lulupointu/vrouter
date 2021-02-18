<p align="center" xmlns="http://www.w3.org/1999/html">
<img src="https://raw.githubusercontent.com/lulupointu/vrouter_website/master/assets/logo_whole.svg" alt="VRouter logo" height="100"/>
</p>

---

A Flutter package that makes navigation and routing easy.

**Learn more at [vrouter.dev](https://vrouter.dev)**

Here are a few things that this package will make easy:
* Automated web url handling
* Nesting routes
* Transition
* Advanced url naming
* Reacting to route changing
* Customizable pop events
* And much more...

## Overview

The goal of this package is to implement a routing system which is
similar to the one in Vue.js (named vue router).

The idea is to use the `VRouter` widget on top of you app, and use
`VRouteElement` to create you routes.

```
VRouter(
  routes: [
    // This matches the path '/login'
    VStacked(
      path: '/login',
      widget: LoginWidget(),
    ),

    VStacked(
      // This matches the path '/in'
      path: '/in',
      widget: MyScaffold(),

      subroutes: [
        // VChild are accessible via VRouteElementData.vChild
        VChild(
          // This matches the path '/in/profile/:id'
          // :id can be any word and will by accessible as a path parameter
          path: 'profile/:id',
          widget: ProfileWidget(),
        ),
        VChild(
          // This matches the path '/settings'
          path: '/settings',
          widget: ProfileWidget(),
        ),
      ],
    ),

    VRouteRedirector(
      // This matches any path
      path: ':_(.*)',
      // We redirect to /login
      redirectTo: '/login',
    )
  ],
)
```
## VRouteElements

### VStacked

VStacked are a VRouteElement which are stacked on top on the previous one

### VChild

VChild are useful when nesting widgets. You can access them using `VRouteElementData.vChild`

For example, for the example above:

```
class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VRouteElementData.of(context).vChild,
    );
  }
}
```

### VRouteRedirector

This is useful when you want a `VRouteElement` which only redirects

## Useful notions

If you want detailed explanations of the notions bellow, please have a look
at the **[vrouter.dev](https://vrouter.dev)** website.

### Programmatic Navigation

Use VRouterData to access VRouter methods which allow you to navigate:

```
// Pushing a new url
VRouterData.of(context).push('/home');

// Pushing a named route
VRouterData.of(context).pushNamed('home');

// Pushing an external route
VRouterData.of(context).pushExternal('google.com');
```

### Named route

Naming a route is simple and allows for simpler navigation,
just use the `name` attribute of any `VRouteElement`.

### Path parameters

You will often need to match with a certain path pattern
to the same route. To easily achieve this, you can use
path parameters. To use them you just need to insert
:parameterName in the url.

VRouter configuration
```
VRouter(
  routes: [
    VStacked(
      path: '/user/:id',
      widget: UserWidget(),
    ),
  ],
)
```

Access the path parameters in you widgets:
```
class UserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use VRouteElement to access general information about the route
    print('The current id is: ${VRouteData.of(context).pathParameters['id']}');

    // Use VRouteElementData to data which belong to this VRouteElement
    return Text('User id is ${VRouteElementData.of(context).pathParameters['id']}');
  }
}
```

### Transitions

You can either specify a default transition in VRouter, or a transition
specific to a given route by specifying the transition in the last
`VRouteElement` in the route

```
VRouter(
  // This transition will be applied to every route
  buildTransition: (animation1, _, child) =>
      FadeTransition(opacity: animation1, child: child),
  routes: [
    // No transition is specified, so the default one will play for '/user'
    VStacked(
      path: '/user',
      widget: ProfileWidget(),
      subroutes: [
        // The custom transition will be played when accessing '/user/likes'
        VChild(
          path: 'likes',
          widget: LikesWidget(),
          buildTransition: (animation1, _, child) =>
              ScaleTransition(scale: animation1, child: child),
        )
      ],
    ),
    // No transition is specified, so the default one will play
    VStacked(path: '/settings', widget: SettingsWidget()),
  ],
);
```

### Pop events

Pop event are handled by default: The last VStack of the route is remove.

<p align="center" xmlns="http://www.w3.org/1999/html">
<img src="https://raw.githubusercontent.com/lulupointu/vrouter_website/master/assets/default_pop.png" alt="VRouter logo" height="200"/>
</p>

But you can also handle a pop event by yourself

```
VRouter(
  // Every pop event will call this
  onPop: (context) async {
    return true;
  },
  routes: [
    VStacked(
      path: 'profile',
      // popping the path path /login will call this
      onPop: (context) async {
        return false; // returning false stops the pop event
      },
      widget: ProfileWidget(),
    ),
  ],
)
```

### Navigation control

VRouter allows you to have a fine grain control over
navigation events.

Use the `beforeLeave`, `beforeEnter`, `afterEnter` or `afterUpdate` to
catch navigation events, referring to the following navigation
cycle to know in which order they happen:
1. Call beforeLeave in all deactivated [VNavigationGuard]
2. Call beforeLeave in the nest-most [VRouteElement] of the current route
3. Call beforeLeave in the [VRouter]
4. Call beforeEnter in the [VRouter]
5. Call beforeEnter in the nest-most [VRouteElement] of the new route

\#\# The history state got in beforeLeave are stored  
\#\# The state of the VRouter changes

6. Call afterEnter in the [VRouter]
7. Call afterEnter in the nest-most [VRouteElement] of the new route
8. Call afterUpdate in all reused [VNavigationGuard]
9. Call afterEnter in all initialized [VNavigationGuard]

In every before.. function, you can return false to stop the navigation.

## Much more

<<<<<<< HEAD
There is so much more that this package can do, check out the example
=======
Their is so much more that this package can do, check out the example
>>>>>>> f33432a55f633757c8dcd9cae5f1ace258a527eb
or have a look at the **[vrouter.dev](https://vrouter.dev)** website