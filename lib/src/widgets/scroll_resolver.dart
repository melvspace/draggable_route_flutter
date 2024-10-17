import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// TODO(@melvspace): 10/17/24 add nested scroll view example to sandbox

/// Customize offset resolve logic for complex cases.
///
/// Example: In nested scroll views can be multiple scroll controllers conflicting with each other.
class DraggableRouteScrollResolver extends StatefulWidget {
  final Widget? child;
  final Axis axis;
  final ValueGetter<double?> offset;

  const DraggableRouteScrollResolver({
    super.key,
    required this.axis,
    required this.offset,
    this.child,
  });

  @override
  State<DraggableRouteScrollResolver> createState() =>
      DraggableRouteScrollResolverState();
}

class DraggableRouteScrollResolverState
    extends State<DraggableRouteScrollResolver> {
  ValueGetter<double?> get offset => widget.offset;

  Axis get axis => widget.axis;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: widget.child ?? const SizedBox(),
    );
  }
}
