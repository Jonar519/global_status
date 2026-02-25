import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final List<NewOrderItem> _items = [];

  // Controladores para nuevo item
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemPriceController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  void _addItem() {
    // Validar campos del item
    if (_itemNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese el nombre del producto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_itemQuantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese la cantidad',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_itemPriceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese el precio',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar que cantidad sea número válido
    int? quantity = int.tryParse(_itemQuantityController.text);
    if (quantity == null || quantity <= 0) {
      Get.snackbar(
        'Error',
        'La cantidad debe ser un número positivo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar que precio sea número válido
    double? price = double.tryParse(_itemPriceController.text);
    if (price == null || price <= 0) {
      Get.snackbar(
        'Error',
        'El precio debe ser un número positivo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _items.add(NewOrderItem(
        name: _itemNameController.text,
        quantity: quantity,
        price: price,
      ));
    });

    // Limpiar campos
    _itemNameController.clear();
    _itemQuantityController.clear();
    _itemPriceController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _createOrder() {
    // Validar nombre del cliente
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

    // Validar que haya al menos un item
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
                price: item.price,
              ))
          .toList(),
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      total: _totalAmount,
    );

    widget.onOrderCreated(newOrder);
    Get.back();
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

                    // Sección para agregar items
                    const Text(
                      'Agregar Productos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Formulario de items
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _itemNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Producto',
                                      border: OutlineInputBorder(),
                                      hintText: 'Ej: Café',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _itemQuantityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Cant',
                                      border: OutlineInputBorder(),
                                      hintText: '1',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _itemPriceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Precio',
                                      border: OutlineInputBorder(),
                                      hintText: '2.50',
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar Producto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                                  '\$${item.price.toStringAsFixed(2)} c/u'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
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
                              'TOTAL DEL PEDIDO:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_totalAmount.toStringAsFixed(2)}',
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

// Modelo para items del nuevo pedido
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
