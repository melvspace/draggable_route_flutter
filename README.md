# Draggable Route

[![pub package](https://img.shields.io/pub/v/draggable_route)](https://pub.dev/packages/draggable_route)

This package provides easy to use draggable route. Inspired by Instagram route transitions.

## Showcase

| With Source | Without Source | Scroll View with Source | Scroll View without Source |
| ----------- | -------------- | ----------------------- | -------------------------- |
| ![gif](https://github.com/rIIh/draggable_route_flutter/raw/main/media/simple-with-source.gif) | ![gif](https://github.com/rIIh/draggable_route_flutter/raw/main/media/simple-without-source.gif) | ![gif](https://github.com/rIIh/draggable_route_flutter/raw/main/media/drag-with-scrollview-with-source.gif) | ![gif](https://github.com/rIIh/draggable_route_flutter/raw/main/media/drag-with-scrollview-without-source.gif) |

## Features

Draggable route can:

- open from source widget with expanding
- close to source widget with pretty animation
- drag to close
- vanish if source widget not available

## Getting started

Add `draggable_route` to dependencies

```sh
dart pub add draggable_route
```

## Usage

### Without widget source

Open route without widget source. Page will be pushed as Adaptive page. On pop page will vanish with animation. Drag to pop is also working in this scenario

```dart
Navigator.of(context).push(
  DraggableRoute(
    builder: (context) => const Page(),
  ),
)
```

### With widget source

Open route with widget source. Page will be expanded from widget source and retracted to widget source on pop.

> [!WARNING]
> `context` provided to `source` should not have GlobalKeys in children.
> 
> Source widget from `context` will be recreated for shuttle animation.

```dart
Navigator.of(context).push(
  DraggableRoute(
    source: context,
    builder: (context) => const Page(),
  ),
)
```

## Additional information

Feel free to contribute :-)

## Meta

![Star History Chart](https://api.star-history.com/svg?repos=rIIh/draggable_route_flutter&type=Date)
