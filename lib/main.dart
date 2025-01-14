import 'dart:async';
import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:l/l.dart';
import 'package:widgetless/src/rendering/binding.dart';
import 'package:widgetless/src/util/env.dart';

void main() => l.capture<void>(
      () => runZonedGuarded<void>(
        () async {
          final env = Env();
          final shouldRender = env.get<bool>('render') == true;
          final binding = Binding.instance
            /* ..attachRootWidget(rootWidget) */
            /* ..ensureVisualUpdate() */
            ..deferFirstFrame();
          final dispatcher = binding.platformDispatcher;
          // Schedule and render a warm-up frame.
          if (dispatcher.implicitView case ui.FlutterView view when shouldRender) {
            binding
              ..scheduleWarmUpFrame()
              ..handleBeginFrame(Duration.zero)
              ..handleDrawFrame();
            render(view);
          }
          binding.allowFirstFrame();
          final clock = Stopwatch()..start();
          var frames = 0;
          while (shouldRender && clock.elapsed.inSeconds < 15) {
            // Render the next frame for each available view.
            binding
              ..scheduleFrame()
              ..handleBeginFrame(clock.elapsed)
              ..handleDrawFrame();
            for (final view in dispatcher.views) render(view);
            // TODO(plugfox): Make it possible to render at a fixed frame rate.
            // Mike Matiunin <plugfox@gmail.com>, 14 January 2025
            await Future<void>.delayed(const Duration(milliseconds: 16)); // Rate limit to 60 FPS.
            frames++;
          }
          final elapsed = clock.elapsed;
          l
            ..i('Rendered $frames frames in ${elapsed.inMilliseconds}ms')
            ..i('Average FPS: ${frames ~/ elapsed.inSeconds} frames per second');
          io.exit(0);
        },
        l.e,
      ),
      const LogOptions(
        handlePrint: true,
        messageFormatting: _messageFormatting,
        outputInRelease: true,
        printColors: true,
      ),
    );

/// Formats the log message.
Object _messageFormatting(LogMessage log) => '${_timeFormat(log.timestamp)} | ${log.message}';

/// Formats the time.
String _timeFormat(DateTime time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

// TODO(plugfox): Pass the delta time and frame number to the paint method.
// Mike Matiunin <plugfox@gmail.com>, 14 January 2025
void render(ui.FlutterView view) {
  // Получаем информацию о размерах экрана
  final windowSize = view.physicalSize;
  final pixelRatio = view.devicePixelRatio;
  final logicalSize = windowSize / pixelRatio;
  final rect = Rect.fromLTWH(0, 0, logicalSize.width, logicalSize.height);

  // Создаем рекордер для записи команд рисования
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Рисуем на холсте
  paint(canvas, windowSize);

  // Создаем слой с картинкой
  final pictureLayer = PictureLayer(rect)..picture = recorder.endRecording();
  final rootLayer = OffsetLayer()..append(pictureLayer);

  // Создаем сцену
  final sceneBuilder = ui.SceneBuilder()
    ..pushClipRect(rect) // Обрезаем всё за пределами доски
    ..pop();
  final scene = rootLayer.buildScene(sceneBuilder);

  // Отправляем сцену во вьюху
  view.render(scene);
}

void paint(Canvas canvas, Size size) {
  canvas
    ..save()
    ..clipRect(Offset.zero & size);
  final paint = Paint()..style = PaintingStyle.fill;
  canvas
    ..drawPaint(paint..color = const Color(0xFFFFFFFF))
    ..drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 - 16,
      paint..color = const Color(0xFF000000),
    )
    ..restore();
}
