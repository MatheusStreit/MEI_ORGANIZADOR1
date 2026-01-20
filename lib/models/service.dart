class Service {
  final int? id;
  final int clientId;
  final String description;
  final double value;
  final DateTime date;

  Service({
    this.id,
    required this.clientId,
    required this.description,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'description': description,
      'value': value,
      // salva como INTEGER (timestamp)
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int?,
      clientId: map['client_id'] as int,
      description: map['description'] as String,
      value: (map['value'] as num).toDouble(),
      // converte corretamente de int → DateTime
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
