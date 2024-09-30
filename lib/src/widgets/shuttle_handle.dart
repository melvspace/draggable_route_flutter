import 'package:flutter/widgets.dart';

// TODO(@melvspace): 09/30/24 probably unneded. user should keep alive reference by himself
class ShuttleHandle extends StatefulWidget {
  final ValueChanged<BuildContext> onCreated;
  final Widget child;

  const ShuttleHandle({
    super.key,
    required this.onCreated,
    required this.child,
  });

  @override
  State<ShuttleHandle> createState() => _ShuttleHandleState();
}

class _ShuttleHandleState extends State<ShuttleHandle> {
  @override
  Widget build(BuildContext context) {
    widget.onCreated(context);
    return widget.child;
  }
}
