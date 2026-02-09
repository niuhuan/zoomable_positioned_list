# zoomable_positioned_list

A zoomable scrollable positioned list based on `scrollable_positioned_list`.
Supports pinch-to-zoom with focal point preservation while maintaining index-based position tracking.

## Features

- **Pinch-to-zoom**: Seamlessly zoom in/out of the list content.
- **Scroll to index**: Jump or scroll to a specific item index.
- **Item positioning**: Listen to which items are currently visible.
- **Scroll offset monitoring**: Track the scroll offset changes.
- **Double tap zoom**: Double tap to zoom in/out.

## Usage

```dart
import 'package:zoomable_positioned_list/zoomable_positioned_list.dart';

final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

ZoomablePositionedList.builder(
  itemCount: 500,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  itemScrollController: itemScrollController,
  itemPositionsListener: itemPositionsListener,
  minScale: 1.0,
  maxScale: 3.0,
);
```

## Parameters

| Parameter | Description |
|---|---|
| `itemCount` | Number of items in the list. |
| `itemBuilder` | Builder for list items. |
| `itemScrollController` | Controller to jump/scroll to specific items. |
| `itemPositionsListener` | Listener for visibility of items. |
| `scrollOffsetListener` | Listener for scroll offset changes. |
| `minScale` | Minimum zoom scale (default: 1.0). |
| `maxScale` | Maximum zoom scale (default: 5.0). |
| `initialScale` | Initial zoom scale. |
| `doubleTapScale` | Scale to zoom to on double tap. |
| `enableZoom` | Enable/disable zoom gesture. |

## License

This package is based on `scrollable_positioned_list` from the `flutter_widgets` package.
