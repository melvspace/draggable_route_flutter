import 'dart:math';
import 'dart:ui';

import 'package:draggable_route/src/routes/drag_area.dart';
import 'package:draggable_route/src/routes/no_source_exit_transition.dart';
import 'package:flutter/material.dart';

class DraggableRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  static DraggableRoute of(BuildContext context) {
    return ModalRoute.of(context) as DraggableRoute;
  }

  final BuildContext? source;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  final BorderRadius borderRadius;

  /// Construct a DraggableRoute whose contents are defined by [builder].
  DraggableRoute({
    this.source,
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = false,
    super.barrierDismissible = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  }) {
    assert(opaque);
  }

  var entered = ValueNotifier(false);

  var offset = ValueNotifier(Offset.zero);
  var velocity = Offset.zero;
  void handleDragStart(DragStartDetails details) {
    navigator!.didStartUserGesture();
    offset.value = Offset.zero;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    offset.value += details.delta;
    velocity = details.delta;
    fling();
  }

  void handleDragCancel() {
    if (!isActive) return;

    if (navigator!.userGestureInProgress) {
      navigator!.didStopUserGesture();
    }

    offset.value = Offset.zero;
    velocity = Offset.zero;
    controller?.value = 1.0;
  }

  void handleDragEnd(DragEndDetails details) {
    navigator!.didStopUserGesture();
    fling();
  }

  void fling() {
    if (!isActive) return;

    if (!navigator!.userGestureInProgress) {
      if (offset.value.distanceSquared > 100 ||
          velocity.distanceSquared > 100) {
        navigator!.pop();
      } else {
        offset.value = Offset.zero;
        velocity = Offset.zero;
        controller?.value = 1.0;
      }
    } else {
      if (offset.value != Offset.zero) {
        controller?.value = 0.999;
      } else {
        controller?.value = 1.0;
      }
    }
  }

  @override
  void install() {
    super.install();

    void handleEntered(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        entered.value = true;
        controller!.removeStatusListener(handleEntered);
      }
    }

    controller!.addStatusListener(handleEntered);
  }

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    animation = CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
      reverseCurve: Curves.easeInQuad,
    );

    final source = this.source;
    if (source == null || !source.mounted) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5 * animation.value,
          sigmaY: 5 * animation.value,
        ),
        child: ListenableBuilder(
          listenable: entered,
          builder: (context, child) {
            if (!entered.value) {
              return super.buildTransitions(
                context,
                animation,
                secondaryAnimation,
                child!,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) => Transform.translate(
                offset: offset.value,
                child: NoSourceExitTransition(
                  animation: animation,
                  child: ClipPath(
                    clipper: _RectWithNotchesClipper(
                      borderRadius: borderRadius,
                    ),
                    child: buildDragArea(
                      context,
                      animation,
                      secondaryAnimation,
                      child!,
                    ),
                  ),
                ),
              ),
            );
          },
          child: child,
        ),
      );
    } else {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5 * animation.value,
          sigmaY: 5 * animation.value,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final startRO = source.findRenderObject() as RenderBox;
            final startTransform = startRO.getTransformTo(null);
            final rectTween = RectTween(
              begin: Rect.fromLTWH(
                startTransform.getTranslation().x,
                startTransform.getTranslation().y,
                startRO.size.width,
                startRO.size.height,
              ),
              end: offset.value & constraints.biggest,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Positioned.fromRect(
                    rect: rectTween.evaluate(animation)!,
                    child: child!,
                  ),
                  child: ClipPath(
                    clipper: _RectWithNotchesClipper(
                      influence: animation.value,
                      borderRadius: borderRadius,
                    ),
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                      child: ConstrainedBox(
                        constraints: constraints,
                        child: buildDragArea(
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Positioned.fromRect(
                    rect: rectTween.evaluate(animation)!,
                    child: child!,
                  ),
                  child: IgnorePointer(
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      child: FadeTransition(
                        opacity:
                            Tween<double>(begin: 1, end: 0).animate(animation),
                        child: SizedBox.fromSize(
                          size: startRO.size,
                          child: source.widget,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  List<Widget> buildNotches() {
    return [
      Positioned(
        left: 0,
        right: 0,
        top: -max(borderRadius.topLeft.y, borderRadius.topRight.y),
        height: max(borderRadius.topLeft.y, borderRadius.topRight.y),
        child: IgnorePointer(
          child: Builder(
            builder: (context) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: borderRadius.topLeft,
                    topRight: borderRadius.topRight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: -max(borderRadius.bottomLeft.y, borderRadius.bottomRight.y),
        height: max(borderRadius.bottomLeft.y, borderRadius.bottomRight.y),
        child: IgnorePointer(
          child: Builder(
            builder: (context) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: borderRadius.bottomLeft,
                    bottomRight: borderRadius.bottomRight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget buildDragArea(
    BuildContext context,
    Animation animation,
    Animation secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...buildNotches(),
        DragArea(child: child),
      ],
    );
  }

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

class _RectWithNotchesClipper extends CustomClipper<Path> {
  final BorderRadius borderRadius;
  final double influence;

  _RectWithNotchesClipper({
    required this.borderRadius,
    this.influence = 1.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final topNotch = max(borderRadius.topLeft.y, borderRadius.topRight.y) * //
        influence;
    final bottomNotch =
        max(borderRadius.bottomLeft.y, borderRadius.bottomRight.y) * //
            influence;

    path.addRRect(
      RRect.fromRectAndCorners(
        Offset(0, -topNotch) & (size + Offset(0, topNotch + bottomNotch)),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant _RectWithNotchesClipper oldClipper) {
    return borderRadius != oldClipper.borderRadius ||
        influence != oldClipper.influence;
  }
}
