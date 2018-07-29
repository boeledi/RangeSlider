import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

typedef RangeSliderCallback(double lowerValue, double upperValue);

class RangeSlider extends StatefulWidget {
  const RangeSlider({
    Key key,
    this.min: 0.0,
    this.max: 1.0,
    this.divisions,
    @required this.lowerValue,
    @required this.upperValue,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.showValueIndicator: false,
    this.valueIndicatorMaxDecimals: 1,
  })  : assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(divisions == null || divisions > 0),
        assert(lowerValue != null),
        assert(upperValue != null),
        assert(lowerValue >= min && lowerValue <= max),
        assert(upperValue >= lowerValue && upperValue <= max),
        assert(valueIndicatorMaxDecimals >= 0 && valueIndicatorMaxDecimals < 5),
        super(key: key);

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  final double min;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  final double max;

  /// The currently selected lower value.
  /// 
  /// Corresponds to the left thumb
  /// Must be greater than or equal to [min],
  /// less than or equal to [max]. 
  final double lowerValue;

  /// The currently selected upper value.
  /// 
  /// Corresponds to the right thumb
  /// Must be greater than [lowerValue],
  /// less than or equal to [max]. 
  final double upperValue;

  /// The number of discrete divisions.
  ///
  /// If null, the slider is continuous.
  final int divisions;

  /// Do we show a label above the active thumb when
  /// the RangeSlider is active ?
  final bool showValueIndicator;

  /// Max number of decimals when displaying
  /// the value in the label above the active
  /// thumb
  final int valueIndicatorMaxDecimals;

  /// Callback to invoke when the user is changing the
  /// values.
  final RangeSliderCallback onChanged;

  /// Callback to invoke when the user starts dragging
  final RangeSliderCallback onChangeStart;

  /// Callback to invoke when the user ends the dragging
  final RangeSliderCallback onChangeEnd;

  @override
  _RangeSliderState createState() => _RangeSliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DoubleProperty('lowerValue', lowerValue));
    properties.add(new DoubleProperty('upperValue', upperValue));
    properties.add(new DoubleProperty('min', min));
    properties.add(new DoubleProperty('max', max));
    properties.add(new IntProperty('divisions', divisions));
  }
}

class _RangeSliderState extends State<RangeSlider> with TickerProviderStateMixin {
  static const Duration kEnableAnimationDuration = const Duration(milliseconds: 75);
  static const Duration kValueIndicatorAnimationDuration = const Duration(milliseconds: 100);

  // Animation controller that is run when the overlay (a.k.a radial reaction)
  // is shown in response to user interaction.
  AnimationController overlayController;

  // Animation controller that is run when enabling/disabling the slider.
  AnimationController enableController;

  // Animation controller that is run when the value indicator is being shown
  // or hidden.
  AnimationController valueIndicatorController;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controllers
    overlayController = new AnimationController(
      duration: kRadialReactionDuration,
      vsync: this,
    );

    enableController = new AnimationController(
      duration: kEnableAnimationDuration,
      vsync: this,
    );

    valueIndicatorController = new AnimationController(
      duration: kValueIndicatorAnimationDuration,
      vsync: this,
    );

