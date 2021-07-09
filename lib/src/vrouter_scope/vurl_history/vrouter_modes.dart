/// Two router mode are possible:
///    - "hash": This is the default, the url will be serverAddress/#/localUrl
///    - "history": This will display the url in the way we are used to, without
///       the #. However note that you will need to configure your server to make this work.
///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
enum VRouterMode { hash, history }

/// Two router mode are possible:
///    - "hash": This is the default, the url will be serverAddress/#/localUrl
///    - "history": This will display the url in the way we are used to, without
///       the #. However note that you will need to configure your server to make this work.
///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
@Deprecated('Use VRouterMode (without the "s") instead')
typedef VRouterModes = VRouterMode;
