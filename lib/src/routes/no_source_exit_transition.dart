import 'dart:ui';

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
      child: BlurTransition(
        sigma: Tween<double>(begin: 10, end: 0).animate(animation),
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
