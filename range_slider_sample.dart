import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './range_slider.dart';

/// ---------------------------------------------------
/// Helper class aimed at simplifying the way to
/// automate the creation of a series of RangeSliders,
/// based on various parameters
/// 
/// This class is to be used to demonstrate the Widget
/// customization
/// ---------------------------------------------------
class RangeSliderData {
  double min;
  double max;
  double lowerValue;
  double upperValue;
  int divisions;
  bool showValueIndicator;
  int valueIndicatorMaxDecimals;
  bool forceValueIndicator;
  Color overlayColor;
  Color activeTrackColor;
  Color inactiveTrackColor;
  Color thumbColor;
  Color valueIndicatorColor;
  Color activeTickMarkColor;

  static const Color defaultActiveTrackColor = const Color(0xFF0175c2);
  static const Color defaultInactiveTrackColor = const Color(0x3d0175c2);
  static const Color defaultActiveTickMarkColor = const Color(0x8a0175c2);
  static const Color defaultThumbColor = const Color(0xFF0175c2);
  static const Color defaultValueIndicatorColor = const Color(0xFF0175c2);
  static const Color defaultOverlayColor = const Color(0x290175c2);

  RangeSliderData({
    this.min,
    this.max,
    this.lowerValue,
    this.upperValue,
    this.divisions,
    this.showValueIndicator: true,
    this.valueIndicatorMaxDecimals: 1,
    this.forceValueIndicator: false,
    this.overlayColor: defaultOverlayColor,
    this.activeTrackColor: defaultActiveTrackColor,
    this.inactiveTrackColor: defaultInactiveTrackColor,
    this.thumbColor: defaultThumbColor,
    this.valueIndicatorColor: defaultValueIndicatorColor,
    this.activeTickMarkColor: defaultActiveTickMarkColor,
  });

  /// Returns the values in text format, with the number
  /// of decimals, limited to the valueIndicatedMaxDecimals
  /// 
  String get lowerValueText =>
      lowerValue.toStringAsFixed(valueIndicatorMaxDecimals);
  String get upperValueText =>
      upperValue.toStringAsFixed(valueIndicatorMaxDecimals);

  /// Builds a RangeSlider and customizes the theme
  /// based on paramters
  /// 
  Widget build(BuildContext context, RangeSliderCallback callback) {
    return new Container(
      width: double.infinity,
      child: new Row(
        children: <Widget>[
          new Container(
            constraints: new BoxConstraints(
              minWidth: 40.0,
              maxWidth: 40.0,
            ),
            child: new Text(lowerValueText),
          ),
          new Expanded(
            child: new SliderTheme(
              // Customization of the SliderTheme
              data: SliderTheme.of(context).copyWith(
                    overlayColor: overlayColor,
                    activeTickMarkColor: activeTickMarkColor,
                    activeTrackColor: activeTrackColor,
                    inactiveTrackColor: inactiveTrackColor,
                    thumbColor: thumbColor,
                    valueIndicatorColor: valueIndicatorColor,
                    showValueIndicator: showValueIndicator
                        ? ShowValueIndicator.always
                        : ShowValueIndicator.onlyForDiscrete,
                  ),
              child: new RangeSlider(
                min: min,
                max: max,
                lowerValue: lowerValue,
                upperValue: upperValue,
                divisions: divisions,
                showValueIndicator: showValueIndicator,
                valueIndicatorMaxDecimals: valueIndicatorMaxDecimals,
                onChanged: (double lower, double upper) {
                  callback(lower, upper);
                },
              ),
            ),
          ),
          new Container(
            constraints: new BoxConstraints(
              minWidth: 40.0,
              maxWidth: 40.0,
            ),
            child: new Text(upperValueText),
          ),
        ],
      ),
    );
  }
}

class RangeSliderSample extends StatefulWidget {
  @override
  _RangeSliderSampleState createState() => _RangeSliderSampleState();
}

class _RangeSliderSampleState extends State<RangeSliderSample> {
  /// List of RangeSliders to use, together with their parameters
  List<RangeSliderData> rangeSliders = <RangeSliderData>[
    RangeSliderData(min: 0.0, max: 100.0, lowerValue: 10.0, upperValue: 100.0),
    RangeSliderData(
        min: 0.0,
        max: 100.0,
        lowerValue: 25.0,
        upperValue: 75.0,
        divisions: 20,
        overlayColor: Colors.red[100]),
    RangeSliderData(
        min: 0.0,
        max: 100.0,
        lowerValue: 10.0,
        upperValue: 30.0,
        showValueIndicator: false,
        valueIndicatorMaxDecimals: 0),
    RangeSliderData(
        min: 0.0,
        max: 100.0,
        lowerValue: 10.0,
        upperValue: 30.0,
        showValueIndicator: true,
        valueIndicatorMaxDecimals: 0,
        activeTrackColor: Colors.red,
        inactiveTrackColor: Colors.red[50],
        valueIndicatorColor: Colors.green),
    RangeSliderData(
        min: 0.0,
        max: 100.0,
        lowerValue: 25.0,
        upperValue: 75.0,
        divisions: 20,
        thumbColor: Colors.grey,
        valueIndicatorColor: Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    /// Builds the list of RangeSliders
    List<Widget> children = <Widget>[];
    for (int index = 0; index < rangeSliders.length; index++) {
      children.add(rangeSliders[index].build(
        context, 
        (double lower, double upper) {
          setState(() {
            rangeSliders[index].lowerValue = lower;
            rangeSliders[index].upperValue = upper;
          });
        }
      ));
      // Add an extra padding at the bottom of each RangeSlider
      children.add(new SizedBox(height: 8.0));
    }

    return new SafeArea(
      top: false,
      bottom: false,
      child: new Scaffold(
        appBar: new AppBar(title: new Text('RangeSlider Demo')),
        body: new Container(
          padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
          child: new Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
