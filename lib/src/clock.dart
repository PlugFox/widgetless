import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' as ui;
import 'package:l/l.dart';

class Clock {
  Clock({required ui.FlutterView view}) : _view = view;

  final ui.FlutterView _view;
  ui.Size _size = ui.Size.zero;
  final ui.LayerHandle<ui.OffsetLayer> _faceLayer = ui.LayerHandle<ui.OffsetLayer>();
  ui.Picture? _facePicture;

  void _createFacePicture(ui.Size size) {
    final paint = ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.fill
      ..blendMode = ui.BlendMode.src
      ..filterQuality = ui.FilterQuality.none
      ..isAntiAlias = true;

    final borderPaint = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..blendMode = ui.BlendMode.src
      ..filterQuality = ui.FilterQuality.none
      ..isAntiAlias = true;

    final center = ui.Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)
      ..save()
      ..clipRect(ui.Offset.zero & size);

    // Draw face
    // ignore: cascade_invocations
    canvas
      ..drawCircle(center, radius, paint)
      ..drawCircle(center, radius, borderPaint);

    // Draw hour marks
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final markerStart =
          ui.Offset(center.dx + (radius - 15) * math.cos(angle), center.dy + (radius - 15) * math.sin(angle));
      final markerEnd = ui.Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

      canvas.drawLine(markerStart, markerEnd, borderPaint);
    }

    canvas.restore();
    _facePicture = recorder.endRecording();
  }

  void render() {
    final view = _view;
    final windowSize = view.physicalSize;
    //final pixelRatio = view.devicePixelRatio;
    //final logicalSize = windowSize / pixelRatio;

    // Relayout if size changed
    if (_size != windowSize) {
      l.i('Size changed: $_size -> $windowSize');
      _size = windowSize; // logicalSize;
      _facePicture?.dispose();
      _facePicture = null;
      _createFacePicture(windowSize);
    }
    final size = _size;

    // Create picture layer
    final pictureLayer = ui.PictureLayer(ui.Offset.zero & windowSize)
      ..isComplexHint = true
      ..willChangeHint = false
      ..picture = _facePicture!;

    // Create face layer with picture layer
    _faceLayer.layer = ui.OffsetLayer(
      offset: ui.Offset.zero,
    )..append(pictureLayer);

    // Add hands layer to root layer
    // ...

    // Create scene
    final rect = ui.Rect.fromLTRB(0, 0, size.width, size.height);
    final rootLayer = ui.ContainerLayer()..append(_faceLayer.layer!);
    final sceneBuilder = ui.SceneBuilder()
      ..pushClipRect(rect)
      ..pushOffset(0, 0)
      ..pop();

    // Add root layer to scene
    rootLayer.addToScene(sceneBuilder);

    //_paint(logicalSize);

    final scene = sceneBuilder.build();
    _view.render(scene);
  }

  /* void _performLayout(ui.Size size) {
    _createFacePicture(_size = size);
  }

  void _createFacePicture(ui.Size size) {

    _facePicture?.dispose();
    _facePicture = recorder.endRecording();

    _faceLayer?.dispose();
    _faceLayer = ui.PictureLayer(ui.Offset.zero & size)..picture = _facePicture;
  } */

  /* void _paint(ui.PaintingContext context, ui.Offset offset) {
    final size = _size;

    // Create root layer
    final rootLayer = ui.ContainerLayer();

    // Add cached face layer
    if (_faceLayer != null) {
      rootLayer.append(_faceLayer!);
    }

    // Create layer for hands
    final handsLayer = ui.PictureLayer(ui.Offset.zero & size);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final center = ui.Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final now = DateTime.now();

    // Hour hand
    final hourPaint = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..strokeWidth = 4.0
      ..style = ui.PaintingStyle.stroke;

    final hourAngle = (now.hour % 12 + now.minute / 60) * 30 * math.pi / 180;
    final hourHand =
        ui.Offset(center.dx + (radius * 0.5) * math.sin(hourAngle), center.dy - (radius * 0.5) * math.cos(hourAngle));
    canvas.drawLine(center, hourHand, hourPaint);

    // Minute hand
    final minutePaint = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..strokeWidth = 3.0
      ..style = ui.PaintingStyle.stroke;

    final minuteAngle = (now.minute + now.second / 60) * 6 * math.pi / 180;
    final minuteHand = ui.Offset(
        center.dx + (radius * 0.7) * math.sin(minuteAngle), center.dy - (radius * 0.7) * math.cos(minuteAngle));
    canvas.drawLine(center, minuteHand, minutePaint);

    // Second hand
    final secondPaint = ui.Paint()
      ..color = const ui.Color(0xFFFF0000)
      ..strokeWidth = 1.5
      ..style = ui.PaintingStyle.stroke;

    final secondAngle = now.second * 6 * math.pi / 180;
    final secondHand = ui.Offset(
        center.dx + (radius * 0.8) * math.sin(secondAngle), center.dy - (radius * 0.8) * math.cos(secondAngle));
    canvas.drawLine(center, secondHand, secondPaint);

    // Center dot
    canvas.drawCircle(center, 4, hourPaint);

    handsLayer.picture = recorder.endRecording();
    rootLayer.append(handsLayer);

    // Set as root layer
    context.addLayer(rootLayer);

    // Schedule next frame
    SchedulerBinding.instance.scheduleFrameCallback((_) => markNeedsPaint());
  } */

  void dispose() {
    _faceLayer.layer = null;
  }
}
