export 'platform_none.dart'
    if (dart.library.io) 'platform_io.dart'
    if (dart.library.js) 'platform_web.dart';
