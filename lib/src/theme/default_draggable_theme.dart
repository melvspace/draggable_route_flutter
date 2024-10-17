import 'dart:ui';

import 'package:draggable_route/src/theme/draggable_route_theme.dart';
import 'package:flutter/widgets.dart';

final kDefaultTheme = DraggableRouteTheme(
  settings: kDefaultSettings,
  transitionDuration: const Duration(milliseconds: 300),
  transitionCurve: Curves.linear,
  transitionCurveOut: Curves.easeInOutCubic,
  borderRadius: const BorderRadius.all(Radius.circular(24)),
  backdropFilterBuilder: (animation) => ImageFilter.blur(
    sigmaX: 5 * animation.value,
    sigmaY: 5 * animation.value,
  ),
  dissolveFilterBuilder: (animation) => ImageFilter.blur(
    sigmaX: 10 * animation.value,
    sigmaY: 10 * animation.value,
    tileMode: TileMode.decal,
  ),
);

// TODO(@melvspace): 10/02/24 research why this magic numbers works
const kDefaultSettings = DraggableRouteSettings(edgeSlop: 4, slop: 300);
