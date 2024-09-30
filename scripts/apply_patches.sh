#!/bin/bash

fvm install

# monodrag.dart
patch -i patches/monodrag.patch .fvm/flutter_sdk/packages/flutter/lib/src/gestures/monodrag.dart -o lib/src/gestures/monodrag.dart
