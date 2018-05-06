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

    // Current value and angle
    var totalProducts = 260;
    var maxTotal = totalProducts > 400 ? 400 : totalProducts;
    var angle = (180 * maxTotal) / 400.0;

    // Clip the canvas
    final Rect canvasDimensions = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    //canvas.clipRect(canvasDimensions);

    // Gray Background
    canvas.drawColor(
      Color.fromARGB(255, 228, 228, 228), 
      BlendMode.src,
    );

    // Centered bottom count text
    final ui.ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        fontSize: 26.0,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr
      ),
    )
      ..pushStyle(new ui.TextStyle(
        color: const Color.fromARGB(255, 116, 116, 118),
        fontWeight: FontWeight.w500,
      ))
      ..addText(maxTotal.toString());

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: 80.0));

    var dxParagraph = size.width * 0.5 - (paragraph.width * 0.5);
    var offsetParagraph = new Offset(dxParagraph, size.height * 0.8);
    canvas.drawParagraph(paragraph, offsetParagraph);

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
      ..style = PaintingStyle.fill;

    canvas.drawArc(primaryRect, 0.0, math.pi, false, primaryPaint);

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

    canvas.drawArc(secondRect, math.pi, math.pi, false, secondPaint);

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

    var countedSweepAngle = math.pi * angle / 180;
    canvas.drawArc(filledRect, math.pi, countedSweepAngle, false, filledPaint);

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

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Offset _getOffset(double angle, double radius) {
    var angleAux = angle + 180.0;
    var radians = math.pi * angleAux / 180.0;
    var x = radius * math.cos(radians);
    var y = radius * math.sin(radians);
    return new Offset(x, y);
  }

  /*ui.Gradient _generateGradient(double radius) {
    return new ui.Gradient.radial(
      _getOffset(45.0, radius), 
      radius + 180,
      [
        Color.fromARGB(255, 237, 49, 37),
        Color.fromARGB(255, 251, 175, 64),
      ],
    );
  }*/

  ui.Gradient _generateGradient(double radius) {
    final Offset off0 = _getOffset(-90.0, radius);
    final Offset off180 = _getOffset(-180.0, radius);
    print("From: $off0");
    print("To  : $off180");
    return new ui.Gradient.linear(
      new Offset(0.0, 45.0), 
      off180, 
      [
        Color.fromARGB(255, 237, 49, 37),
        Color.fromARGB(255, 251, 175, 64),
      ],
    );
  }

}