import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';

class StatusFilter extends StatelessWidget {
  const StatusFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildFilterChip(
            controller,
            OrderStatus.pending,
            'Pendientes',
            Colors.orange,
          ),
          _buildFilterChip(
            controller,
            OrderStatus.preparing,
            'Preparando',
            Colors.blue,
          ),
          _buildFilterChip(
            controller,
            OrderStatus.ready,
            'Listos',
            Colors.green,
          ),
          _buildFilterChip(
            controller,
            OrderStatus.delivered,
            'Entregados',
            Colors.grey,
          ),
          _buildFilterChip(
            controller,
            OrderStatus.cancelled,
            'Cancelados',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    OrderController controller,
    OrderStatus status,
    String label,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Obx(() => FilterChip(
            label: Text(label),
            selected: controller.filterStatus.value == status,
            onSelected: (selected) {
              if (selected) {
                controller.setFilter(status);
              }
            },
            selectedColor: color.withOpacity(0.3),
            checkmarkColor: color,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: controller.filterStatus.value == status
                  ? color
                  : Colors.black,
              fontWeight: controller.filterStatus.value == status
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          )),
    );
  }
}
