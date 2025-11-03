// presentation/screens/product_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider_riverpod.dart';
import 'product_edit_screen.dart';
import 'product_form_screen.dart';

class ProductViewScreen extends ConsumerStatefulWidget {
  const ProductViewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends ConsumerState<ProductViewScreen> {
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

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    ref.read(productProvider.notifier).fetchProducts();
  }

  void _applyFilters() {
    ref.read(productProvider.notifier).filterProducts(
      storage: selectedStorage,
      category: selectedCategory,
    );
  }

  Future<void> _confirmDelete(String productId, String productName) async {
    final confirm = await showDialog<bool>(
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
      await ref.read(productProvider.notifier).deleteProduct(productId);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: const Color.fromARGB(255, 227, 113, 202),
      ),

      // BODY: Column + Expanded
      body: asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(productProvider.notifier).fetchProducts(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (products) => Column(
          children: [
            // FILTROS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: selectedStorage,
                      decoration: const InputDecoration(
                        labelText: 'Almacén',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: [null, ...storageOptions]
                          .map((loc) => DropdownMenuItem<String?>(
                        value: loc,
                        child: Text(loc ?? 'Todos'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedStorage = value);
                        _applyFilters();
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: [null, ...categoryOptions]
                          .map((cat) => DropdownMenuItem<String?>(
                        value: cat,
                        child: Text(cat ?? 'Todas'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedCategory = value);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(productProvider.notifier).fetchProducts();
                  _applyFilters();
                },
                child: products.isEmpty
                    ? const Center(child: Text('No hay productos registrados'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTÓN DE AGREGAR PRODUCTO
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          ).then((_) {
            // Refresca al volver
            ref.read(productProvider.notifier).fetchProducts();
            _applyFilters();
          });
        },
        backgroundColor: const Color.fromARGB(255, 220, 90, 222),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // TARJETA DE PRODUCTO
  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre + Stock Status
              Row(
                children: [
                  const Icon(Icons.label, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.isOutOfStock)
                        const Chip(
                          label: Text('Agotado'),
                          backgroundColor: Colors.redAccent,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      if (!product.isOutOfStock && product.isLowStock)
                        const Chip(
                          label: Text('Stock bajo'),
                          backgroundColor: Colors.orangeAccent,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info Detallada
              _infoRow(Icons.category, 'Categoría: ${product.category}'),
              _infoRow(Icons.location_on, 'Ubicación: ${product.storageLocation ?? 'Sin ubicación'}'),
              _infoRow(Icons.inventory_2, 'Stock: ${product.stock} ${product.unit}'),
              _infoRow(Icons.attach_money, 'Precio: \$${product.price.toStringAsFixed(2)}'),
              _infoRow(Icons.qr_code, 'Código: ${product.codeProduct}'),
              _infoRow(
                Icons.calendar_today,
                'Creado: ${product.createdAt.toLocal().toString().split(' ')[0]}',
              ),

              // Imagen
              if (product.img?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.img!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductEditScreen(product: product)),
                      ).then((_) {
                        ref.read(productProvider.notifier).fetchProducts();
                        _applyFilters();
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Actualizar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _confirmDelete(product.id, product.name),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fila de información
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}