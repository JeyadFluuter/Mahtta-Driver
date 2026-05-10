import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import '../../logic/controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ـــ الشعار ـــ
              const _LogoAnimation(),
              const SizedBox(height: 32),
              const _HeadlineWithCurve(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoAnimation extends StatelessWidget {
  const _LogoAnimation();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeIn,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: Image.asset(
        'assets/images/Asset 3.png',
        height: AppDimensions.screenHeight * .18,
      ),
    );
  }
}

class _HeadlineWithCurve extends StatefulWidget {
  const _HeadlineWithCurve();

  @override
  State<_HeadlineWithCurve> createState() => _HeadlineWithCurveState();
}

class _HeadlineWithCurveState extends State<_HeadlineWithCurve>
    with TickerProviderStateMixin {
  late final AnimationController _wordCtrl;
  late final AnimationController _curveCtrl;

  @override
  void initState() {
    super.initState();
    _wordCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _curveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _wordCtrl.addStatusListener((st) {
      if (st == AnimationStatus.completed) _curveCtrl.forward();
    });
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _curveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const txtStyle = TextStyle(
      color: AppThemes.primaryNavy,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    return LayoutBuilder(builder: (ctx, cons) {
      final curveWidth = cons.maxWidth * .6;
      const curveH = 45.0;
      return AnimatedBuilder(
        animation: _wordCtrl,
        builder: (_, __) {
          final v = _wordCtrl.value;
          final w1 = (v.clamp(0.0, .33) * 3);
          final w2 = ((v - .33).clamp(0.0, .33) * 3);
          final w3 = ((v - .66).clamp(0.0, .34) * 2.94);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                      opacity: w3, child: const Text('أسرع', style: txtStyle)),
                  const SizedBox(width: 16),
                  Opacity(
                      opacity: w2, child: const Text('أوفر', style: txtStyle)),
                  const SizedBox(width: 16),
                  Opacity(
                      opacity: w1, child: const Text('أسهل', style: txtStyle)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: curveWidth,
                height: curveH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _curveCtrl,
                      builder: (_, __) => CustomPaint(
                        size: Size(curveWidth, curveH),
                        painter: _SmileCurvePainter(progress: _curveCtrl.value),
                      ),
                    ),
                    const Positioned(
                      right: -8,
                      top: 0,
                      child: Icon(Icons.location_on,
                          color: AppThemes.primaryOrange, size: 22),
                    ),
                    const Positioned(
                      left: -8,
                      top: 0,
                      child: Icon(Icons.location_on,
                          color: AppThemes.primaryOrange, size: 22),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _SmileCurvePainter extends CustomPainter {
  final double progress;
  const _SmileCurvePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppThemes.primaryOrange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width, size.height * .25);
    final end = Offset(0, size.height * .25);
    final control = Offset(size.width / 2, size.height);
    final full = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    final metric = full.computeMetrics().first;
    final pathSegment = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(pathSegment, paint);
  }

  @override
  bool shouldRepaint(covariant _SmileCurvePainter old) =>
      old.progress != progress;
}
