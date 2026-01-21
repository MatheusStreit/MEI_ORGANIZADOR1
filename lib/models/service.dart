class Service {
  final int? id;
  final int clientId;

  final String title;
  final String details;

  final double value;
  final DateTime date;

  final DateTime deliveryDate;
  final bool remindDelivery;
  final int remindDaysBefore;

  Service({
    this.id,
    required this.clientId,
    required this.title,
    required this.details,
    required this.value,
    required this.date,
    required this.deliveryDate,
    required this.remindDelivery,
    required this.remindDaysBefore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'title': title,
      'details': details,
      'value': value,
      'date': date.millisecondsSinceEpoch,
      'delivery_date': deliveryDate.millisecondsSinceEpoch,
      'remind_delivery': remindDelivery ? 1 : 0,
      'remind_days_before': remindDaysBefore,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int?,
      clientId: map['client_id'] as int,
      title: map['title'] as String,
      details: (map['details'] as String?) ?? '',
      value: (map['value'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      deliveryDate: DateTime.fromMillisecondsSinceEpoch(map['delivery_date'] as int),
      remindDelivery: (map['remind_delivery'] as int) == 1,
      remindDaysBefore: map['remind_days_before'] as int,
    );
  }
}
