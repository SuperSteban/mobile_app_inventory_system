import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductViewScreen extends StatelessWidget {
  const ProductViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Productos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchProducts(),
              child: provider.products.isEmpty
                  ? const Center(child: Text('No hay productos registrados'))
                  : ListView.builder(
                      itemCount: provider.products.length,
                      itemBuilder: (_, index) {
                        final product = provider.products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.category} - \$${product.price.toStringAsFixed(2)}',
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                product.createdAt.toLocal().toString().split(
                                  ' ',
                                )[0],
                              ),
                              if (product.isOutOfStock)
                                const Text(
                                  'Agotado',
                                  style: TextStyle(color: Colors.red),
                                ),
                              if (!product.isOutOfStock && product.isLowStock)
                                const Text(
                                  'Stock bajo',
                                  style: TextStyle(color: Colors.orange),
                                ),
                            ],
                          ),
                          onTap: () {
                            // Aquí luego puedes navegar a ProductDetailScreen
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
