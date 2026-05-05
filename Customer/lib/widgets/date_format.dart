import 'package:intl/intl.dart';

String formatDateTime(String iso) {
  final dt = DateTime.parse(iso).toLocal(); // حوّله للتوقيت المحلّي
  return DateFormat('HH:mm').format(dt); // 24-ساعة
  // أو: return DateFormat('hh:mm a').format(dt);  // 12-ساعة مع AM/PM
}
