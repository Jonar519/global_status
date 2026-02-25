import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';

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

    // Worker para actualizar tiempos cada segundo
    ever(orders, (_) {
      update();
    });
  }

  void loadMockOrders() {
    isLoading.value = true;

    // Simular carga de datos
    Future.delayed(const Duration(seconds: 1), () {
      orders.value = [
        OrderModel(
          id: 'ORD-001',
          customerName: 'Juan Pérez',
          items: [
            OrderItem(name: 'Café Americano', quantity: 2, price: 3.5),
            OrderItem(name: 'Croissant', quantity: 1, price: 2.0),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: OrderStatus.pending,
          total: 9.0,
        ),
        OrderModel(
          id: 'ORD-002',
          customerName: 'María García',
          items: [
            OrderItem(name: 'Capuchino', quantity: 1, price: 4.0),
            OrderItem(name: 'Sandwich', quantity: 1, price: 5.5),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
          status: OrderStatus.preparing,
          total: 9.5,
        ),
        OrderModel(
          id: 'ORD-003',
          customerName: 'Carlos López',
          items: [
            OrderItem(name: 'Té Chai', quantity: 1, price: 3.0),
            OrderItem(name: 'Muffin', quantity: 2, price: 2.5),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          status: OrderStatus.ready,
          total: 8.0,
        ),
        OrderModel(
          id: 'ORD-004',
          customerName: 'Ana Martínez',
          items: [
            OrderItem(name: 'Latte', quantity: 1, price: 4.5),
            OrderItem(name: 'Galleta', quantity: 3, price: 1.5),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          startedAt: DateTime.now().subtract(const Duration(minutes: 18)),
          completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: OrderStatus.delivered,
          total: 9.0,
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
        'Estado Actualizado',
        'Pedido ${order.id} ahora está ${_getStatusName(newStatus)}',
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
      '✅ Nuevo Pedido Creado',
      'Pedido ${newOrder.id} de ${newOrder.customerName} agregado exitosamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void setFilter(OrderStatus status) {
    filterStatus.value = status;
  }

  void searchOrders(String query) {
    searchQuery.value = query;
  }

  String _getStatusName(OrderStatus status) {
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
}
