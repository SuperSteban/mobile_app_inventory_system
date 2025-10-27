import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductViewScreen extends StatelessWidget {
  const ProductViewScreen({Key? key}) : super(key: key);

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
          : RefreshIndicator(
              onRefresh: () => provider.fetchProducts(),
              child: provider.products.isEmpty
                  ? const Center(child: Text('No hay productos registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: provider.products.length,
                      itemBuilder: (_, index) {
                        final product = provider.products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              backgroundColor: Colors.redAccent,
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
                                      const Icon(Icons.category, size: 20),
                                      const SizedBox(width: 6),
                                      Text('Categoría: ${product.category}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ubicación: ${product.storageLocation ?? 'Sin ubicación'}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory_2, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Stock: ${product.stock} ${product.unit}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 20),
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
                                      Text('Código: ${product.codeProduct}'),
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
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        // Navegar a ProductDetailScreen (próximo paso)
                                      },
                                      icon: const Icon(Icons.info_outline),
                                      label: const Text('Ver detalles'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
