// presentation/screens/product_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/product.dart';
import '../providers/product_provider_riverpod.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final Product product;
  final bool isNewProduct;

  const ProductEditScreen({
    Key? key,
    required this.product,
    this.isNewProduct = false,
  }) : super(key: key);

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _codeProductController;

  late String _selectedCategory;
  late String _selectedStorageLocation;
  late String _selectedUnit;
  File? _selectedImage;
  bool _isUploading = false;

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
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p.name);
    _priceController = TextEditingController(text: p.price.toStringAsFixed(2));
    _stockController = TextEditingController(text: p.stock.toStringAsFixed(0));
    _minStockController = TextEditingController(text: p.minStock.toStringAsFixed(0));
    _codeProductController = TextEditingController(text: p.codeProduct);

    _selectedUnit = unitOptions.contains(p.unit) ? p.unit : 'pieza';
    _selectedStorageLocation = storageOptions.contains(p.storageLocation)
        ? p.storageLocation!
        : 'ABARROTES';
    _selectedCategory = categoryOptions.contains(p.category)
        ? p.category
        : 'general';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _codeProductController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final ref = FirebaseStorage.instance.ref().child('products/$fileName');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (_isUploading) return;

    final name = _nameController.text.trim();
    final code = _codeProductController.text.trim();
    if (name.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y código son obligatorios')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl = widget.product.img;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
      if (imageUrl == null) {
        setState(() => _isUploading = false);
        return;
      }
    }

    final updatedProduct = widget.product.copyWith(
      name: name,
      price: double.tryParse(_priceController.text) ?? 0.0,
      stock: double.tryParse(_stockController.text) ?? 0.0,
      minStock: double.tryParse(_minStockController.text) ?? 0.0,
      codeProduct: code,
      category: _selectedCategory,
      storageLocation: _selectedStorageLocation,
      unit: _selectedUnit,
      img: imageUrl,
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.isNewProduct) {
        await ref.read(productProvider.notifier).createProduct(updatedProduct);
      } else {
        await ref.read(productProvider.notifier).updateProduct(updatedProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isNewProduct
                ? 'Producto creado exitosamente'
                : 'Producto actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewProduct ? 'Nuevo Producto' : 'Actualizar Producto'),
        backgroundColor: const Color.fromARGB(255, 227, 113, 202),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // === Nombre ===
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // === Precio ===
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),

                // === Stock ===
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

                // === Stock mínimo ===
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

                // === Almacén ===
                DropdownButtonFormField<String>(
                  value: _selectedStorageLocation,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación de almacenamiento',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: storageOptions
                      .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStorageLocation = value!),
                ),
                const SizedBox(height: 12),

                // === Unidad ===
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de medida',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                  ),
                  items: unitOptions
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
                const SizedBox(height: 12),

                // === Código ===
                TextField(
                  controller: _codeProductController,
                  decoration: const InputDecoration(
                    labelText: 'Código de barras',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // === Categoría ===
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: categoryOptions
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // === Imagen ===
                TextButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Cambiar imagen'),
                ),

                if (_selectedImage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
                  )
                else if (widget.product.img != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.product.img!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // === Botón Guardar ===
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _saveProduct,
                    icon: _isUploading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.save),
                    label: Text(_isUploading
                        ? (widget.isNewProduct ? 'Creando...' : 'Guardando...')
                        : 'Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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