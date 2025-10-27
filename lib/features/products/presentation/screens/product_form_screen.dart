import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'general';

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  void _submitProduct() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa nombre y precio válidos'),
        ),
      );
      return;
    }

    final product = Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      img: null, // Imagen nula por ahora
    );

    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).addProduct(product);

    _nameController.clear();
    _priceController.clear();
    setState(() => _selectedCategory = 'general');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (provider.error != null)
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                    ),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: ['general', 'abarrotes', 'carnes', 'pollo', 'pan']
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitProduct,
                    child: const Text('Agregar producto'),
                  ),
                  const Divider(),
                  Expanded(
                    child: provider.products.isEmpty
                        ? const Center(
                            child: Text('No hay productos registrados'),
                          )
                        : ListView.builder(
                            itemCount: provider.products.length,
                            itemBuilder: (_, index) {
                              final product = provider.products[index];
                              return ListTile(
                                title: Text(product.name),
                                subtitle: Text(
                                  '${product.category} - \$${product.price.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  product.createdAt.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
