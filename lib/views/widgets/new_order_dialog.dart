import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../constants/product_catalog.dart';
import '../../controllers/order_controller.dart'; // 👈 IMPORTANTE: Agregar este import
import 'product_selector.dart';

class NewOrderDialog extends StatefulWidget {
  final Function(OrderModel) onOrderCreated;

  const NewOrderDialog({
    super.key,
    required this.onOrderCreated,
  });

  @override
  State<NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<NewOrderDialog> {
  final _customerController = TextEditingController();
  final List<NewOrderItem> _items = [];

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _showProductSelector() {
    Get.dialog(
      ProductSelector(
        onProductSelected: (product, quantity) {
          setState(() {
            _items.add(NewOrderItem(
              productId: product['id'],
              name: product['name'],
              quantity: quantity,
              unitPrice: product['price'],
            ));
          });

          Get.back(); // Cerrar el selector de productos

          Get.snackbar(
            'Producto Agregado',
            '${quantity}x ${product['name']} - ${ProductCatalog.formatPrice(product['price'] * quantity)}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
          );
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  int get _totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void _createOrder() {
    if (_customerController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese el nombre del cliente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_items.isEmpty) {
      Get.snackbar(
        'Error',
        'Agregue al menos un producto al pedido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Generar ID único
    final now = DateTime.now();
    final orderId =
        'ORD-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final newOrder = OrderModel(
      id: orderId,
      customerName: _customerController.text,
      items: _items
          .map((item) => OrderItem(
                name: item.name,
                quantity: item.quantity,
                price: item.unitPrice.toDouble(),
                productId: item.productId,
              ))
          .toList(),
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      total: _totalAmount.toDouble(),
    );

    widget.onOrderCreated(newOrder);
    Get.back(); // Cerrar el diálogo

    // Cambiar automáticamente al filtro de pendientes
    final OrderController controller = Get.find<OrderController>();
    controller.setFilter(OrderStatus.pending);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.add_shopping_cart, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  'Nuevo Pedido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del cliente
                    TextFormField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Juan Pérez',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botón para agregar productos
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showProductSelector,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de items agregados
                    if (_items.isNotEmpty) ...[
                      const Text(
                        'Productos del Pedido:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.brown[100],
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                  '${ProductCatalog.formatPrice(item.unitPrice)} c/u'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ProductCatalog.formatPrice(item.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeItem(index),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Total
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ProductCatalog.formatPrice(_totalAmount),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Crear Pedido',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
