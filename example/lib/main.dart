import 'package:draggable_route/draggable_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        for (final platform in TargetPlatform.values)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => setState(
                              () =>
                                  debugDefaultTargetPlatformOverride = platform,
                            ),
                            child: Text(platform.name),
                          )
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          DraggableRoute(
                            source: context,
                            builder: (context) => const PageB(),
                          ),
                        ),
                        child: const SizedBox(
                          width: 300,
                          height: 200,
                          child: Card.filled(
                            child: Center(child: Text('Open with Source')),
                          ),
                        ),
                      );
                    },
                  ),
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        DraggableRoute(
                          builder: (context) => const PageB(),
                        ),
                      ),
                      child: const SizedBox(
                        width: 300,
                        height: 200,
                        child: Card.filled(
                          child: Center(child: Text('Open without Source')),
                        ),
                      ),
                    );
                  }),
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          DraggableRoute(
                            source: context,
                            builder: (context) => const ScrollablePage(),
                          ),
                        ),
                        child: const SizedBox(
                          width: 300,
                          height: 200,
                          child: Card.filled(
                            child: Center(child: Text('Open Scrollable')),
                          ),
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          DraggableRoute(
                            builder: (context) => const ScrollablePage(),
                          ),
                        ),
                        child: const SizedBox(
                          width: 300,
                          height: 200,
                          child: Card.filled(
                            child: Center(
                                child: Text('Open Scrollable without Source')),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  DraggableRoute(
                    builder: (context) => const PageB(),
                  ),
                );
              },
              child: const Text("Push more"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Return"),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollablePage extends StatelessWidget {
  const ScrollablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Return"),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 100,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    if (index % 3 == 0) {
                      return SizedBox(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          itemCount: 100,
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => ColoredBox(
                            color: Colors.yellow,
                            child: SizedBox(
                              height: 120,
                              width: 60,
                              child: Center(child: Text(index.toString())),
                            ),
                          ),
                        ),
                      );
                    }

                    return ColoredBox(
                      color: Colors.purple,
                      child: ListTile(
                        title: Text(index.toString()),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
