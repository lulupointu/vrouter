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
    VWidget(
      path: '/login',
      widget: LoginWidget(),
    ),
    
    VGuard(
      beforeEnter: (vRedirector) => (isConnected) ? null : vRedirector.push('/login'),
      stackedRoutes: [
        VNester(
          // This matches the path '/in'
          path: '/in',
          widgetBuilder: (child) => MyScaffold(child), // The child is from nestedRoutes
          nestedRoutes: [
            
            VWidget(
              // This matches the path '/in/profile/:id'
              // :id can be any word and will by accessible as a path parameter
              path: 'profile/:id',
              widget: ProfileWidget(),
            ),
            VWidget(
              // This matches the path '/settings'
              path: '/settings',
              widget: ProfileWidget(),
            ),
          ],
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

`VRouteElements` are the building blocs of your routes. Just like widgets,
you nest them to create your routes.

### VWidget

VWidget is used to display the given `widget` if the given `path` is matched

```
VWidget(
  path: '/login', 
  widget: LoginWidget(),
  stackedRoutes: [
    VWidget(path: '/home', widget: HomeWidget()),
  ],
)
```

Using `stackedRoutes`, you can stack widget from other `VRouteElement` on top of the given `widget`: Here the `HomeWidget` will be stacked on top of the `LoginWidget`.


### VNester

VNester can be used to created `nestedRoutes`. This will allow you to nest your `widgets`

```
VNester(
  path: '/in',
  widgetBuilder: (child) => MyScaffold(child), // The child is from nestedRoutes
  nestedRoutes: [
    VWidget(
      path: 'profile',
      widget: ProfileWidget(),
    ),
    VWidget(
      path: 'settings',
      widget: ProfileWidget(),
    ),
  ],
)
```

In the example above, if you have MyScaffold and want to use a different body for different paths, you can use a `VNester`. Here:
  - In `/in/profile` MyScaffold will have `ProfileWidget` as a `child`
  - In `/in/settings` MyScaffold will have `Settings` as a `child`

### VGuard

`VGuard` helps you control the navigation changes. You can use many methods like `beforeEnter` which will be called at different times to respond to precise navigation events.

In the example above, `vRedirector` is used to redirect if we are not connected.

### VRouteRedirector

This is useful when you want a `VRouteElement` which only redirects

## Useful notions

If you want detailed explanations of the notions bellow, please have a look
at the **[vrouter.dev](https://vrouter.dev)** website.

### Programmatic Navigation

Use VRouter to access methods which allow you to navigate:

```
// Pushing a new url
context.vRouter.push('/home');

// Pushing a named route
context.vRouter.pushNamed('home');

// Pushing an external route
context.vRouter.pushExternal('google.com');
```

### Named route

Naming a route is simple and allows for simpler navigation,
just use the `name` attribute of any `VRouteElement` having a path.

### Path parameters

You will often need to match with a certain path pattern
to the same route. To easily achieve this, you can use
path parameters. To use them you just need to insert
:parameterName in the url.

VRouter configuration
```
VRouter(
  routes: [
    VWidget(
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
    final id = context.vRouter.pathParameters['id'];
    
    ...
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
    VWidget(
      path: '/user',
      widget: ProfileWidget(),
      stackedRoutes: [
        // The custom transition will be played when accessing '/user/likes'
        VWidget(
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

Pop event are handled by default: The last `VRouteElement` of the `stackedRoutes` of the `context` is popped

But you can also handle a pop event by yourself, notably using the `VRouteElement` called `VPopHandler`:

```
VRouter(
  // Every pop event will call this
  onPop: (vRedirector) async {
    return vRedirector.push('/other'); // You can use vRedirector to redirect
  },
  routes: [
    VPopHandler(
      // popping the path path /login will call this
      onPop: (vRedirector) async {
        vRedirector.stopRedirection(); // You can use vRedirector to stop the redirection
      },
      stackedRoutes: [
        VWidget(path: 'profile', widget: ProfileWidget()),  
      ],
    ),
  ],
)
```

### Navigation control

VRouter allows you to have a fine grain control over
navigation events.

Use the `beforeLeave`, `beforeEnter`, `beforeUpdate`, `afterEnter` or `afterUpdate` to
catch navigation events, referring to the following navigation
cycle to know in which order they happen:
1. Call *beforeLeave* in all deactivated \[VNavigationGuard\]
2. Call *beforeLeave* in all deactivated \[VRouteElement\]
3. Call *beforeLeave* in the \[VRouter\]
4. Call *beforeEnter* in the \[VRouter\]
5. Call *beforeEnter* in all initialized \[VRouteElement\] of the new route
6. Call *beforeUpdate* in all reused \[VRouteElement\]

\#\# The history state got in beforeLeave are stored  
\#\# The state is updated

7. Call *afterEnter* in all initialized \[VNavigationGuard\]
8. Call *afterEnter* all initialized \[VRouteElement\]
9. Call *afterEnter* in the \[VRouter\]
10. Call *afterUpdate* in all reused \[VNavigationGuard\]
11. Call *afterUpdate* in all reused \[VRouteElement\]

In every before.. function, you can use the first argument to stop the navigation using .stopNavigation()

There are 3 main ways you can access those methods:
1. `VRouter`
```
VRouter(
  afterEnter: (context, String from, String to) => ...,
  routes: [...],
)
```
2. With a `VRouteElement`: `VGuard`
```
VRouter(
  routes: [
    VGuard(
      beforeEnter: (vRedirector) => ...,
      
      // If any of the stackedRoutes are entered, VGuard.beforeEnter is called
      stackedRoutes: [
        ...
      ],
    ),
  ],
)
```
3. With a widget: `VWidgetGuard`
```
class UserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VWidgetGuard(
      beforeLeave: (vRedirector, _) => ...,
      child: ...,
    );
  }
}
```

### Initial url

Maybe you want to redirect people to a certain part of your app when they first launch it. You can d just that with `initialUrl` from `VRouter`:

```
VRouter(
  initialUrl: '/home',
  routes: [...],
)
```

Note that this will not break deep linking. If your user are on the web and launch `/user` they won't be redirected.

## Much more

There is so much more that this package can do, check out the example
or have a look at the **[vrouter.dev](https://vrouter.dev)** website