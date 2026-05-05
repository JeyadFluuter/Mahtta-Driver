import 'dart:async';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:biadgo/services/cancel_order_services.dart';
import 'package:biadgo/services/retry_order_services.dart';
import 'package:biadgo/services/order_accepted_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SearchingDriverScreen extends StatefulWidget {
  const SearchingDriverScreen({super.key});

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> with WidgetsBindingObserver {
  static const int _initialSeconds = 60;
  static const int _warningThreshold = 10;
  bool get _accepted => OrderAcceptedServices().latestOid != null;
  bool get _isCurrentRoute => (ModalRoute.of(context)?.isCurrent ?? false);

  int _remainingSeconds = _initialSeconds;
  Timer? _timer;
  bool _isLoading = false;
  bool _isDialogShowing = false;

  /*──────────────────── lifecycle ────────────────────*/
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recalculateTimer();
    }
  }

  /*──────────────────── helpers ────────────────────*/
  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _startTimer() {
    _timer?.cancel();
    
    // إعادة تعيين الثواني يدوياً لضمان البدء من 60 عند الـ Retry
    _remainingSeconds = _initialSeconds;
    setState(() {});
    
    // ثم المزامنة مع وقت البدء (في حال كانت العودة من الخلفية)
    _recalculateTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (_accepted || !_isCurrentRoute) {
        t.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
      
      if (_remainingSeconds <= 0) {
        t.cancel();
        _handleTimeout();
      }
    });
  }

  void _recalculateTimer() {
    final startTime = Get.find<ConfirmOrderController>().searchStartTime.value;
    if (startTime == null) {
      _remainingSeconds = _initialSeconds;
    } else {
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      _remainingSeconds = (_initialSeconds - elapsed).clamp(0, _initialSeconds);
    }
    
    setState(() {});
    
    if (_remainingSeconds <= 0 && _timer?.isActive == true) {
      _timer?.cancel();
      _handleTimeout();
    } else if (_remainingSeconds <= 0 && (_timer == null || !_timer!.isActive)) {
       // إذا دخلنا الشاشة والوقت أصلاً منتهي
       _handleTimeout();
    }
  }

  Future<void> _handleTimeout() async {
    if (!mounted || _accepted || !_isCurrentRoute || _isDialogShowing) return;

    _isDialogShowing = true;
    final orderId = Get.find<ConfirmOrderController>().dataConfirmOrder.value?.orderId;

    // تم إزالة الإلغاء التلقائي بناءً على طلب المستخدم، ليتم الاختيار يدوياً من الدايلوق

    if (!mounted || _accepted || !_isCurrentRoute) {
      _isDialogShowing = false;
      return;
    }

    final res = await showOkCancelAlertDialog(
      context: context,
      title: 'لم يتم العثور على سائق',
      message: 'لم يتم العثور على سائق متاح حالياً.\nهل تود إعادة محاولة البحث أم إلغاء الطلب؟',
      okLabel: 'إعادة المحاولة',
      cancelLabel: 'إلغاء الطلب والعودة',
    );

    if (!mounted || _accepted || !_isCurrentRoute) {
      _isDialogShowing = false;
      return;
    }

    if (res == OkCancelResult.ok) {
      // إعادة المحاولة تعني إنشاء طلب جديد أو إعادة تفعيل الطلب
      if (orderId != null && orderId != 0) {
        setState(() => _isLoading = true);
        try {
          final success = await RetryOrderServices().retryOrder(orderId);
          if (mounted) setState(() => _isLoading = false);

          if (success) {
            Get.find<ConfirmOrderController>().searchStartTime.value = DateTime.now();
            _startTimer();
          } else {
            Get.snackbar(
              'تنبيه',
              'فشلت إعادة المحاولة، يرجى إنشاء طلب جديد',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            Get.find<ConfirmOrderController>().clearSearchSession();
            Get.offAllNamed(AppRoutes.navbar);
          }
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
          Get.offAllNamed(AppRoutes.navbar);
        }
      } else {
        _startTimer();
      }
    } else {
      // إلغاء الطلب يدوياً بناءً على اختيار المستخدم
      if (orderId != null && orderId != 0) {
        setState(() => _isLoading = true);
        await CancelOrderServices().cancelOrder(orderId);
        setState(() => _isLoading = false);
      }
      Get.find<ConfirmOrderController>().clearSearchSession();
      Get.offAllNamed(AppRoutes.navbar);
    }
    
    _isDialogShowing = false;
  }

  /*──────────────────── UI ────────────────────*/
  @override
  Widget build(BuildContext context) {
    final bool isWarning = _remainingSeconds <= _warningThreshold;
    final Color timerColor = isWarning ? Colors.red : Get.theme.primaryColor;

    return WillPopScope(
      onWillPop: () async {
        // إلغاء الطلب عند الضغط على زر الرجوع في الهاتف
        final orderId = Get.find<ConfirmOrderController>()
            .dataConfirmOrder
            .value
            ?.orderId;
        if (orderId != null && orderId != 0) {
          await CancelOrderServices().cancelOrder(orderId);
        }
        Get.find<ConfirmOrderController>().clearSearchSession();
        Get.offAllNamed(AppRoutes.navbar);
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              Lottie.asset(
                'assets/lottie/car.json',
                height: AppDimensions.screenHeight * 0.35,
              ),
              const SizedBox(height: 24),
              const Text(
                'جاري البحث عن سائق الشحن...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              /* العدّاد */
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
              const SizedBox(height: 12),

              /* شريط التقدّم */
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _remainingSeconds / _initialSeconds,
                  strokeWidth: 6,
                  color: timerColor,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
