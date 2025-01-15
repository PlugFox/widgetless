import 'dart:async';

import 'package:l/l.dart';
import 'package:widgetless/src/clock.dart';
import 'package:widgetless/src/rendering/binding.dart';

void main() => l.capture<void>(
      () => runZonedGuarded<void>(
        () async {
          //final env = Env();
          final binding = Binding.instance
            ..deferFirstFrame()
            //..ensureVisualUpdate()
            ..scheduleWarmUpFrame()
            ..handleBeginFrame(Duration.zero)
            ..handleDrawFrame();
          final view = binding.platformDispatcher.views.first;
          final clock = Clock(view: view)..render();
          binding.allowFirstFrame();

          final stopwatch = Stopwatch()..start();

          void onTick(Timer timer) {
            // Render the next frame for each available view.
            binding
              ..scheduleFrame()
              ..handleBeginFrame(stopwatch.elapsed)
              ..handleDrawFrame();
            clock.render();
          }

          Timer.periodic(const Duration(seconds: 1), onTick);
        },
        (error, stackTrace) {
          l.e('An error occurred $error\n$stackTrace', stackTrace);
        },
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
