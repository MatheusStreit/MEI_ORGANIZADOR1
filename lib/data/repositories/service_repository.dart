import '../../services/notifications_service.dart';
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
    int id;

    if (isEdit) {
      // ✅ evita crash com s.id!
      if (s.id == null) {
        throw StateError('ServiceRepository.save: isEdit=true mas s.id é null');
      }
      await _dao.update(s);
      id = s.id!;
    } else {
      id = await _dao.insert(s);

      // ✅ valida retorno do insert
      if (id <= 0) {
        throw StateError('ServiceRepository.save: insert retornou id inválido: $id');
      }
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


    // ✅ garante que cancelar/agendar nunca use id nulo
    if (saved.remindDelivery) {
      await _notifications.scheduleServiceReminder(saved);
    } else {
      await _notifications.cancelServiceReminder(id);
    }

    return id;
  }

  Future<void> delete(Service s) async {
    final id = s.id;
    if (id == null) return;

    await _dao.delete(id);
    await _notifications.cancelServiceReminder(id);
  }
}