    // Set the enableController value to active (1 if we are handling callback)
    // or to inactive (0 otherwise)
    enableController.value = widget.onChanged != null ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    // release the animation controllers
    valueIndicatorController.dispose();
    enableController.dispose();
    overlayController.dispose();
    super.dispose();
  }

  /// -------------------------------------------------
  /// Returns a value between 0.0 and 1.0
  /// given a value between min and max
  /// -------------------------------------------------
  double _unlerp(double value){
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min ? (value - widget.min) / (widget.max - widget.min) : 0.0;
  }

  /// -------------------------------------------------
  /// Returns the number, between min and max
  /// proportional to value, which must be
  /// between 0.0 and 1.0
  /// -------------------------------------------------
  double lerp(double value){
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  /// -------------------------------------------------
  /// Handling of any change applied to lowerValue
  /// and/or upperValue
  /// Invokes the corresponding callback
  /// -------------------------------------------------
  void _handleChanged(double lowerValue, double upperValue){
    if (widget.onChanged is RangeSliderCallback){
      widget.onChanged(lerp(lowerValue), lerp(upperValue));
    }
  }
  void _handleChangeStart(double lowerValue, double upperValue){
    if (widget.onChangeStart is RangeSliderCallback){
      widget.onChangeStart(lerp(lowerValue), lerp(upperValue));
    }
  }
  void _handleChangeEnd(double lowerValue, double upperValue){
    if (widget.onChangeEnd is RangeSliderCallback){
      widget.onChangeEnd(lerp(lowerValue), lerp(upperValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _RangeSliderRenderObjectWidget(
      lowerValue: _unlerp(widget.lowerValue),
      upperValue: _unlerp(widget.upperValue),
      divisions: widget.divisions,
      onChanged: (widget.onChanged != null) ? _handleChanged : null,
      onChangeStart: _handleChangeStart,
      onChangeEnd: _handleChangeEnd,
      sliderTheme: SliderTheme.of(context),
      state: this,
      showValueIndicator: widget.showValueIndicator,
      valueIndicatorMaxDecimals: widget.valueIndicatorMaxDecimals,
    );
  }
}

/// ------------------------------------------------------
/// Widget that instantiates a RenderObject
/// ------------------------------------------------------
class _RangeSliderRenderObjectWidget extends LeafRenderObjectWidget {
  const _RangeSliderRenderObjectWidget({
    Key key,
    this.lowerValue,
    this.upperValue,
    this.divisions,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.sliderTheme,
    this.state,
    this.showValueIndicator,
    this.valueIndicatorMaxDecimals,
  }) : super(key: key);

  final _RangeSliderState state;
  final RangeSliderCallback onChanged;
  final RangeSliderCallback onChangeStart;
  final RangeSliderCallback onChangeEnd;
  final SliderThemeData sliderTheme;
  final double lowerValue;
  final double upperValue;
  final int divisions;
  final bool showValueIndicator;
  final int valueIndicatorMaxDecimals;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return new _RenderRangeSlider(
      lowerValue: lowerValue,
      upperValue: upperValue,
      divisions: divisions,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      sliderTheme: sliderTheme,
      state: state,
      showValueIndicator: showValueIndicator,
      valueIndicatorMaxDecimals: valueIndicatorMaxDecimals,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRangeSlider renderObject) {
    renderObject
      ..lowerValue = lowerValue
      ..upperValue = upperValue
      ..divisions = divisions
      ..onChanged = onChanged
      ..onChangeStart = onChangeStart
      ..onChangeEnd = onChangeEnd
      ..sliderTheme = sliderTheme
      ..showValueIndicator = showValueIndicator
      ..valueIndicatorMaxDecimals = valueIndicatorMaxDecimals;
  }
}

/// ------------------------------------------------------
/// Class that renders the RangeSlider as a pure drawing
/// in a Canvas and allows the user to interact.
/// ------------------------------------------------------
class _RenderRangeSlider extends RenderBox {
  _RenderRangeSlider({
    double lowerValue,
    double upperValue,
    int divisions,
    RangeSliderCallback onChanged,
    RangeSliderCallback onChangeStart,
    RangeSliderCallback onChangeEnd,
    SliderThemeData sliderTheme,
    @required this.state,
    bool showValueIndicator,
    int valueIndicatorMaxDecimals,
  }) {
    // Initialization
    this.divisions = divisions;
    this.lowerValue = lowerValue;
    this.upperValue = upperValue;
    this.onChanged = onChanged;
    this.onChangeStart = onChangeStart;
    this.onChangeEnd = onChangeEnd;
    this.sliderTheme = sliderTheme;
    this.showValueIndicator = showValueIndicator;
    this.valueIndicatorMaxDecimals = valueIndicatorMaxDecimals;

    // Initialization of the Drag Gesture Recognizer
    _drag = new HorizontalDragGestureRecognizer()
                ..onStart  = _handleDragStart
                ..onEnd    = _handleDragEnd
                ..onUpdate = _handleDragUpdate
                ..onCancel = _handleDragCancel
                ;

    // Initialization of the overlay animation
    _overlayAnimation = new CurvedAnimation(
      parent: state.overlayController,
      curve: Curves.fastOutSlowIn,
    );

    // Initialization of the enable/disable animation
    _enableAnimation = new CurvedAnimation(
      parent: state.enableController,
      curve: Curves.easeInOut,
    );

    // Initialization of the animation to show the value indicator
    _valueIndicatorAnimation = new CurvedAnimation(
      parent: state.valueIndicatorController,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// -------------------------------------------------
  /// Global Constants. See Material.io 
  /// -------------------------------------------------
  static const double _overlayRadius = 16.0;
  static const double _overlayDiameter = _overlayRadius * 2.0;
  static const double _trackHeight = 2.0;
  static const double _preferredTrackWidth = 144.0;
  static const double _preferredTotalWidth = _preferredTrackWidth + 2 * _overlayDiameter;
  static const double _tickRadius = _trackHeight / 2.0;
  static final Tween<double> _overlayRadiusTween = new Tween<double>(begin: 0.0, end: _overlayRadius);

  /// -------------------------------------------------
  /// Instance specific properties
  /// -------------------------------------------------
  _RangeSliderState state;
  RangeSliderCallback _onChanged;
  RangeSliderCallback _onChangeStart;
  RangeSliderCallback _onChangeEnd;
  double _lowerValue;
  double _upperValue;
  int _divisions;
  Animation<double> _overlayAnimation;
  Animation<double> _enableAnimation;
  Animation<double> _valueIndicatorAnimation;
  HorizontalDragGestureRecognizer _drag;
  SliderThemeData _sliderTheme;
  bool _showValueIndicator;
  int _valueIndicatorMaxDecimals;
  final TextPainter _valueIndicatorPainter = new TextPainter();

  /// --------------------------------------------------
  /// Setters
  /// Setters are necessary since we will need
  /// to update the values via the 
  /// _RangeSliderRenderObjectWidget.updateRenderObject
  /// --------------------------------------------------
  set lowerValue(double value){
    assert(value != null && value >= 0.0 && value <= 1.0);
    _lowerValue = _discretize(value);
  }

  set upperValue(double value){
    assert(value != null && value >= 0.0 && value <= 1.0);
    _upperValue = _discretize(value);
  }

  set divisions(int value){
    _divisions = value;
    
    // If we change the value, we need to repaint
    markNeedsPaint();
  }

  set onChanged(RangeSliderCallback value){
    // If no changes were applied, skip
    if (_onChanged == value){
      return;
    }
  
    // Were we handling callbacks?
    final bool wasInteractive = isInteractive;

    // Record the new callback
    _onChanged = value;

    // Did we change the callbacks
    if (wasInteractive != isInteractive){
      if (isInteractive){
        state.enableController.forward();
      } else {
        state.enableController.reverse();
      }

      // As we apply a change, we need to redraw
      markNeedsPaint();
    }
  }

  set onChangeStart(RangeSliderCallback value){
    _onChangeStart = value;
  }

  set onChangeEnd(RangeSliderCallback value){
    _onChangeEnd = value;
  }

  set sliderTheme(SliderThemeData value){
    assert (value != null);
    _sliderTheme = value;

    // If we change the theme, we need to repaint
    markNeedsPaint();
  }

  set showValueIndicator(bool value){
    // Skip if no changes
    if (value == _showValueIndicator){
      return;
    }
    _showValueIndicator = value;

    // Force a repaint of the value indicator
    _updateValueIndicatorPainter();
  }

  set valueIndicatorMaxDecimals(int value){
    // Skip if no changes
    if (value == _valueIndicatorMaxDecimals){
      return;
    }

    _valueIndicatorMaxDecimals = value;

    // Force a repaint
    markNeedsPaint();
  }

  /// ----------------------------------------------
  /// Are we handling callbacks?
  /// ----------------------------------------------
  bool get isInteractive => (_onChanged != null);

  /// ----------------------------------------------
  /// Obtain the radius of a thumb from the Theme
  /// ----------------------------------------------
  double get _thumbRadius {
    final Size preferredSize = _sliderTheme.thumbShape.getPreferredSize(isInteractive, (_divisions != null));
    return math.max(preferredSize.width, preferredSize.height) / 2.0;
  }

  /// ----------------------------------------------
  /// Get from the SliderTheme the right to show
  /// the value indicator unless said otherwise
  /// ----------------------------------------------
  bool get showValueIndicator {
    bool showValueIndicator;
    switch (_sliderTheme.showValueIndicator) {
      case ShowValueIndicator.onlyForDiscrete:
        showValueIndicator = (_divisions != null);
        break;
      case ShowValueIndicator.onlyForContinuous:
        showValueIndicator = (_divisions == null);
        break;
      case ShowValueIndicator.always:
        showValueIndicator = true;
        break;
      case ShowValueIndicator.never:
        showValueIndicator = false;
        break;
    }
    return (showValueIndicator && _showValueIndicator);
  }

  /// --------------------------------------------
  /// Update the value indicator painter, based
  /// on the SliderTheme
  /// --------------------------------------------
  void _updateValueIndicatorPainter(){
    if (_showValueIndicator != false){
      _valueIndicatorPainter
        ..text = new TextSpan(
          style: _sliderTheme.valueIndicatorTextStyle,
          text: ''
        )
        ..textDirection = TextDirection.ltr
        ..layout();
    } else {
      _valueIndicatorPainter.text = null;
    }

    // Force a re-layout
    markNeedsLayout();
  }

  /// --------------------------------------------
  /// We need to repaint
  /// we are dragging and changing the activation
  /// --------------------------------------------
  @override
  void attach(PipelineOwner owner){
    super.attach(owner);
    _overlayAnimation.addListener(markNeedsPaint);
    _enableAnimation.addListener(markNeedsPaint);
    _valueIndicatorAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach(){
    _valueIndicatorAnimation.removeListener(markNeedsPaint);
    _enableAnimation.removeListener(markNeedsPaint);
    _overlayAnimation.removeListener(markNeedsPaint);
    super.detach();
  }

  /// -------------------------------------------
  /// The size of this RenderBox is defined by
  /// the parent
  /// -------------------------------------------
  @override
  bool get sizedByParent => true;

  /// -------------------------------------------
  /// Update of the RenderBox size using only
  /// the constraints.
  /// Compulsory when sizedByParent returns true
  /// -------------------------------------------
  @override
  void performResize(){
    size = new Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : _preferredTotalWidth,
      constraints.hasBoundedHeight ? constraints.maxHeight : _overlayDiameter,
    );
  }

  /// -------------------------------------------
  /// Mandatory if we want any interaction
  /// -------------------------------------------
  @override
  bool hitTestSelf(Offset position) => true;

  /// -------------------------------------------
  /// Computation of the min,max intrinsic
  /// width and height of the box
  /// -------------------------------------------
  @override
  double computeMinIntrinsicWidth(double height) {
    return 2 * math.max(
        _overlayDiameter,
        _sliderTheme.thumbShape.getPreferredSize(true, (_divisions != null)).width
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _preferredTotalWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      _overlayDiameter, 
      _sliderTheme.thumbShape.getPreferredSize(true, (_divisions != null)).height
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(
      _overlayDiameter, 
      _sliderTheme.thumbShape.getPreferredSize(true, (_divisions != null)).height
    );
  }

  /// ---------------------------------------------
  /// Paint the Range Slider
  /// ---------------------------------------------
  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    _paintTrack(canvas, offset);
    _paintOverlay(canvas);
    if (_divisions != null){
      _paintTickMarks(canvas, offset);
    }
    _paintValueIndicator(context);
    _paintThumbs(context);
  }

  /// ---------------------------------------------
  /// Paint the track
  /// ---------------------------------------------
  double _trackLength;
  double _trackVerticalCenter;
  double _trackLeft;
  double _trackTop;
  double _trackBottom;
  double _trackRight;
  double _thumbLeftPosition;
  double _thumbRightPosition;

  void _paintTrack(Canvas canvas, Offset offset){
    final double trackRadius = _trackHeight / 2.0;

    _trackLength = size.width - 2 * _overlayDiameter;
    _trackVerticalCenter = offset.dy + (size.height) / 2.0;
    _trackLeft = offset.dx + _overlayDiameter;
    _trackTop = _trackVerticalCenter - trackRadius;
    _trackBottom = _trackVerticalCenter + trackRadius;
    _trackRight = _trackLeft + _trackLength;

    // Compute the position of the thumbs
    _thumbLeftPosition = _trackLeft + _lowerValue * _trackLength;
    _thumbRightPosition = _trackLeft + _upperValue * _trackLength;

    // Define the paint colors for both unselected and selected track segments
    Paint unselectedTrackPaint = new Paint()..color = _sliderTheme.inactiveTrackColor;
    Paint selectedTrackPaint = new Paint()..color = _sliderTheme.activeTrackColor;

    // Draw the track
    if (_lowerValue > 0.0){
      // Draw the unselected left range
      canvas.drawRect(new Rect.fromLTRB(_trackLeft, _trackTop, _thumbLeftPosition, _trackBottom), unselectedTrackPaint);
    }
    // Draw the selected range
    canvas.drawRect(new Rect.fromLTRB(_thumbLeftPosition, _trackTop, _thumbRightPosition, _trackBottom), selectedTrackPaint);

    if (_upperValue < 1.0){
      // Draw the unselected right range
      canvas.drawRect(new Rect.fromLTRB(_thumbRightPosition, _trackTop, _trackRight, _trackBottom), unselectedTrackPaint);
    }
  }

  /// ---------------------------------------------
  /// Paint the overlay
  /// ---------------------------------------------
  void _paintOverlay(Canvas canvas){
    if (!_overlayAnimation.isDismissed && _previousActiveThumb != _ActiveThumb.none){
      final Paint overlayPaint = new Paint()..color = _sliderTheme.overlayColor;
      final double radius = _overlayRadiusTween.evaluate(_overlayAnimation);

      // We need to find the position of the overlay % active thumb
      Offset center;
      if (_previousActiveThumb == _ActiveThumb.lowerThumb){
        center = new Offset(_thumbLeftPosition, _trackVerticalCenter);
      } else {
        center = new Offset(_thumbRightPosition, _trackVerticalCenter);
      }

      canvas.drawCircle(center, radius, overlayPaint);
    }
  }

  /// ---------------------------------------------
  /// Paint the tick marks
  /// ---------------------------------------------
  void _paintTickMarks(Canvas canvas, Offset offset){
    final double trackWidth = _trackRight - _trackLeft;
    final double dx = (trackWidth - _trackHeight) / _divisions;

    for (int i=0; i<= _divisions; i++){
      final double left = _trackLeft + i * dx;
      final Offset center = new Offset(left + _tickRadius, _trackTop + _tickRadius);

      canvas.drawCircle(center, _tickRadius, new Paint()..color = _sliderTheme.activeTickMarkColor);
    }
  }

  /// ---------------------------------------------
  /// Paint the thumbs
  /// ---------------------------------------------
  Rect _thumbLowerRect;
  Rect _thumbUpperRect;

  void _paintThumbs(PaintingContext context){
    final Offset thumbLowerCenter = new Offset(_thumbLeftPosition, _trackVerticalCenter);
    final Offset thumbUpperCenter = new Offset(_thumbRightPosition, _trackVerticalCenter);
    final double thumbRadius = _thumbRadius;

    _thumbLowerRect = new Rect.fromCircle(center: thumbLowerCenter, radius: thumbRadius);
    _thumbUpperRect = new Rect.fromCircle(center: thumbUpperCenter, radius: thumbRadius);

    // Paint the thumbs, via the Theme
    _sliderTheme.thumbShape.paint(
      context,
      thumbLowerCenter,
      isDiscrete: (_divisions != null),
      parentBox: this,
      sliderTheme: _sliderTheme,
      value: _lowerValue,
      enableAnimation: _enableAnimation,
      activationAnimation: _valueIndicatorAnimation,
      labelPainter: _valueIndicatorPainter,
    );

    _sliderTheme.thumbShape.paint(
      context,
      thumbUpperCenter,
      isDiscrete: (_divisions != null),
      parentBox: this,
      sliderTheme: _sliderTheme,
      value: _upperValue,
      enableAnimation: _enableAnimation,
      activationAnimation: _valueIndicatorAnimation,
      labelPainter: _valueIndicatorPainter,
    );
  }

  /// ---------------------------------------------
  /// Paint the value indicator
  /// ---------------------------------------------
  void _paintValueIndicator(PaintingContext context){
    if (isInteractive && _showValueIndicator && _previousActiveThumb != _ActiveThumb.none) {
      if (_valueIndicatorAnimation.status != AnimationStatus.dismissed && showValueIndicator){

        // We need to find the position of the value indicator % active thumb
        // as well as the value to be displayed
        Offset thumbCenter;
        double value;
        String textValue;

        if (_previousActiveThumb == _ActiveThumb.lowerThumb){
          thumbCenter = new Offset(_thumbLeftPosition, _trackVerticalCenter);
          value = _lowerValue;
        } else {
          thumbCenter = new Offset(_thumbRightPosition, _trackVerticalCenter);
          value = _upperValue;
        }

        // Adapt the value to be displayed to the max number of decimals
        // as well as convert it to the initial range (min, max)
        value = state.lerp(value);
        textValue = value.toStringAsFixed(_valueIndicatorMaxDecimals);

        // Adapt the value indicator with the active thumb value
        _valueIndicatorPainter
          ..text = new TextSpan(
            style: _sliderTheme.valueIndicatorTextStyle,
            text: textValue,
          )
          ..layout();

        // Ask the SliderTheme to paint the valueIndicator
        _sliderTheme.valueIndicatorShape.paint(
          context,
          thumbCenter,
          activationAnimation: _valueIndicatorAnimation,
          enableAnimation: _enableAnimation,
          isDiscrete: (_divisions != null),
          labelPainter: _valueIndicatorPainter,
          parentBox: this,
          sliderTheme: _sliderTheme,
          value: value,
        );
      }
    }
  }

  /// ---------------------------------------------
  /// Drag related routines
  /// ---------------------------------------------
  double _currentDragValue = 0.0;
  double _minDragValue;
  double _maxDragValue;

    /// -------------------------------------------
    /// When we start dragging, we need to 
    /// memorize the initial position of the 
    /// pointer, relative to the track.
    /// -------------------------------------------
  void _handleDragStart(DragStartDetails details){
    _currentDragValue = _getValueFromGlobalPosition(details.globalPosition);

    // As we are starting to drag, let's invoke the corresponding callback
    _onChangeStart(_lowerValue, _upperValue);

    // Show the overlay
    state.overlayController.forward();

    // Show the value indicator
    if (showValueIndicator){
      state.valueIndicatorController.forward();
    }
  }

    /// -------------------------------------------
    /// When we are dragging, we need to 
    /// consider the delta between the initial
    /// pointer position and the current and
    /// compute the new position of the thumb.
    /// Then, we call the handler of a value change
    /// -------------------------------------------
  void _handleDragUpdate(DragUpdateDetails details){
    final double valueDelta = details.primaryDelta / _trackLength;
    _currentDragValue += valueDelta;

    // we need to limit the movement to the track
    _onRangeChanged(_currentDragValue.clamp(_minDragValue, _maxDragValue));
  }

    /// -------------------------------------------
    /// End or Cancellation of the drag
    /// -------------------------------------------
  void _handleDragEnd(DragEndDetails details){
    _handleDragCancel();
  }
  void _handleDragCancel(){
    _previousActiveThumb = _activeThumb;
    _activeThumb = _ActiveThumb.none;
    _currentDragValue = 0.0;

    // As we have finished with the drag, let's invoke 
    // the appropriate callback
    _onChangeEnd(_lowerValue, _upperValue);

    // Hide the overlay
    state.overlayController.reverse();

    // Hide the value indicator
    if (showValueIndicator){
      state.valueIndicatorController.reverse();
    }
  }

  /// ----------------------------------------------
  /// Handling of a change in the Range selection
  /// ----------------------------------------------
  void _onRangeChanged(double value){

    // If there are divisions, we need to stick to one
    value = _discretize(value);

    if (_activeThumb == _ActiveThumb.lowerThumb){
      _lowerValue = value;
    } else {
      _upperValue = value;
    }

    // Invoke the appropriate callback during the drag
    _onChanged(_lowerValue, _upperValue);

    // Force a repaint
    markNeedsPaint();
  }

  /// ----------------------------------------------
  /// If there are divisions, values should be
  /// aligned to divisions
  /// ----------------------------------------------
  double _discretize(double value) {
    if (_divisions != null) {
      value = (value * _divisions).round() / _divisions;
    }
    return value;
  }

  /// ----------------------------------------------
  /// Position helper.
  /// Translates the Pointer global position to
  /// a percentage of the track length
  /// ----------------------------------------------
  double _getValueFromGlobalPosition(Offset globalPosition){
    final double visualPosition = (globalToLocal(globalPosition).dx - _overlayDiameter) / _trackLength;

    return visualPosition;
  }

  /// ----------------------------------------------
  /// Event Handling
  /// We need to validate that the pointer hits
  /// a thumb before accepting to initiate a Drag.
  /// ----------------------------------------------
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry){
    if (event is PointerDownEvent && isInteractive){
      _validateActiveThumb(event.position);

      // If a thumb is active, initiates the GestureDrag
      if (_activeThumb != _ActiveThumb.none){
        _drag.addPointer(event);
      }
    }
  }

  /// ----------------------------------------------
  /// Determine whether the user presses a thumb
  /// If yes, activate the thumb
  /// ----------------------------------------------
  _ActiveThumb _activeThumb = _ActiveThumb.none;
  _ActiveThumb _previousActiveThumb = _ActiveThumb.none;

  _validateActiveThumb(Offset position){
    if (_thumbLowerRect.contains(position)){
      _activeThumb = _ActiveThumb.lowerThumb;
      _minDragValue = 0.0;
      _maxDragValue = _discretize(_upperValue - _thumbRadius * 2.0 / _trackLength);
    } else if (_thumbUpperRect.contains(position)){
      _activeThumb = _ActiveThumb.upperThumb;
      _minDragValue = _discretize(_lowerValue + _thumbRadius * 2.0 / _trackLength);
      _maxDragValue = 1.0;
    } else {
      _activeThumb = _ActiveThumb.none;
    }
    _previousActiveThumb = _activeThumb;
  }
}

enum _ActiveThumb {
  // no thumb is currently active
  none,
  // the lowerThumb is active
  lowerThumb,
  // the upperThumb is active
  upperThumb,
} 