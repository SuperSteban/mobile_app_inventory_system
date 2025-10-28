import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

class ProductEditScreen extends StatefulWidget {
  final Product product;

  const ProductEditScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _codeProductController;

  late String _selectedCategory;
  late String _selectedStorageLocation;
  late String _selectedUnit;
  File? _selectedImage;

  final List<String> unitOptions = ['kg', 'pieza', 'caja', 'LTS', 'gr'];
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
    final p = widget.product;

    _nameController = TextEditingController(text: p.name);
    _priceController = TextEditingController(text: p.price.toString());
    _stockController = TextEditingController(text: p.stock.toString());
    _minStockController = TextEditingController(text: p.minStock.toString());
    _codeProductController = TextEditingController(text: p.codeProduct);

    _selectedUnit = unitOptions.contains(p.unit) ? p.unit : 'pieza';
    _selectedStorageLocation =
        (p.storageLocation != null &&
            storageOptions.contains(p.storageLocation!))
        ? p.storageLocation!
        : 'ABARROTES';
    _selectedCategory = categoryOptions.contains(p.category)
        ? p.category
        : 'general';

    super.initState();
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

  Future<void> _updateProduct() async {
    final updated = widget.product.copyWith(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      stock: double.tryParse(_stockController.text.trim()) ?? 0,
      minStock: double.tryParse(_minStockController.text.trim()) ?? 0,
      codeProduct: _codeProductController.text.trim(),
      category: _selectedCategory,
      storageLocation: _selectedStorageLocation,
      unit: _selectedUnit,
      img: _selectedImage?.path ?? widget.product.img,
      updatedAt: DateTime.now(),
    );

    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).createProduct(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Producto'),
        backgroundColor: const Color.fromARGB(255, 227, 113, 202),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                  value: storageOptions.contains(_selectedStorageLocation)
                      ? _selectedStorageLocation
                      : 'ABARROTES',
                  decoration: const InputDecoration(
                    labelText: 'Ubicación de almacenamiento',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: storageOptions
                      .map(
                        (loc) => DropdownMenuItem(value: loc, child: Text(loc)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedStorageLocation = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: unitOptions.contains(_selectedUnit)
                      ? _selectedUnit
                      : 'pieza',
                  decoration: const InputDecoration(
                    labelText: 'Unidad de medida',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                  ),
                  items: unitOptions
                      .map(
                        (unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedUnit = value!),
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
                  value: categoryOptions.contains(_selectedCategory)
                      ? _selectedCategory
                      : 'general',
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: categoryOptions
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Cambiar imagen'),
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
                    onPressed: _updateProduct,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
