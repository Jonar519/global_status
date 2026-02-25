import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../controllers/order_controller.dart';
import '../../constants/product_catalog.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderStatus) onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm');
    // Obtener controlador para usar sus métodos
    final OrderController controller = Get.find<OrderController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(order.status, controller),
                  ],
                ),
                Text(
                  ProductCatalog.formatPrice(order.total.toInt()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información del cliente
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  order.customerName,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Tiempo - UI en español
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${dateFormat.format(order.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (order.elapsedTime.inMinutes > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTimeColor(order.elapsedTime),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${order.elapsedTime.inMinutes} min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Divisor
            const Divider(),

            const SizedBox(height: 8),

            // Items del pedido - Ahora con formato de moneda colombiana
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.name}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        ProductCatalog.formatPrice(
                            (item.price * item.quantity).toInt()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 12),

            // Botones de acción según estado - Textos en español
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, OrderController controller) {
    final color = controller.getStatusColor(status);
    final label = controller.getStatusNameForUI(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTimeColor(Duration duration) {
    if (duration.inMinutes < 5) return Colors.green;
    if (duration.inMinutes < 10) return Colors.orange;
    return Colors.red;
  }

  List<Widget> _buildActionButtons(OrderController controller) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          _buildActionButton(
            label: '❌ Cancelar',
            color: Colors.red,
            onPressed: () => onStatusChanged(OrderStatus.cancelled),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: '▶️ Iniciar',
            color: Colors.blue,
            onPressed: () => onStatusChanged(OrderStatus.preparing),
          ),
        ];
      case OrderStatus.preparing:
        return [
          _buildActionButton(
            label: '✅ Listo',
            color: Colors.green,
            onPressed: () => onStatusChanged(OrderStatus.ready),
          ),
        ];
      case OrderStatus.ready:
        return [
          _buildActionButton(
            label: '🛒 Entregar',
            color: Colors.green,
            onPressed: () => onStatusChanged(OrderStatus.delivered),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
