enum OrderStatus { pending, preparing, ready, delivered, cancelled }

class OrderModel {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  OrderStatus status;
  final double total;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.items,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.status,
    required this.total,
  });

  Duration get elapsedTime {
    if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
      return Duration.zero;
    }

    final startTime = startedAt ?? createdAt;
    final endTime = DateTime.now();
    return endTime.difference(startTime);
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    OrderStatus? status,
    double? total,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      total: total ?? this.total,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String? productId; // Opcional, para referencia

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.productId,
  });
}

// Modelo actualizado para nuevos pedidos
class NewOrderItem {
  String productId;
  String name;
  int quantity;
  int unitPrice; // Precio en COP (entero)

  NewOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  int get subtotal => quantity * unitPrice;
}
