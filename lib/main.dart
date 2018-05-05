import 'dart:math' as Math;
import 'dart:ui' as UI;

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
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Container(
          color: Colors.white,
          height: 240.0,
          width: 320.0,
          child: new Column(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  children: <Widget>[
                    new Container(
                      margin: const EdgeInsets.all(8.0),
                      child: new Text('200',
                        style: new TextStyle(
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    new Expanded(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Container(
                                margin: const EdgeInsets.only(left: 8.0, right: 14.0),
                                child: new Text('0',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              )
                            ],
                          ),
                          new Expanded(
                            child: new CustomPaint(
                              painter: new ProductsChart(),
                            ),
                          ),
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Container(
                                margin: const EdgeInsets.only(left: 12.0, right: 8.0),
                                child: new Text('400',
                                  style: new TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w800,
                                  )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text('Pedidos',
                    style: new TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsChart extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    // Clip to avoid overflow
    canvas.clipRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));    

    // Current angle
    var angle = (180 * 90.0) / 400.0;

    // Center bottom for all drawing
    var offsetCenterBottom = new Offset(size.width / 2, size.height);

    // Primary circle drawing
    var primaryRadius = size.width * 0.47;
    //var primaryOffset = _getOffset(angle, primaryRadius);
    var primaryRect = Rect.fromCircle(
      center: offsetCenterBottom,
      radius: primaryRadius,
    );
    var primaryPaint = new Paint()
      ..shader = _generateGradient(primaryRadius)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = primaryRadius * 0.1
      ..style = PaintingStyle.stroke;

    canvas.drawArc(primaryRect, Math.pi, Math.pi, false, primaryPaint);

    // Second circle drawing
    var secondRadius = size.width * 0.3;
    //var secondOffset = _getOffset(angle, secondRadius);
    var secondRect = Rect.fromCircle(
      center: offsetCenterBottom,
      radius: secondRadius,
    );
    var secondPaint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.02
      ..style = PaintingStyle.stroke;

    canvas.drawArc(secondRect, Math.pi, Math.pi, false, secondPaint);

    // Filled circle drawing
    var filledRadius = size.width * 0.38;
    //var filledOffset = _getOffset(angle, filledRadius);
    var filledRect = Rect.fromCircle(
      center: offsetCenterBottom,
      radius: filledRadius,
    );
    var filledPaint = new Paint()
      ..shader = _generateGradient(filledRadius)
      ..strokeWidth = size.width * 0.15
      ..style = PaintingStyle.stroke;

    var countedSweepAngle = Math.pi * angle / 180;
    canvas.drawArc(filledRect, Math.pi, countedSweepAngle, false, filledPaint);

    // Translate the canvas to center bottom
    canvas.translate(offsetCenterBottom.dx, offsetCenterBottom.dy);

    // Triangle pointer
    var offsetTriangleTop = _getOffset(angle, primaryRadius - 5);
    var offsetTriangleLeft = _getOffset(angle + 10, secondRadius);
    var offsetTriangleRight = _getOffset(angle - 10, secondRadius);

    var black = new Paint()
      ..color = Colors.black;

    var path = new Path()
      ..moveTo(offsetTriangleTop.dx, offsetTriangleTop.dy)
      ..lineTo(offsetTriangleLeft.dx, offsetTriangleLeft.dy)
      ..lineTo(offsetTriangleRight.dx, offsetTriangleRight.dy)
      ..close();

    canvas.drawPath(path, black);

    // Centered bottom count text
    final UI.ParagraphBuilder paragraphBuilder = new UI.ParagraphBuilder(
      new UI.ParagraphStyle(
        fontSize: 14.0,
        textDirection: UI.TextDirection.ltr
      ),
    )
      ..pushStyle(new UI.TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ))
      ..addText("148")
      ..pop();

    final UI.Paragraph paragraph = paragraphBuilder.build()
      ..layout(new UI.ParagraphConstraints(width: 200.0));

    canvas.drawParagraph(paragraph, offsetCenterBottom);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Offset _getOffset(double angle, double radius) {
    var angleAux = angle + 180.0;
    var radians = Math.pi * angleAux / 180.0;
    var x = radius * Math.cos(radians);
    var y = radius * Math.sin(radians);
    return new Offset(x, y);
  }

  UI.Gradient _generateGradient(double radius) {
    return new UI.Gradient.linear(
      _getOffset(0.0, radius), 
      _getOffset(180.0, radius), 
      [
        Color.fromARGB(255, 237, 37, 36),
        Color.fromARGB(255, 251, 175, 64),
      ],
    );
  }

}