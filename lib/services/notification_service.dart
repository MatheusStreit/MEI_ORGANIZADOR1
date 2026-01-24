import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/services/domain/service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;

    // Timezone (evita notificar em horário errado)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    // Android 13+ runtime permission
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _inited = true;
  }

  int _notifIdForService(int serviceId) => 100000 + serviceId;

  Future<void> scheduleServiceReminder(Service s) async {
    if (s.id == null) return;
    if (!s.remindDelivery) return;

    await init();

    // Agenda para 09:00 no dia do lembrete (evita 00:00)
    final base = s.deliveryDate.subtract(Duration(days: s.remindDaysBefore));
    final scheduled = DateTime(base.year, base.month, base.day, 9, 0);

    // Se já passou, não agenda.
    if (scheduled.isBefore(DateTime.now())) {
      await cancelServiceReminder(s.id!);
      return;
    }

    final when = tz.TZDateTime.from(scheduled, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'delivery_reminders',
        'Lembretes de entrega',
        channelDescription: 'Notificações para lembrar prazos de entrega',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      _notifIdForService(s.id!),
      'Entrega: ${s.title}',
      'Faltam ${s.remindDaysBefore} dia(s) para a entrega',
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelServiceReminder(int serviceId) async {
    await init();
    await _plugin.cancel(_notifIdForService(serviceId));
  }
}
