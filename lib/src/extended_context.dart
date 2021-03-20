part of 'main.dart';

extension VRouterContext on BuildContext {

  LocalVRouterData get vRouter => VRouter.of(this);

}