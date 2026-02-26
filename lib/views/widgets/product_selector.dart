import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/product_catalog.dart';

class ProductSelector extends StatefulWidget {
  final Function(Map<String, dynamic> product, int quantity) onProductSelected;

  const ProductSelector({
    super.key,
    required this.onProductSelected,
  });

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  String selectedCategory = ProductCatalog.categories.first;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  'Seleccionar Producto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar este diálogo
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            // Categorías
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ProductCatalog.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }
                      },
                      selectedColor: Colors.brown.withOpacity(0.3),
                      backgroundColor: Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Lista de productos
            Expanded(
              child: ListView.builder(
                itemCount:
                    ProductCatalog.getProductsByCategory(selectedCategory)
                        .length,
                itemBuilder: (context, index) {
                  final product = ProductCatalog.getProductsByCategory(
                      selectedCategory)[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          _showQuantitySelector(product);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _buildProductImage(product['name']),
                ),
              ),
              const SizedBox(width: 12),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ProductCatalog.formatPrice(product['price']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha indicadora
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la imagen del producto
  Widget _buildProductImage(String productName) {
    return const Icon(
      Icons.local_cafe,
      color: Colors.brown,
      size: 30,
    );
  }

  void _showQuantitySelector(Map<String, dynamic> product) {
    int tempQuantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen del producto
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.brown[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _buildProductImage(product['name']),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      ProductCatalog.formatPrice(product['price']),
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selector de cantidad
                    const Text(
                      'Cantidad:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempQuantity > 1) {
                              setState(() {
                                tempQuantity--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle, size: 32),
                          color: Colors.brown,
                        ),
                        Container(
                          width: 60,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$tempQuantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              tempQuantity++;
                            });
                          },
                          icon: const Icon(Icons.add_circle, size: 32),
                          color: Colors.brown,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Subtotal
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ProductCatalog.formatPrice(
                                product['price'] * tempQuantity),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Cerrar selector de cantidad
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onProductSelected(product, tempQuantity);
                              Navigator.of(context)
                                  .pop(); // Cerrar selector de cantidad
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Agregar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
