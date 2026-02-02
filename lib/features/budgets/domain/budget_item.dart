class BudgetItem {
  final int? id;
  final int budgetId;
  final String description;
  final double quantity;
  final double? unitPrice;
  final int sortOrder;

  BudgetItem({
    this.id,
    required this.budgetId,
    required this.description,
    this.quantity = 1,
    this.unitPrice,
    this.sortOrder = 0,
  });

  double get total => (unitPrice ?? 0) * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'budget_id': budgetId,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'sort_order': sortOrder,
      };

  factory BudgetItem.fromMap(Map<String, dynamic> m) => BudgetItem(
        id: m['id'] as int?,
        budgetId: m['budget_id'] as int,
        description: m['description'] as String,
        quantity: (m['quantity'] as num).toDouble(),
        unitPrice: (m['unit_price'] as num?)?.toDouble(),
        sortOrder: (m['sort_order'] as int?) ?? 0,
      );
}
