import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import 'product_view_screen.dart';

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
  final _codeProductController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedStorageLocation = 'ABARROTES';
  String _selectedUnit = 'pieza';
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
    final codeProduct = _codeProductController.text.trim();

    if (name.isEmpty ||
        price <= 0 ||
        codeProduct.isEmpty ||
        _selectedUnit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios')),
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
      storageLocation: _selectedStorageLocation,
      codeProduct: codeProduct,
      createdAt: DateTime.now(),
      updatedAt: null,
      unit: _selectedUnit,
    );

    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).createProduct(product);

    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _minStockController.clear();
    _codeProductController.clear();

    setState(() {
      _selectedCategory = 'general';
      _selectedStorageLocation = 'ABARROTES';
      _selectedUnit = 'pieza';
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: const Color.fromARGB(255, 227, 113, 202),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (provider.error != null)
                            Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto',
                              prefixIcon: Icon(Icons.label),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock',
                              prefixIcon: Icon(Icons.inventory),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock mínimo',
                              prefixIcon: Icon(Icons.warning),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedStorageLocation,
                            decoration: const InputDecoration(
                              labelText: 'Ubicación de almacenamiento',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                            items:
                                ['ABARROTES', 'CUARTO FRÍO', 'NO PERECEDEROS']
                                    .map(
                                      (loc) => DropdownMenuItem(
                                        value: loc,
                                        child: Text(loc),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(
                                  () => _selectedStorageLocation = value,
                                );
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unidad de medida',
                              prefixIcon: Icon(Icons.straighten),
                              border: OutlineInputBorder(),
                            ),
                            items: ['kg', 'pieza', 'caja', 'LTS', 'gr']
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedUnit = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _codeProductController,
                            decoration: const InputDecoration(
                              labelText: 'Código de barras',
                              prefixIcon: Icon(Icons.qr_code),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            items:
                                [
                                      'general',
                                      'abarrotes',
                                      'carnes',
                                      'pollo',
                                      'pan',
                                    ]
                                    .map(
                                      (cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedCategory = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Seleccionar imagen'),
                          ),
                          if (_selectedImage != null)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitProduct,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar producto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  220,
                                  90,
                                  222,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductViewScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.storage),
                              label: const Text('PRODUCTOS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  186,
                                  64,
                                  176,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
