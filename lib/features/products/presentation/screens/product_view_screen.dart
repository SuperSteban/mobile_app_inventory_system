import 'package:flutter/material.dart';
import 'package:mobile_app_inventory_system/features/products/presentation/screens/product_edit_screen.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class ProductViewScreen extends StatefulWidget {
  const ProductViewScreen({Key? key}) : super(key: key);

  @override
  State<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends State<ProductViewScreen> {
  String? selectedStorage;
  String? selectedCategory;

  final List<String> storageOptions = [
    'ABARROTES',
    'CUARTO FRÍO',
    'NO PERECEDEROS',
  ];
  final List<String> categoryOptions = [
    'general',
    'abarrotes',
    'carnes',
    'pollo',
    'pan',
  ];

  void _applyFilters(ProductProvider provider) {
    provider.filterProducts(
      storage: selectedStorage,
      category: selectedCategory,
    );
  }

  Future<void> _confirmDelete(
    ProductProvider provider,
    String productId,
    String productName,
  ) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¿Eliminar producto?'),
            content: Text(
              '¿Deseas eliminar "$productName"? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await provider.deleteProduct(productId);
      await provider.fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: const Color.fromARGB(255, 227, 113, 202),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: selectedStorage,
                          decoration: const InputDecoration(
                            labelText: 'Almacén',
                            border: OutlineInputBorder(),
                          ),
                          items: [null, ...storageOptions]
                              .map(
                                (loc) => DropdownMenuItem<String?>(
                                  value: loc,
                                  child: Text(loc ?? 'Todos'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedStorage = value);
                            _applyFilters(provider);
                          },
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: [null, ...categoryOptions]
                              .map(
                                (cat) => DropdownMenuItem<String?>(
                                  value: cat,
                                  child: Text(cat ?? 'Todas'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedCategory = value);
                            _applyFilters(provider);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchProducts();
                      _applyFilters(provider);
                    },
                    child: provider.products.isEmpty
                        ? const Center(
                            child: Text('No hay productos registrados'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            itemCount: provider.products.length,
                            itemBuilder: (_, index) {
                              final product = provider.products[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.label,
                                              color: Colors.teal,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                if (product.isOutOfStock)
                                                  const Chip(
                                                    label: Text('Agotado'),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    labelStyle: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                if (!product.isOutOfStock &&
                                                    product.isLowStock)
                                                  const Chip(
                                                    label: Text('Stock bajo'),
                                                    backgroundColor:
                                                        Colors.orangeAccent,
                                                    labelStyle: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.category,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Categoría: ${product.category}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Ubicación: ${product.storageLocation ?? 'Sin ubicación'}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.inventory_2,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Stock: ${product.stock} ${product.unit}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.attach_money,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Precio: \$${product.price.toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.qr_code, size: 20),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Código: ${product.codeProduct}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Creado: ${product.createdAt.toLocal().toString().split(' ')[0]}',
                                            ),
                                          ],
                                        ),

                                        if (product.img?.isNotEmpty == true)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                product.img!,
                                                // ya no es null por la condición de arriba
                                                height: 150,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                    ),
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ProductEditScreen(
                                                          product: product,
                                                        ),
                                                  ),
                                                ).then(
                                                  (_) =>
                                                      provider.fetchProducts(),
                                                );
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: const Text('Actualizar'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              onPressed: () => _confirmDelete(
                                                provider,
                                                product.id,
                                                product.name,
                                              ),
                                              icon: const Icon(
                                                Icons.delete_forever,
                                              ),
                                              label: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
