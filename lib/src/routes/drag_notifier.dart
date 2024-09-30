import 'package:flutter/material.dart';

class DragNotifier extends ValueNotifier<Offset> {
  DragNotifier() : super(Offset.zero);

  void handleDragStart(DragStartDetails details) {
    value = Offset.zero;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    value += details.delta;
  }

  void handleDragCancel() {}

  void handleDragEnd(DragEndDetails details) {
    value = Offset.zero;
  }
}
