class ProductCatalog {
  static const List<Map<String, dynamic>> products = [
    // Bebidas Calientes
    {
      'id': '1',
      'name': 'Café Tinto',
      'price': 2500,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '2',
      'name': 'Café con Leche',
      'price': 3500,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '3',
      'name': 'Capuchino',
      'price': 4500,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '4',
      'name': 'Latte',
      'price': 4800,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '5',
      'name': 'Mocaccino',
      'price': 5200,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '6',
      'name': 'Chocolate Caliente',
      'price': 4000,
      'category': 'Bebidas Calientes',
    },
    {
      'id': '7',
      'name': 'Aromática',
      'price': 2200,
      'category': 'Bebidas Calientes',
    },

    // Bebidas Frías
    {
      'id': '8',
      'name': 'Café Frappé',
      'price': 5800,
      'category': 'Bebidas Frías',
    },
    {
      'id': '9',
      'name': 'Granizado de Café',
      'price': 6200,
      'category': 'Bebidas Frías',
    },
    {
      'id': '10',
      'name': 'Limonada de Coco',
      'price': 5500,
      'category': 'Bebidas Frías',
    },
    {
      'id': '11',
      'name': 'Jugo de Lulo',
      'price': 4500,
      'category': 'Bebidas Frías',
    },
    {
      'id': '12',
      'name': 'Jugo de Maracuyá',
      'price': 4500,
      'category': 'Bebidas Frías',
    },

    // Repostería
    {
      'id': '13',
      'name': 'Pan de Bono',
      'price': 1800,
      'category': 'Repostería',
    },
    {
      'id': '14',
      'name': 'Almojábana',
      'price': 1800,
      'category': 'Repostería',
    },
    {
      'id': '15',
      'name': 'Croissant',
      'price': 3200,
      'category': 'Repostería',
    },
    {
      'id': '16',
      'name': 'Brownie',
      'price': 3800,
      'category': 'Repostería',
    },
    {
      'id': '17',
      'name': 'Porción de Torta',
      'price': 4200,
      'category': 'Repostería',
    },
    {
      'id': '18',
      'name': 'Empanada',
      'price': 2200,
      'category': 'Repostería',
    },
    {
      'id': '19',
      'name': 'Pastel de Pollo',
      'price': 3800,
      'category': 'Repostería',
    },

    // Especiales
    {
      'id': '20',
      'name': 'Café Especial (Origen)',
      'price': 6800,
      'category': 'Especiales',
    },
    {
      'id': '21',
      'name': 'Submarino',
      'price': 5500,
      'category': 'Especiales',
    },
    {
      'id': '22',
      'name': 'Carajillo',
      'price': 7200,
      'category': 'Especiales',
    },
  ];

  // Obtener categorías únicas
  static List<String> get categories {
    return products.map((p) => p['category'] as String).toSet().toList();
  }

  // Obtener productos por categoría
  static List<Map<String, dynamic>> getProductsByCategory(String category) {
    return products.where((p) => p['category'] == category).toList();
  }

  // Buscar producto por ID
  static Map<String, dynamic>? getProductById(String id) {
    try {
      return products.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Formatear precio en pesos colombianos
  static String formatPrice(int price) {
    return '\$${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
