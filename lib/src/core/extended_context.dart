import 'package:flutter/widgets.dart';
import 'package:vrouter/src/widgets/router_app/vrouter.dart';

import 'vrouter_sailor/vrouter_sailor.dart';

extension VRouterContext on BuildContext {
  InitializedVRouterSailor get vRouter => VRouter.of(this);
}
