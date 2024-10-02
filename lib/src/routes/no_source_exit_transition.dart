import 'dart:ui';

import 'package:draggable_route/draggable_route.dart';
import 'package:flutter/material.dart';

class NoSourceExitTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const NoSourceExitTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final dissolveFilterBuilder =
              DraggableRouteTheme.of(context).dissolveFilterBuilder;
          if (dissolveFilterBuilder != null) {
            return ImageFiltered(
              enabled: animation.isAnimating,
              imageFilter: dissolveFilterBuilder(ReverseAnimation(animation)),
              child: child,
            );
          }

          return child!;
        },
        child: child,
      ),
    );
  }
}

class BlurTransition extends StatelessWidget {
  final Animation<double> sigma;
  final Widget child;

  const BlurTransition({
    super.key,
    required this.sigma,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sigma,
      builder: (context, child) => ImageFiltered(
        enabled: !sigma.isDismissed,
        imageFilter: ImageFilter.blur(
          sigmaX: sigma.value,
          sigmaY: sigma.value,
          tileMode: TileMode.decal,
        ),
        child: child!,
      ),
      child: child,
    );
  }
}
