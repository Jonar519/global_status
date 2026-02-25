import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import 'widgets/order_card.dart';
import 'widgets/status_filter.dart';
import 'widgets/new_order_dialog.dart';

class HomePage extends StatelessWidget {
  late final OrderController controller;

  HomePage({super.key}) {
    // Inicializar el controlador de manera segura
    try {
      controller = Get.find<OrderController>();
    } catch (e) {
      controller = Get.put(OrderController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos - Cafetería'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Activos: ${controller.activeOrders}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre del cliente...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => controller.searchOrders(value),
              ),
            ),
          ),

          // Filtros de estado
          const StatusFilter(),

          // Estadísticas rápidas
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Pendientes',
                      controller.pendingOrders.length.toString(),
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Preparando',
                      controller.preparingOrders.length.toString(),
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Listos',
                      controller.readyOrders.length.toString(),
                      Colors.green,
                    ),
                  ],
                ),
              )),

          // Lista de pedidos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                  ),
                );
              }

              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay pedidos ${_getStatusName(controller.filterStatus.value)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cambia el filtro o agrega un nuevo pedido',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshOrders,
                color: Colors.brown,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return OrderCard(
                      order: order,
                      onStatusChanged: (newStatus) {
                        controller.updateOrderStatus(order.id, newStatus);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOrderDialog,
        label: const Text('Nuevo Pedido'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pendientes';
      case OrderStatus.preparing:
        return 'en preparación';
      case OrderStatus.ready:
        return 'listos';
      case OrderStatus.delivered:
        return 'entregados';
      case OrderStatus.cancelled:
        return 'cancelados';
    }
  }

  Future<void> _refreshOrders() async {
    controller.loadMockOrders();
  }

  void _showAddOrderDialog() {
    Get.dialog(
      NewOrderDialog(
        onOrderCreated: (newOrder) {
          controller.addOrder(newOrder);
        },
      ),
      barrierDismissible: false, // No permite cerrar tocando fuera
    );
  }
}
