import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ProductsChart extends CustomPainter {
  final int currentValue;
  final List<Color> gradientColors;
  final int initialValue;
  final Color labelColor;
  final ui.TextStyle maxLabelStyle;
  final int maxValue;
  final ui.TextStyle minLabelStyle;
  final int minValue;
  final Offset origin;
  final Color pointerColor;
  final Paint pointerPaint;
  final Color smallerArcColor;
  final Paint smallerArcPaint;
  final ui.TextStyle topLabelStyle;

  ProductsChart(
      {this.gradientColors,
      this.initialValue = 0,
      this.labelColor,
      this.maxValue,
      this.minValue = 0,
      this.pointerColor = Colors.black,
      this.smallerArcColor = Colors.black})
      : assert(minValue >= 0 && maxValue > 0),
        assert(minValue < maxValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(gradientColors != null),
        assert(labelColor != null),
        assert(pointerColor != null),
        assert(smallerArcColor != null),
        currentValue = initialValue > maxValue ? maxValue : initialValue,
        maxLabelStyle = new ui.TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w800,
        ),
        minLabelStyle = new ui.TextStyle(
          color: labelColor,
        ),
        origin = Offset.zero,
        pointerPaint = new Paint()..color = pointerColor,
        smallerArcPaint = new Paint()
          ..color = smallerArcColor
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke,
        topLabelStyle = new ui.TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w500,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Current value and angle
    final double angle = (180 * currentValue) / maxValue;
    final double cx = size.width * 0.5;
    final double cy = size.height;
    final double labelRadius = cx * 0.8;

    // Set the origin to draw
    canvas.translate(cx, cy);

    // Black Arc
    final double blackArcRadius = _drawSmallerArc(cx, canvas);

    // Centered label
    _drawCurrentValueLabel(25.0, blackArcRadius, canvas);

    // Progress Arc
    _drawProgressArc(cx, angle, canvas);

    // Gradient Arc
    final double gradientArcRadius = _drawGradientArc(cx, canvas);

    // Triangle pointer
    _drawTriangleProgressPointer(
        angle, gradientArcRadius, blackArcRadius, canvas);

    // Draw left label
    _drawMinLabel(
      labelRadius,
      canvas,
    );
    _drawTopLabel(
      labelRadius,
      canvas,
    );
    _drawRightLabel(
      labelRadius,
      canvas,
    );
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
      this.gradientColors,
    );
  }

  void _drawCurrentValueLabel(
    double fontSize,
    double blackArcRadius,
    ui.Canvas canvas,
  ) {
    final ui.ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
          fontSize: fontSize,
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr),
    )
      ..pushStyle(new ui.TextStyle(
        color: this.labelColor,
        fontWeight: FontWeight.w500,
      ))
      ..addText(this.currentValue.toString());

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: 80.0));

    if (paragraph.height > blackArcRadius) {
      _drawCurrentValueLabel(fontSize - 5.0, blackArcRadius, canvas);
      return;
    }

    final double dxParagraph = this.origin.dx - paragraph.width * 0.5;
    final double dyParagraph = this.origin.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);
    canvas.drawParagraph(paragraph, offsetParagraph);
  }

  double _drawSmallerArc(double cx, ui.Canvas canvas) {
    final double blackArcRadius = cx * 0.5;
    final Rect blackArcRect = Rect.fromCircle(
      center: this.origin,
      radius: blackArcRadius,
    );

    canvas.drawArc(blackArcRect, math.pi, math.pi, false, this.smallerArcPaint);

    return blackArcRadius;
  }

  double _drawGradientArc(double cx, ui.Canvas canvas) {
    final double gradientArcRadius = cx * 0.7;
    final Rect gradientArcRect = Rect.fromCircle(
      center: this.origin,
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

  void _drawProgressArc(double cx, double angle, ui.Canvas canvas) {
    final double progressArcRadius = cx * 0.6;
    final Rect progressArcRect = Rect.fromCircle(
      center: this.origin,
      radius: progressArcRadius,
    );
    final Paint progressArcPaint = new Paint()
      ..shader = _generateGradient(progressArcRadius)
      ..strokeWidth = cx * 0.19
      ..style = PaintingStyle.stroke;

    final double progressAngle = math.pi * angle / 180;
    canvas.drawArc(
        progressArcRect, math.pi, progressAngle, false, progressArcPaint);
  }

  void _drawTriangleProgressPointer(double angle, double gradientArcRadius,
      double blackArcRadius, ui.Canvas canvas) {
    double rightIncrease = 5.0;
    double leftIncrease = 5.0;

    if (angle > 175.0) {
      rightIncrease = 180.0 - angle;
    } else if (angle < 5.0) {
      leftIncrease = angle;
    }

    final Offset offsetTriangleTop =
        _getOffset(angle, gradientArcRadius - (gradientArcRadius * 0.05));
    final Offset offsetTriangleRight =
        _getOffset(angle + rightIncrease, blackArcRadius);
    final Offset offsetTriangleLeft =
        _getOffset(angle - leftIncrease, blackArcRadius);

    final Path path = new Path()
      ..moveTo(offsetTriangleTop.dx, offsetTriangleTop.dy)
      ..lineTo(offsetTriangleRight.dx, offsetTriangleRight.dy)
      ..lineTo(offsetTriangleLeft.dx, offsetTriangleLeft.dy)
      ..close();

    canvas.drawPath(path, pointerPaint);
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
    final ui.Paragraph paragraph =
        _getParagraph(this.minValue.toString(), this.minLabelStyle);

    final Offset offsetMinLabel = _getOffset(this.origin.dx, labelRadius);

    final double dxParagraph = offsetMinLabel.dx - paragraph.width * 0.6;
    final double dyParagraph = offsetMinLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);
  }

  void _drawTopLabel(double labelRadius, Canvas canvas) {
    final String topLabelText =
        ((this.maxValue + this.minValue) * 0.5).toStringAsFixed(0);
    final ui.Paragraph paragraph =
        _getParagraph(topLabelText, this.topLabelStyle);

    final Offset offsetMinLabel = _getOffset(90.0, labelRadius);

    final double dxParagraph = offsetMinLabel.dx - paragraph.width * 0.5;
    final double dyParagraph = offsetMinLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);
  }

  void _drawRightLabel(double labelRadius, Canvas canvas) {
    final ui.Paragraph paragraph =
        _getParagraph(this.maxValue.toString(), this.maxLabelStyle);

    final Offset offsetMaxLabel = _getOffset(180.0, labelRadius);

    final double dxParagraph = offsetMaxLabel.dx - paragraph.width * 0.2;
    final double dyParagraph = offsetMaxLabel.dy - paragraph.height;
    final Offset offsetParagraph = new Offset(dxParagraph, dyParagraph);

    canvas.drawParagraph(paragraph, offsetParagraph);
  }
}
