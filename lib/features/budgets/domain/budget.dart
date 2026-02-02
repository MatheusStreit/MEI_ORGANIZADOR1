class Budget {
  final int? id;
  final int clientId;
  final DateTime createdAt;
  final DateTime? validUntil;
  final String notes;
  final double? discount;
  final String status; // rascunho | enviado | aprovado | recusado

  Budget({
    this.id,
    required this.clientId,
    required this.createdAt,
    this.validUntil,
    this.notes = '',
    this.discount,
    this.status = 'rascunho',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'client_id': clientId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'valid_until': validUntil?.millisecondsSinceEpoch,
        'notes': notes,
        'discount': discount,
        'status': status,
      };

  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
        id: m['id'] as int?,
        clientId: m['client_id'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        validUntil: m['valid_until'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['valid_until'] as int),
        notes: (m['notes'] as String?) ?? '',
        discount: (m['discount'] as num?)?.toDouble(),
        status: (m['status'] as String?) ?? 'rascunho',
      );
}
