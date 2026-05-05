import 'package:biadgo/models/order_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/constants/app_theme.dart';

class StatusCardAnimated extends StatefulWidget {
  final Status status;
  const StatusCardAnimated({super.key, required this.status});

  @override
  State<StatusCardAnimated> createState() => _StatusCardAnimatedState();
}

class _StatusCardAnimatedState extends State<StatusCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late Animation<double> _ripple;
  late Animation<Color?> _borderColor;

  int _lastId = -1;

  @override
  void initState() {
    super.initState();
    _lastId = widget.status.id;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final curve1 = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    final curve2 = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(curve1);
    _slide = Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero)
        .animate(curve2);

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve2);

    _ripple = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );

    final statusColor = Get.find<MyOrderController>()
        .getStatusColor(widget.status.name, id: widget.status.id);

    _borderColor = ColorTween(
      begin: statusColor.withValues(alpha: 0.7),
      end: statusColor,
    ).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.15, 1.0, curve: Curves.easeOut)),
    );

    _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant StatusCardAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.id != _lastId) {
      _lastId = widget.status.id;
      final statusColor = Get.find<MyOrderController>()
          .getStatusColor(widget.status.name, id: widget.status.id);

      _borderColor = ColorTween(
        begin: statusColor.withValues(alpha: 0.7),
        end: statusColor,
      ).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOut)),
      );
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: (1.0 - _ripple.value).clamp(0.0, 0.8),
                child: Transform.scale(
                  scale: 0.85 + (_ripple.value * 0.6),
                  child: Container(
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Get.theme.primaryColor
                            .withValues(alpha: 0.25 * (1.0 - _ripple.value)),
                        width: 2.0 * (1.0 - _ripple.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Transform.scale(
                  scale: _scale.value,
                  child: _buildCard(
                      borderColor:
                          _borderColor.value ?? Get.theme.primaryColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({required Color borderColor}) {
    final status = widget.status;
    final controller = Get.find<MyOrderController>();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: borderColor.withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحالة مع انتقال سلس
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: borderColor.withOpacity(0.1),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    controller.getStatusIconData(status.name, id: status.id),
                    key: ValueKey('icon-${status.id}'),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    controller.getStatusDescription(status.id, status.description),
                    key: ValueKey('desc-${status.id}'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppThemes.primaryNavy,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    controller.getStatusName(status.id, status.name),
                    key: ValueKey('name-${status.id}'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // مؤشر خطوات بتصميم عصري
                if (status.id <= 6)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (status.id / 6).clamp(0.1, 1.0),
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "خطوة ${status.id} من 6",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
