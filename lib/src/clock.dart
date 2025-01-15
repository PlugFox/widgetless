// ignore_for_file: cascade_invocations

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
    canvas
      ..drawCircle(center, radius, paint)
      ..drawCircle(center, radius, borderPaint);

    // Draw hour marks
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final markerStart = ui.Offset(
        center.dx + (radius - 15) * math.cos(angle),
        center.dy + (radius - 15) * math.sin(angle),
      );
      final markerEnd = ui.Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(markerStart, markerEnd, borderPaint);

      // TODO(plugfox): Add text
      // Mike Matiunin <plugfox@gmail.com>, 16 January 2025
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
    // Use TransformLayer to rotate hands
    // Create layer for hands
    final ui.Layer handsLayer;
    {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      final center = ui.Offset(size.width / 2, size.height / 2);
      final radius = math.min(size.width, size.height) / 2;

      final now = DateTime.now();

      // Hour hand
      final hourPaint = ui.Paint()
        ..color = const ui.Color(0xFF000000)
        ..strokeWidth = 4.0
        ..style = ui.PaintingStyle.stroke
        ..filterQuality = ui.FilterQuality.none
        ..isAntiAlias = true;

      final hourAngle = (now.hour % 12 + now.minute / 60) * 30 * math.pi / 180;
      final hourHand = ui.Offset(
        center.dx + (radius * 0.5) * math.sin(hourAngle),
        center.dy - (radius * 0.5) * math.cos(hourAngle),
      );
      canvas.drawLine(center, hourHand, hourPaint);

      // Minute hand
      final minutePaint = ui.Paint()
        ..color = const ui.Color(0xFF000000)
        ..strokeWidth = 3.0
        ..style = ui.PaintingStyle.stroke
        ..filterQuality = ui.FilterQuality.none
        ..isAntiAlias = true;

      final minuteAngle = (now.minute + now.second / 60) * 6 * math.pi / 180;
      final minuteHand = ui.Offset(
        center.dx + (radius * 0.7) * math.sin(minuteAngle),
        center.dy - (radius * 0.7) * math.cos(minuteAngle),
      );
      canvas.drawLine(center, minuteHand, minutePaint);

      // Second hand
      final secondPaint = ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..strokeWidth = 1.5
        ..style = ui.PaintingStyle.stroke
        ..filterQuality = ui.FilterQuality.none
        ..isAntiAlias = true;

      final secondAngle = now.second * 6 * math.pi / 180;
      final secondHand = ui.Offset(
        center.dx + (radius * 0.8) * math.sin(secondAngle),
        center.dy - (radius * 0.8) * math.cos(secondAngle),
      );
      canvas.drawLine(center, secondHand, secondPaint);

      // Center dot
      canvas.drawCircle(center, 4, hourPaint);

      handsLayer = ui.PictureLayer(ui.Offset.zero & size)..picture = recorder.endRecording();
    }

    // Create scene
    final rect = ui.Rect.fromLTRB(0, 0, size.width, size.height);
    final rootLayer = ui.ContainerLayer()
      ..append(_faceLayer.layer!)
      ..append(handsLayer);
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

  void dispose() {
    _faceLayer.layer = null;
  }
}
