import 'package:flutter/widgets.dart';

import 'vrouter_data_impl.dart';
import 'vrouter_data.dart';
import '../extended_context.dart';

/// Provides a builder with access to [VRouterData]
class VRouterDataBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, VRouterData state) builder;

  const VRouterDataBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      VRouterDataImpl(
        previousUrl: context.vRouter.previousUrl,
        url: context.vRouter.url,
        pathParameters: context.vRouter.pathParameters,
        queryParameters: context.vRouter.queryParameters,
        historyState: context.vRouter.historyState,
        names: context.vRouter.names,
      ),
    );
  }
}
