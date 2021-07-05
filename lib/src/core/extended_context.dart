import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/vrouter_data.dart';
import 'package:vrouter/src/widgets/vrouter.dart';

extension VRouterContext on BuildContext {
  InitializedVRouterSailor get vRouter => VRouter.of(this);
}
