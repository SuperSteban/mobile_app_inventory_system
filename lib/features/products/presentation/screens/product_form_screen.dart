import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _codeProductController = TextEditingController();

  String _selectedCategory = 'general';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = double.tryParse(_stockController.text.trim()) ?? 0;
    final minStock = double.tryParse(_minStockController.text.trim()) ?? 0;
    final storageLocation = _storageLocationController.text.trim();
    final codeProduct = _codeProductController.text.trim();

    if (name.isEmpty || price <= 0 || codeProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre, precio y código de barras'),
        ),
      );
      return;
    }

    final isDuplicate = await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).isDuplicateCode(codeProduct);

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe un producto con ese código de barras'),
        ),
      );
      return;
    }

    final product = Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: _selectedCategory,
      img: _selectedImage?.path,
      stock: stock,
      minStock: minStock,
      storageLocation: storageLocation.isEmpty ? null : storageLocation,
      codeProduct: codeProduct,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).createProduct(product);

    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _minStockController.clear();
    _storageLocationController.clear();
    _codeProductController.clear();

    setState(() {
      _selectedCategory = 'general';
      _selectedImage = null;
    });
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
                  TextField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock mínimo',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _storageLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación de almacenamiento',
                    ),
                  ),
                  TextField(
                    controller: _codeProductController,
                    decoration: const InputDecoration(
                      labelText: 'Código de barras',
                    ),
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
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar imagen'),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      product.createdAt
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                    ),
                                    if (product.isOutOfStock)
                                      const Text(
                                        'Agotado',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    if (!product.isOutOfStock &&
                                        product.isLowStock)
                                      const Text(
                                        'Stock bajo',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                  ],
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
