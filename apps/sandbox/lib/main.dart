import 'package:flutter/material.dart';
import 'package:sandbox/components.g.dart';
import 'package:sandboxed/addons/viewport/viewport_addon.dart';
import 'package:sandboxed/sandboxed.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sandboxed(
      components: components,
      addons: [
        ViewportAddon(devices: Devices.ios.all),
      ],
    );
  }
}
