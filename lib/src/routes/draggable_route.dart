import 'dart:math';

import 'package:draggable_route/src/routes/drag_area.dart';
import 'package:draggable_route/src/routes/no_source_exit_transition.dart';
import 'package:draggable_route/src/theme/draggable_route_theme.dart';
import 'package:flutter/material.dart';

/// Route with instagram-like transition from other widgets.
class DraggableRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  static DraggableRoute of(BuildContext context) {
    return ModalRoute.of(context) as DraggableRoute;
  }

  /// Source element from which transition will be performing.
  ///
  /// `context` provided to `source` should not have GlobalKeys in children.
  ///
  /// Source widget from `context` will be recreated for shuttle animation.
  final BuildContext? source;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

// #region Style Properties

  /// Border radius of card when dragging around
  final BorderRadius? borderRadius;

// #endregion

  /// Settings to control route behavior
  final DraggableRouteSettings? routeSettings;

  /// Construct a DraggableRoute whose contents are defined by [builder].
  DraggableRoute({
    this.source,
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = false,
    super.barrierDismissible = false,
    this.borderRadius,
    this.routeSettings,
  }) {
    assert(opaque);
  }

  @override
  Duration get transitionDuration {
    return DraggableRouteTheme.of(navigator!.context).transitionDuration;
  }

  final _entered = ValueNotifier(false);

  final _offset = ValueNotifier(Offset.zero);
  var _velocity = Offset.zero;

  void handleDragStart(DragStartDetails details) {
    navigator!.didStartUserGesture();
    _offset.value = Offset.zero;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    _offset.value += details.delta;
    _velocity = details.delta;
    _fling();
  }

  void handleDragCancel() {
    if (!isActive) return;

    if (navigator!.userGestureInProgress) {
      navigator!.didStopUserGesture();
    }

    _offset.value = Offset.zero;
    _velocity = Offset.zero;
    controller?.value = 1.0;
  }

  void handleDragEnd(DragEndDetails details) {
    navigator!.didStopUserGesture();
    _fling();
  }

  void _fling() {
    if (!isActive) return;

    if (!navigator!.userGestureInProgress) {
      if (_offset.value.distanceSquared > 100 ||
          _velocity.distanceSquared > 100) {
        navigator!.pop();
      } else {
        _offset.value = Offset.zero;
        _velocity = Offset.zero;
        controller?.value = 1.0;
      }
    } else {
      if (_offset.value != Offset.zero) {
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
        _entered.value = true;
        controller!.removeStatusListener(handleEntered);
      }
    }

    controller!.addStatusListener(handleEntered);
  }

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget content = buildContent(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: content,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final source = this.source;
    final theme = DraggableRouteTheme.of(context);
    animation = CurvedAnimation(
      parent: animation,
      curve: theme.transitionCurve,
      reverseCurve: theme.transitionCurveOut,
    );

    final backdropFilterBuilder = theme.backdropFilterBuilder;

    if (source == null || !source.mounted) {
      return _wrap(
        (context, child) {
          if (backdropFilterBuilder != null) {
            return BackdropFilter(
              filter: backdropFilterBuilder(animation),
              child: child,
            );
          }

          return child;
        },
        ListenableBuilder(
          listenable: _entered,
          builder: (context, child) {
            if (!_entered.value) {
              return super.buildTransitions(
                context,
                animation,
                secondaryAnimation,
                child!,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) => Transform.translate(
                offset: _offset.value,
                child: NoSourceExitTransition(
                  animation: animation,
                  child: ClipPath(
                    clipper: _RectWithNotchesClipper(
                      borderRadius: borderRadius ??
                          DraggableRouteTheme.of(context).borderRadius,
                    ),
                    child: _buildDragArea(
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
      return _wrap(
        (context, child) {
          if (backdropFilterBuilder != null) {
            return BackdropFilter(
              filter: backdropFilterBuilder(animation),
              child: child,
            );
          }

          return child;
        },
        LayoutBuilder(
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
              end: _offset.value & constraints.biggest,
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
                      borderRadius: borderRadius ??
                          DraggableRouteTheme.of(context).borderRadius,
                    ),
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                      child: ConstrainedBox(
                        constraints: constraints,
                        child: _buildDragArea(
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

  List<Widget> _buildNotches(BuildContext context) {
    final borderRadius = this.borderRadius ?? //
        DraggableRouteTheme.of(context).borderRadius;

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

  Widget _buildDragArea(
    BuildContext context,
    Animation animation,
    Animation secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ..._buildNotches(context),
        DragArea(child: child, settings: routeSettings),
      ],
    );
  }
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

Widget _wrap(
    Widget Function(BuildContext context, Widget child) builder, Widget child) {
  return Builder(
    builder: (context) => builder(context, child),
  );
}
