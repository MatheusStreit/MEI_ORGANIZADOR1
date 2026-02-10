import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../features/services/domain/service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleServiceReminder(Service service) async {
    // Aqui você implementa depois
  }

  Future<void> cancelServiceReminder(int id) async {
    await _plugin.cancel(id);
  }
}
