import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'product_chart.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double currentValue = 148.0;
  double maxValue = 400.0;
  double minValue = 0.0;

  void changeCurrentValue(double newValue) {
    setState(() {
      currentValue = newValue;      
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Flexible(
            flex: 2,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Slider(
                  min: this.minValue,
                  max: this.maxValue,
                  value: this.currentValue,
                  onChanged: (double value) {
                    changeCurrentValue(value);
                  },
                ),
              ],
            ),
          ),
          new Flexible(
            flex: 1,
            child: new Container(
              height: 400.0,
              margin: const EdgeInsets.only(bottom: 40.0),
              width: double.infinity,
              child: new CustomPaint(
                painter: ProductsChart(
                  initialValue: this.currentValue.toInt(),
                  gradientColors: [
                    Color.fromARGB(255, 237, 49, 37),
                    Color.fromARGB(255, 251, 175, 64),
                  ],  
                  labelColor: Color.fromARGB(255, 116, 116, 118),
                  maxValue: this.maxValue.toInt(),
                  minValue: this.minValue.toInt(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}