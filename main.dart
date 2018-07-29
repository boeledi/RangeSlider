import 'package:flutter/material.dart';
import './range_slider_sample.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Slider Range Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RangeSliderSample(),
    );
  }
}
