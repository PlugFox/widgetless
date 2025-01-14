import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

base class _BindingBase = BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding /*, WidgetsBinding */;

final class Binding extends _BindingBase {
  Binding._() : super();

  static final Binding instance = Binding._();

/*
  Size _surfaceSize = const Size.square(480);

  /// The size of the surface that the render view is rendering into.
  void setSurfaceSize(Size size) {
    if (_surfaceSize == size) return;
    _surfaceSize = size;
    handleMetricsChanged();
  }

  ViewConfiguration createViewConfiguration() => ViewConfiguration(
        physicalConstraints: BoxConstraints.tight(_surfaceSize),
        logicalConstraints: BoxConstraints.tight(_surfaceSize),
        devicePixelRatio: 1,
      );

  void initRenderView() {
    renderView = _ExposedRenderView(
      configuration: createViewConfiguration(),
      view: platformDispatcher.implicitView!,
    );
    renderView.prepareInitialFrame();
  }

  @override
  _ExposedRenderView get renderView => super.renderView as _ExposedRenderView; */
}

/* /// Render view implementation that exposes the [layer] as an [OffsetLayer]
/// for converting to images at the root level.
class _ExposedRenderView extends RenderView {
  _ExposedRenderView({
    required ViewConfiguration super.configuration,
    required super.view,
    super.child,
  });

  // Unprotect the layer getter.
  @override
  OffsetLayer get layer => super.layer as OffsetLayer;
}
*/
