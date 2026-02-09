import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zoomable_positioned_list/zoomable_positioned_list.dart';

void main() {
  runApp(const ZoomablePositionedListExampleApp());
}

class ZoomablePositionedListExampleApp extends StatelessWidget {
  const ZoomablePositionedListExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zoomable_positioned_list',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  static const _itemCount = 200;

  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _scrollOffsetController = ScrollOffsetController();
  final _scrollOffsetListener =
      ScrollOffsetListener.create(recordProgrammaticScrolls: true);

  final _indexController = TextEditingController(text: '0');
  final _alignmentController = TextEditingController(text: '0');

  StreamSubscription<double>? _scrollDeltaSub;

  var _visibleSummary = 'visible: (unknown)';
  var _lastScrollDelta = 0.0;

  var _enableZoom = true;
  var _enableDoubleTapZoom = true;
  var _dragRegionLock = false;
  var _gestureSpeed = 1.0;

  var _minScale = 1.0;
  var _maxScale = 4.0;
  var _doubleTapScale = 2.0;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
    _scrollDeltaSub = _scrollOffsetListener.changes.listen((delta) {
      setState(() => _lastScrollDelta = delta);
    });
    _onPositionsChanged();
  }

  @override
  void dispose() {
    _scrollDeltaSub?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    _indexController.dispose();
    _alignmentController.dispose();
    super.dispose();
  }

  void _onPositionsChanged() {
    final positions = _itemPositionsListener.itemPositions.value.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    if (positions.isEmpty) return;
    setState(() {
      _visibleSummary =
          'visible: ${positions.first.index}..${positions.last.index} (${positions.length})';
    });
  }

  int? _tryParseIndex() => int.tryParse(_indexController.text.trim());

  double _parseAlignment() {
    final v = double.tryParse(_alignmentController.text.trim());
    return (v ?? 0).clamp(0.0, 1.0);
  }

  void _jumpTo() {
    final index = _tryParseIndex();
    if (index == null) return;
    _itemScrollController.jumpTo(
      index: index.clamp(0, _itemCount - 1),
      alignment: _parseAlignment(),
    );
  }

  Future<void> _scrollTo() async {
    final index = _tryParseIndex();
    if (index == null) return;
    await _itemScrollController.scrollTo(
      index: index.clamp(0, _itemCount - 1),
      alignment: _parseAlignment(),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _nudge(double offset) async {
    await _scrollOffsetController.animateScroll(
      offset: offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('zoomable_positioned_list example'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _indexController,
                          decoration: const InputDecoration(
                            labelText: 'Index',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _alignmentController,
                          decoration: const InputDecoration(
                            labelText: 'Alignment',
                            helperText: '0..1',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      FilledButton(onPressed: _jumpTo, child: const Text('Jump')),
                      FilledButton.tonal(
                          onPressed: _scrollTo, child: const Text('Scroll')),
                      FilledButton.tonal(
                        onPressed: () => _nudge(-240),
                        child: const Text('▲ -240px'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _nudge(240),
                        child: const Text('▼ +240px'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('enableZoom'),
                        selected: _enableZoom,
                        onSelected: (v) => setState(() => _enableZoom = v),
                      ),
                      FilterChip(
                        label: const Text('doubleTapZoom'),
                        selected: _enableDoubleTapZoom,
                        onSelected: (v) =>
                            setState(() => _enableDoubleTapZoom = v),
                      ),
                      FilterChip(
                        label: const Text('dragRegionLock'),
                        selected: _dragRegionLock,
                        onSelected: (v) => setState(() => _dragRegionLock = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_visibleSummary    Δoffset: ${_lastScrollDelta.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'gestureSpeed',
                    value: _gestureSpeed,
                    min: 0.5,
                    max: 2.0,
                    onChanged: (v) => setState(() => _gestureSpeed = v),
                  ),
                  _LabeledSlider(
                    label: 'minScale',
                    value: _minScale,
                    min: 0.5,
                    max: 2.0,
                    onChanged: (v) {
                      setState(() {
                        _minScale = v;
                        _maxScale = _maxScale < _minScale ? _minScale : _maxScale;
                        _doubleTapScale =
                            _doubleTapScale.clamp(_minScale, _maxScale);
                      });
                    },
                  ),
                  _LabeledSlider(
                    label: 'maxScale',
                    value: _maxScale,
                    min: 1.0,
                    max: 8.0,
                    onChanged: (v) {
                      setState(() {
                        _maxScale = v;
                        _minScale = _minScale > _maxScale ? _maxScale : _minScale;
                        _doubleTapScale =
                            _doubleTapScale.clamp(_minScale, _maxScale);
                      });
                    },
                  ),
                  _LabeledSlider(
                    label: 'doubleTapScale',
                    value: _doubleTapScale,
                    min: _minScale,
                    max: _maxScale,
                    onChanged: (v) => setState(() => _doubleTapScale = v),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ZoomablePositionedList.builder(
                itemCount: _itemCount,
                itemBuilder: (context, index) => _ExampleItem(index: index),
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                scrollOffsetController: _scrollOffsetController,
                scrollOffsetListener: _scrollOffsetListener,
                minScale: _minScale,
                maxScale: _maxScale,
                doubleTapScale: _doubleTapScale,
                enableZoom: _enableZoom,
                enableDoubleTapZoom: _enableDoubleTapZoom,
                dragRegionLock: _dragRegionLock,
                gestureSpeed: _gestureSpeed,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleItem extends StatelessWidget {
  const _ExampleItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      (index % 20) / 20,
    )!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: color,
        child: SizedBox(
          height: 96,
          child: Center(
            child: Text(
              'Item $index',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text('$label: ${value.toStringAsFixed(2)}'),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

