import '../../services/notification_service.dart';
import '../../features/services/domain/service.dart';
import '../../features/services/data/service_dao.dart';

class ServiceRepository {
  final ServiceDao _dao;
  final NotificationService _notifications;

  ServiceRepository({
    ServiceDao? dao,
    NotificationService? notifications,
  })  : _dao = dao ?? ServiceDao(),
        _notifications = notifications ?? NotificationService.instance;

  Future<List<Service>> getByClient(int clientId) {
    return _dao.getByClient(clientId);
  }

  Future<int> save(Service s, {required bool isEdit}) async {
    late final int id;

    if (!isEdit) {
      id = await _dao.insert(s);
    } else {
      await _dao.update(s);
      id = s.id!;
    }

    final saved = Service(
      id: id,
      clientId: s.clientId,
      title: s.title,
      details: s.details,
      value: s.value,
      date: s.date,
      deliveryDate: s.deliveryDate,
      remindDelivery: s.remindDelivery,
      remindDaysBefore: s.remindDaysBefore,
    );

    if (saved.remindDelivery) {
      await _notifications.scheduleServiceReminder(saved);
    } else {
      await _notifications.cancelServiceReminder(saved.id!);
    }

    return id;
  }

  Future<void> delete(Service s) async {
    if (s.id == null) return;
    await _dao.delete(s.id!);
    await _notifications.cancelServiceReminder(s.id!);
  }
}
