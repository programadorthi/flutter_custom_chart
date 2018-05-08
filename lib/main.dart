import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
                painter: new ProductsChart(
                  backgroundColor: Color.fromARGB(255, 228, 228, 228),
                  currentValue: this.currentValue.toInt(),
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

class ProductsChart extends CustomPainter {

  final Color backgroundColor;
  final int currentValue;
  final Color labelColor;
  final int maxValue;
  final int minValue;

  ProductsChart({
    this.backgroundColor,
    this.currentValue, 
    this.labelColor,
    this.maxValue, 
    this.minValue,
  }) : assert(minValue >= 0),
       assert(maxValue > 0),
       assert(minValue < maxValue),
       assert(currentValue >= minValue),
       assert(currentValue <= maxValue),
       assert(labelColor != null),
       assert(backgroundColor != null);

  @override
  void paint(Canvas canvas, Size size) {

    // Current value and angle
    final int maxTotal       = currentValue > maxValue ? maxValue : currentValue;
    final double angle       = (180 * maxTotal) / maxValue;
    final double cx          = size.width * 0.5;
    final double cy          = size.height;
    final Offset origin      = _getOffset(0.0, 0.0);
    final double labelRadius = cx * 0.8;

    // Set the origin to draw
    canvas.translate(cx, cy);

    // Black Arc
    final double blackArcRadius = _blackArc(cx, origin, canvas);

    // Centered label
    _centeredLabel(maxTotal, 25.0, blackArcRadius, labelColor, origin, canvas);

    // Progress Arc
    _progressArc(cx, origin, angle, canvas);

    // Gradient Arc
    final double gradientArcRadius = _gradientArc(cx, origin, canvas);

    // Triangle pointer
    _progressMarkArc(angle, gradientArcRadius, blackArcRadius, canvas);

    // Draw left label
    _drawMinLabel(labelRadius, canvas,);
    _drawTopLabel(labelRadius, canvas,);
    _drawRightLabel(labelRadius, canvas,);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Offset _getOffset(double angle, double radius) {
    final double radians = math.pi * angle / 180.0;
    final double x = radius * math.cos(radians) * -1;
    final double y = radius * math.sin(radians) * -1;
    return new Offset(x, y);
  }

  ui.Gradient _generateGradient(double radius) {
    return new ui.Gradient.linear(
      _getOffset(0.0, radius),
      _getOffset(180.0, radius),
      [
        Color.fromARGB(255, 237, 49, 37),
        Color.fromARGB(255, 251, 175, 64),
      ],
    );
  }

  void _centeredLabel(
    int value, 
    double fontSize, 
    double blackArcRadius, 
    Color textColor, 
    ui.Offset origin, 
    ui.Canvas canvas,
  ) {

    final ui.ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        fontSize: fontSize,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr
      ),
    )
      ..pushStyle(new ui.TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
      ))
      ..addText(value.toString());
    
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: 80.0));

    if (paragraph.height > blackArcRadius) {
      _centeredLabel(
        value,
        fontSize - 5.0,
        blackArcRadius, 
        textColor, 
        origin, 
        canvas,
      );
      return;
    }
    
    final double dxParagraph = origin.dx - paragraph.width * 0.5;
    final double dyParagraph = origin.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);
    canvas.drawParagraph(paragraph, offsetParagraph);
  }

  double _blackArc(double cx, ui.Offset origin, ui.Canvas canvas) {
    final double blackArcRadius = cx * 0.5;
    final Rect blackArcRect = Rect.fromCircle(
      center: origin,
      radius: blackArcRadius,
    );
    final Paint blackArcPaint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = cx * 0.02
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(blackArcRect, math.pi, math.pi, false, blackArcPaint);

    return blackArcRadius;
  }

  double _gradientArc(double cx, ui.Offset origin, ui.Canvas canvas) {
    final double gradientArcRadius = cx * 0.7;
    final Rect gradientArcRect = Rect.fromCircle(
      center: origin,
      radius: gradientArcRadius,
    );
    final Paint gradientArcPaint = new Paint()
      ..shader = _generateGradient(gradientArcRadius)
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = gradientArcRadius * 0.1
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(gradientArcRect, math.pi, math.pi, false, gradientArcPaint);

    return gradientArcRadius;
  }

  void _progressArc(double cx, ui.Offset origin, double angle, ui.Canvas canvas) {
    final double progressArcRadius = cx * 0.6;
    final Rect progressArcRect = Rect.fromCircle(
      center: origin,
      radius: progressArcRadius,
    );
    final Paint progressArcPaint = new Paint()
      ..shader = _generateGradient(progressArcRadius)
      ..strokeWidth = cx * 0.19
      ..style = PaintingStyle.stroke;
    
    final double progressAngle = math.pi * angle / 180;
    canvas.drawArc(progressArcRect, math.pi, progressAngle, false, progressArcPaint);
  }

  void _progressMarkArc(double angle, double gradientArcRadius, double blackArcRadius, ui.Canvas canvas) {
    double rightIncrease = 5.0;
    double leftIncrease = 5.0;
    
    if (angle > 175) {
      rightIncrease = 180.0 - angle;
    } else if (angle < 5) {
      leftIncrease = angle;
    }
    
    final Offset offsetTriangleTop   = _getOffset(angle, gradientArcRadius - (gradientArcRadius * 0.05));
    final Offset offsetTriangleRight = _getOffset(angle + rightIncrease, blackArcRadius);
    final Offset offsetTriangleLeft  = _getOffset(angle - leftIncrease, blackArcRadius);
    
    final Paint black = new Paint()
      ..color = Colors.black;
    
    final Path path = new Path()
      ..moveTo(offsetTriangleTop.dx, offsetTriangleTop.dy)
      ..lineTo(offsetTriangleRight.dx, offsetTriangleRight.dy)
      ..lineTo(offsetTriangleLeft.dx, offsetTriangleLeft.dy)
      ..close();
    
    canvas.drawPath(path, black);
  }

  ui.Paragraph _getParagraph(String text, ui.TextStyle style) {
    final ui.ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr
      ),
    )
      ..pushStyle(style)
      ..addText(text);
    
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: 40.0));

    return paragraph;
  }

  void _drawMinLabel(double labelRadius, Canvas canvas) {

    final ui.TextStyle minLabelStyle = new ui.TextStyle(
      color: this.labelColor,
    );

    final ui.Paragraph paragraph = _getParagraph(this.minValue.toString(), minLabelStyle);

    final Offset offsetMinLabel = _getOffset(0.0, labelRadius);

    final double dxParagraph = offsetMinLabel.dx - paragraph.width * 0.6;
    final double dyParagraph = offsetMinLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);

  }

  void _drawTopLabel(double labelRadius, Canvas canvas) {

    final ui.TextStyle label200Style = new ui.TextStyle(
      color: this.labelColor,
      fontWeight: FontWeight.w500,
    );

    final String topLabelText = ((this.maxValue + this.minValue) * 0.5).toStringAsFixed(0);
    final ui.Paragraph paragraph = _getParagraph(topLabelText, label200Style);

    final Offset offsetMinLabel = _getOffset(90.0, labelRadius);

    final double dxParagraph = offsetMinLabel.dx - paragraph.width * 0.5;
    final double dyParagraph = offsetMinLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);

  }

  void _drawRightLabel(double labelRadius, Canvas canvas) {

    final ui.TextStyle maxLabelStyle = new ui.TextStyle(
      color: this.labelColor,
      fontWeight: FontWeight.w800,
    );

    final ui.Paragraph paragraph = _getParagraph(this.maxValue.toString(), maxLabelStyle);

    final Offset offsetMaxLabel = _getOffset(180.0, labelRadius);

    final double dxParagraph = offsetMaxLabel.dx - paragraph.width * 0.2;
    final double dyParagraph = offsetMaxLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);

  }

}