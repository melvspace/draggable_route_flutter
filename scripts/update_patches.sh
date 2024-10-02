#!/bin/bash

fvm install

# monodrag.dart
diff -u .fvm/flutter_sdk/packages/flutter/lib/src/gestures/monodrag.dart lib/src/gestures/monodrag.dart > patches/monodrag.patch
