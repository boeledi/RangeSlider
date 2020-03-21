# RangeSlider

An extension of the Flutter Material Slider to allow selection of a range of values via 2 thumbs.

<img src="https://www.didierboelens.com/images/blog/range_slider.gif" width="220" alt="Flutter RangeSlider" />
<br/><br/>

---
## Step by step explanation

A full explanation on how to build such Widget may be found on my blog:

* in English, click [here](https://www.didierboelens.com/2018/07/range-slider/)
* in French, click [here](https://www.didierboelens.com/fr/2018/07/range-slider/)

---
## Getting Started

You should ensure that you add the following dependency in your Flutter project.
```yaml
dependencies:
 flutter_range_slider: "^1.4.0"
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

In your Dart code, to use it:
```dart
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
```

> **IMPORTANT NOTE**
<br/>
> As of version 1.7, Flutter Framework also has its own RangeSlider.
> If you want to keep working with this library, you need to import the package, using an alias e.g. frs.
> Then, your need to prefix both RangeSlider and RangeSliderCallback with this alias (frs.RangeSlider and frs.RangeSliderCallback)

---
## Example

An example can be found in the `example` folder.  Check it out.

