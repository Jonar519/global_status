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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.index,
      'total': total,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customerName'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      status: OrderStatus.values[json['status']],
      total: json['total'].toDouble(),
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}

class NewOrderItem {
  String name;
  int quantity;
  double price;

  NewOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
