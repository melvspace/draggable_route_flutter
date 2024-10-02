import 'dart:ui';

import 'package:draggable_route/src/theme/default_draggable_theme.dart';
import 'package:flutter/material.dart';

typedef ImageFilterTransitionBuilder = ImageFilter Function(
  Animation<double> animation,
);

/// {@template draggable_route.DraggableRouteTheme}
/// Theme to control styling of [DraggableRoute]
/// {@endtemplate}
class DraggableRouteTheme extends ThemeExtension<DraggableRouteTheme> {
  final Duration transitionDuration;

// #region Curves

  /// Curve for entering animation
  final Curve transitionCurve;

  /// Curve for exiting animation
  final Curve? transitionCurveOut;

// #endregion

// #region Filters

  /// Background filter animation builder
  final ImageFilterTransitionBuilder? backdropFilterBuilder;

  /// Dissolve filter animation builder.
  ///
  /// Used when source was not provided or no longer alive
  final ImageFilterTransitionBuilder? dissolveFilterBuilder;

// #endregion

  // shape

// #region Shape

  /// Border radius of card when dragging around
  final BorderRadius borderRadius;

// #endregion

  /// {@macro draggable_route.DraggableRouteTheme}
  const DraggableRouteTheme({
    required this.transitionDuration,
    required this.transitionCurve,
    this.borderRadius = BorderRadius.zero,
    this.transitionCurveOut,
    this.backdropFilterBuilder,
    this.dissolveFilterBuilder,
  });

  /// {@macro draggable_route.DraggableRouteTheme}
  ///
  /// Get instance from ancestor [Theme]
  static DraggableRouteTheme of(BuildContext context) {
    return Theme.of(context).extension<DraggableRouteTheme>() ?? kDefaultTheme;
  }

  @override
  ThemeExtension<DraggableRouteTheme> copyWith() {
    return this;
  }

  @override
  ThemeExtension<DraggableRouteTheme> lerp(
    covariant ThemeExtension<DraggableRouteTheme>? other,
    double t,
  ) {
    return other ?? this;
  }
}
