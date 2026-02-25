import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../constants/product_catalog.dart'; // Agregar este import

class OrderController extends GetxController {
  // Estado reactivo
  var orders = <OrderModel>[].obs;
  var filterStatus = OrderStatus.pending.obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  // Getters computados
  List<OrderModel> get filteredOrders {
    return orders.where((order) {
      if (filterStatus.value != order.status) return false;

      if (searchQuery.value.isNotEmpty) {
        return order.customerName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }

      return true;
    }).toList();
  }

  List<OrderModel> get pendingOrders =>
      orders.where((o) => o.status == OrderStatus.pending).toList();

  List<OrderModel> get preparingOrders =>
      orders.where((o) => o.status == OrderStatus.preparing).toList();

  List<OrderModel> get readyOrders =>
      orders.where((o) => o.status == OrderStatus.ready).toList();

  int get totalOrders => orders.length;
  int get activeOrders => orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .length;

  @override
  void onInit() {
    super.onInit();
    loadMockOrders();

    ever(orders, (_) {
      update();
    });
  }

  void loadMockOrders() {
    isLoading.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      orders.value = [
        OrderModel(
          id: 'ORD-001',
          customerName: 'Juan Pérez',
          items: [
            OrderItem(name: 'Café Tinto', quantity: 2, price: 2500),
            OrderItem(name: 'Pan de Bono', quantity: 1, price: 1800),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: OrderStatus.pending,
          total: 6800,
        ),
        OrderModel(
          id: 'ORD-002',
          customerName: 'María García',
          items: [
            OrderItem(name: 'Capuchino', quantity: 1, price: 4500),
            OrderItem(name: 'Almojábana', quantity: 2, price: 1800),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
          status: OrderStatus.preparing,
          total: 8100,
        ),
        OrderModel(
          id: 'ORD-003',
          customerName: 'Carlos López',
          items: [
            OrderItem(name: 'Café Frappé', quantity: 1, price: 5800),
            OrderItem(name: 'Brownie', quantity: 1, price: 3800),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          status: OrderStatus.ready,
          total: 9600,
        ),
        OrderModel(
          id: 'ORD-004',
          customerName: 'Ana Martínez',
          items: [
            OrderItem(name: 'Limonada de Coco', quantity: 2, price: 5500),
            OrderItem(name: 'Empanada', quantity: 3, price: 2200),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 18)),
          completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: OrderStatus.delivered,
          total: 17600,
        ),
      ];

      isLoading.value = false;
    });
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = orders[index];

      OrderModel updatedOrder = order.copyWith(
        status: newStatus,
        startedAt: newStatus == OrderStatus.preparing
            ? (order.startedAt ?? DateTime.now())
            : order.startedAt,
        completedAt: newStatus == OrderStatus.delivered ||
                newStatus == OrderStatus.cancelled
            ? DateTime.now()
            : order.completedAt,
      );

      orders[index] = updatedOrder;

      Get.snackbar(
        '✅ Estado Actualizado',
        'Pedido ${order.id} ahora está ${getStatusNameForUI(newStatus)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    }
  }

  void addOrder(OrderModel newOrder) {
    orders.add(newOrder);
    Get.snackbar(
      '✅ Nuevo Pedido',
      'Pedido ${newOrder.id} de ${newOrder.customerName} agregado correctamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void removeOrder(String orderId) {
    orders.removeWhere((order) => order.id == orderId);
  }

  void setFilter(OrderStatus status) {
    filterStatus.value = status;
  }

  void searchOrders(String query) {
    searchQuery.value = query;
  }

  // Método para obtener nombre en español
  String getStatusNameForUI(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  // Método para obtener color según estado
  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
