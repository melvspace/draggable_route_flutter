import 'package:draggable_route/draggable_route.dart';
import 'package:draggable_route/src/gestures/monodrag.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';

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
  Set<BuildContext> horizontal = {};
  Set<BuildContext> vertical = {};

  _Edge? horizontalEdge;
  _Edge? verticalEdge;

  late DraggableRoute route;

  @override
  void didChangeDependencies() {
    route = ModalRoute.of(context) as DraggableRoute;
    super.didChangeDependencies();
  }

  void updateEdge(BuildContext context, Offset position) {
    final state = (context as StatefulElement).state as ScrollableState;
    final ro = context.findRenderObject() as RenderBox?;

    if (state.position.maxScrollExtent == 0) {
      return;
    }

    if (state.resolvedPhysics is NeverScrollableScrollPhysics) {
      return;
    }

    if (ro != null) {
      final result = BoxHitTestResult();
      final localPosition = Vector3(position.dx, position.dy, 0) -
          ro.getTransformTo(null).getTranslation();

      final hitted = ro.hitTest(
        result,
        position: Offset(localPosition.x, localPosition.y),
      );

      if (hitted) {
        _Edge edge;
        final metrics = state.position;

        var offset = (state.position.pixels - state.position.minScrollExtent) /
            (state.position.maxScrollExtent - state.position.minScrollExtent);

        DraggableRouteScrollResolverState? findCustomResolver(
          BuildContext context,
        ) {
          final resolver = context.read<DraggableRouteScrollResolverState?>();
          if (resolver == null) return null;
          if (resolver.axis != state.position.axis) {
            return findCustomResolver(resolver.context);
          }

          return resolver;
        }

        offset = findCustomResolver(state.context)?.offset() ?? offset;

        if (offset == 0) {
          edge = _Edge.start;
        } else if (offset == 1) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings ?? //
        DraggableRouteTheme.of(context).settings;

    return Listener(
      onPointerDown: (event) {
        for (final context in {...horizontal}) {
          if (!context.mounted) horizontal.remove(context);
        }

        for (final context in {...vertical}) {
          if (!context.mounted) vertical.remove(context);
        }

        int sort(BuildContext a, BuildContext b) {
          final value = (a as Element).depth.compareTo((b as Element).depth);
          return value;
        }

        final horizontalList = horizontal.toList()..sort((a, b) => sort(a, b));
        final verticalList = vertical.toList()..sort((a, b) => sort(a, b));

        horizontalEdge = null;
        for (final context in horizontalList) {
          updateEdge(context, event.position);
        }

        verticalEdge = null;
        for (final context in verticalList) {
          updateEdge(context, event.position);
        }
      },
      child: RawGestureDetector(
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
              if (notification is ScrollMetricsNotification) {
                final axis = notification.metrics.axis;
                ScrollableState? findTopMostScrollable(BuildContext context) {
                  final state =
                      context.findAncestorStateOfType<ScrollableState>();

                  if (state == null) return null;
                  if (state.position.axis != axis) {
                    return findTopMostScrollable(state.context);
                  }

                  return state;
                }

                var scrollable = findTopMostScrollable(notification.context) //
                    ?.context;

                if (scrollable != null) {
                  switch (notification.metrics.axis) {
                    case Axis.horizontal:
                      horizontal.add(scrollable);
                    case Axis.vertical:
                      vertical.add(scrollable);
                  }
                }
              }

              return false;
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    route.handleDragStart(context, details);
  }

  void onPanCancel() {
    route.handleDragCancel(context);
  }

  void onPanUpdate(DragUpdateDetails details) {
    route.handleDragUpdate(context, details);
  }

  void onPanEnd(DragEndDetails details) {
    route.handleDragEnd(context, details);
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
  final ValueGetter<_Edge?> horizontalEdge;
  final ValueGetter<_Edge?> verticalEdge;

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
      null => edgeSlop,
      _ => defaultSlop,
    };

    var xSlop = switch (horizontalEdge()) {
      _Edge.start when delta.dx > 0 => edgeSlop,
      _Edge.end when delta.dx < 0 => edgeSlop,
      null => edgeSlop,
      _ => defaultSlop,
    };

    final slop = delta.dx.abs() > delta.dy.abs() ? xSlop : ySlop;

    return globalDistanceMoved.abs() > slop;
  }
}
