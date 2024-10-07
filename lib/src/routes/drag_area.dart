import 'package:draggable_route/draggable_route.dart';
import 'package:draggable_route/src/gestures/monodrag.dart';
import 'package:flutter/widgets.dart';

class DragArea extends StatefulWidget {
  final Widget child;

  final DraggableRouteSettings? settings;

  const DragArea({
    super.key,
    required this.child,
    this.settings,
  });

  @override
  State<DragArea> createState() => _DragAreaState();
}

enum _Edge {
  start,
  middle,
  end;
}

class _DragAreaState extends State<DragArea> {
  _Edge horizontalEdge = _Edge.start;
  _Edge verticalEdge = _Edge.start;

  late DraggableRoute route;

  @override
  void didChangeDependencies() {
    route = ModalRoute.of(context) as DraggableRoute;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings ?? //
        DraggableRouteTheme.of(context).settings;

    return RawGestureDetector(
      gestures: {
        _PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_PanGestureRecognizer>(
          () => _PanGestureRecognizer(
            () => horizontalEdge,
            () => verticalEdge,
            settings.edgeSlop,
            settings.slop,
          ),
          (instance) => instance //
            ..onStart = onPanStart
            ..onCancel = onPanCancel
            ..onUpdate = onPanUpdate
            ..onEnd = onPanEnd,
        ),
      },
      child: ScrollConfiguration(
        behavior: const _DraggableScrollBehavior(),
        child: NotificationListener<Notification>(
          onNotification: (notification) {
            switch (notification) {
              case ScrollMetricsNotification(:final metrics):
              case ScrollUpdateNotification(:final metrics):
                _Edge edge;
                if (metrics.pixels == metrics.minScrollExtent) {
                  edge = _Edge.start;
                } else if (metrics.pixels == metrics.maxScrollExtent) {
                  edge = _Edge.end;
                } else {
                  edge = _Edge.middle;
                }

                switch (metrics.axis) {
                  case Axis.vertical:
                    verticalEdge = edge;

                  case Axis.horizontal:
                    horizontalEdge = edge;
                }
            }

            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    route.handleDragStart(details);
  }

  void onPanCancel() {
    route.handleDragCancel();
  }

  void onPanUpdate(DragUpdateDetails details) {
    route.handleDragUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    route.handleDragEnd(details);
  }

  @override
  void dispose() {
    onPanCancel();
    super.dispose();
  }
}

class _DraggableScrollBehavior extends ScrollBehavior {
  const _DraggableScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const _DraggableScrollPhysics();
  }
}

class _DraggableScrollPhysics extends ClampingScrollPhysics {
  const _DraggableScrollPhysics();
}

class _PanGestureRecognizer extends PanGestureRecognizer {
  final ValueGetter<_Edge> horizontalEdge;
  final ValueGetter<_Edge> verticalEdge;

  final double edgeSlop;
  final double defaultSlop;

  _PanGestureRecognizer(
    this.horizontalEdge,
    this.verticalEdge,
    this.edgeSlop,
    this.defaultSlop,
  );

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    if (horizontalEdge() == _Edge.middle && verticalEdge() == _Edge.middle) {
      return super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      );
    }

    var delta = (finalPosition.global - initialPosition.global);

    var ySlop = switch (verticalEdge()) {
      _Edge.start when delta.dy > 0 => edgeSlop,
      _Edge.end when delta.dy < 0 => edgeSlop,
      _ => defaultSlop,
    };

    var xSlop = switch (horizontalEdge()) {
      _Edge.start when delta.dx > 0 => edgeSlop,
      _Edge.end when delta.dx < 0 => edgeSlop,
      _ => defaultSlop,
    };

    final slop = delta.dx.abs() > delta.dy.abs() ? xSlop : ySlop;

    return globalDistanceMoved.abs() > slop;
  }
}
