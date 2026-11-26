// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'wrapping.dart';
import 'viewport.dart';

/// A version of [CustomScrollView] that allows does not constrict the extents
/// to be within 0 and 1. See [CustomScrollView] for more information.
class UnboundedCustomScrollView extends CustomScrollView {
  final bool _shrinkWrap;

  /// Called for a mouse-wheel [PointerScrollEvent] before the surrounding
  /// [Scrollable] can jump. Trackpads are left to Flutter.
  final void Function(PointerScrollEvent event)? onPointerScroll;

  const UnboundedCustomScrollView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Key? center,
    double anchor = 0.0,
    double? cacheExtent,
    List<Widget> slivers = const <Widget>[],
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    this.onPointerScroll,
  })  : _shrinkWrap = shrinkWrap,
        _anchor = anchor,
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: false,
          center: center,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          slivers: slivers,
        );

  // [CustomScrollView] enforces constraints on [CustomScrollView.anchor], so
  // we need our own version.
  final double _anchor;

  @override
  double get anchor => _anchor;

  /// Build the viewport.
  @override
  @protected
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    final Widget viewport;
    if (_shrinkWrap) {
      viewport = CustomShrinkWrappingViewport(
        axisDirection: axisDirection,
        offset: offset,
        slivers: slivers,
        cacheExtent: cacheExtent,
        center: center,
        anchor: anchor,
      );
    } else {
      viewport = UnboundedViewport(
        axisDirection: axisDirection,
        offset: offset,
        slivers: slivers,
        cacheExtent: cacheExtent,
        center: center,
        anchor: anchor,
      );
    }
    final handler = onPointerScroll;
    if (handler == null) return viewport;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: (PointerSignalEvent event) {
        if (event is! PointerScrollEvent ||
            event.kind != PointerDeviceKind.mouse ||
            event.scrollDelta == Offset.zero) {
          return;
        }
        GestureBinding.instance.pointerSignalResolver.register(event,
            (PointerSignalEvent event) {
          handler(event as PointerScrollEvent);
        });
      },
      child: viewport,
    );
  }
}
