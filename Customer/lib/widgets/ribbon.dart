import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HorizontalRibbon extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final String text;
  final TextStyle? textStyle;

  const HorizontalRibbon({
    super.key,
    required this.color,
    this.width = 140,
    this.height = 36,
    this.text = "طلبية قيد التنفيذ",
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _RibbonPainter(color),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 28,
                width: 28,
                child: Lottie.asset('assets/lottie/car.json'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final Color color;
  _RibbonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final notch = size.height / 3;
    final radius = Radius.circular(size.height / 2.5);
    path.moveTo(0, 0);
    path.lineTo(size.width - notch, 0);
    path.arcToPoint(
      Offset(size.width - notch, size.height),
      radius: radius,
      clockwise: true,
    );
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => false;
}
