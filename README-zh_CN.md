# zoomable_positioned_list

基于 `scrollable_positioned_list` 的支持缩放的定位列表。
支持捏合缩放（Pinch-to-zoom），同时保持基于索引的位置跟踪。

## 特性 (Features)

- **捏合缩放**: 无缝缩放列表内容。
- **滚动到索引**: 跳转或滚动到指定索引的项目。
- **项目定位**: 监听当前可见的项目。
- **滚动偏移监听**: 跟踪滚动偏移量的变化。
- **双击缩放**: 双击进行放大或缩小。

## 使用方法 (Usage)

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

## 参数 (Parameters)

| 参数 | 描述 |
|---|---|
| `itemCount` | 列表项数量。 |
| `itemBuilder` | 列表项构建器。 |
| `itemScrollController` | 用于跳转/滚动到特定项目的控制器。 |
| `itemPositionsListener` | 监听项目可见性的监听器。 |
| `scrollOffsetListener` | 监听滚动偏移变化的监听器。 |
| `minScale` | 最小缩放比例 (默认: 1.0)。 |
| `maxScale` | 最大缩放比例 (默认: 5.0)。 |
| `initialScale` | 初始缩放比例。 |
| `doubleTapScale` | 双击时的缩放比例。 |
| `enableZoom` | 启用/禁用缩放手势。 |

## 许可证 (License)

本包基于 `flutter_widgets` 包中的 `scrollable_positioned_list` 开发。
