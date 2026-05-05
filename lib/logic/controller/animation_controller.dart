import 'package:get/get.dart';

class AnimationController extends GetxController {
  final _animationController = AnimationController();

  void reset() => _animationController.reset();

  void forward() => _animationController.forward();

  void reverse() => _animationController.reverse();
}
