import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';

class ThreeShapedBox extends StatelessWidget {
  const ThreeShapedBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(3, 3), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            // triangle shape of view
            Positioned(
              top: 0,
              left: 0,
              child: SlideInLeft(
                from: 200,
                child: PressableDough(
                  child: ShapeOfView(
                    elevation: 5,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: TriangleShape(
                      percentBottom: 0,
                      percentLeft: 0,
                      percentRight: 0,
                    ),
                    child: Container(
                      width: 200,
                      height: 300,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
            ),
            // create another triangle shape of view of the bottom right
            Positioned(
              bottom: 0,
              right: 0,
              child: SlideInRight(
                from: 200,
                child: PressableDough(
                  child: ShapeOfView(
                    elevation: 5,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: TriangleShape(
                      percentBottom: 1,
                      percentLeft: 1,
                      percentRight: 0,
                    ),
                    child: Container(
                      width: 200,
                      height: 300,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ShapeType { topLeftTriangle, bottomRightTriangle, parallelogram }

class ShadowedShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final ShapeType shape;

  const ShadowedShape({
    required this.width,
    required this.height,
    required this.color,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(width, height),
        painter: CustomShapePainter(shape: shape, color: color),
      ),
    );
  }
}

class CustomShapePainter extends CustomPainter {
  final ShapeType shape;
  final Color color;

  CustomShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path;

    switch (shape) {
      case ShapeType.topLeftTriangle:
        path = Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width, 0)
          ..lineTo(0, 0)
          ..close();
        break;
      case ShapeType.bottomRightTriangle:
        path = Path()
          ..moveTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        break;
      case ShapeType.parallelogram:
        path = Path()
          ..moveTo(0, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, 0)
          ..close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BlackRectangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(BlackRectangle oldDelegate) => false;
}

Widget build(BuildContext context) {
  return CustomPaint(
    size: Size(100, 50),
    painter: BlackRectangle(),
  );
}
