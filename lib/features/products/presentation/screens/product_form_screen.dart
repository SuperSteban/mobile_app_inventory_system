// presentation/screens/product_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/product.dart';
import '../providers/product_provider_riverpod.dart';
import 'product_view_screen.dart';
import '../widgets/bar_code_scanner.dart'; // Asegúrate de que la ruta sea correcta

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _codeProductController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedStorageLocation = 'ABARROTES';
  String _selectedUnit = 'pieza';
  File? _selectedImage;
  bool _isSubmitting = false;

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
      final fileName = '${const Uuid().v4()}_${path.basename(image.path)}';
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

  Future<void> _submitProduct() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = double.tryParse(_stockController.text.trim()) ?? 0;
    final minStock = double.tryParse(_minStockController.text.trim()) ?? 0;
    final codeProduct = _codeProductController.text.trim();

    if (name.isEmpty || price <= 0 || codeProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Validar código duplicado
    final isDuplicate = await ref.read(productProvider.notifier).isDuplicateCode(codeProduct);
    if (isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya existe un producto con ese código de barras')),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      try {
        imageUrl = await _uploadImage(_selectedImage!);
        if (imageUrl == null) {
          setState(() => _isSubmitting = false);
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: $e')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final product = Product(
      id: '',
      name: name,
      price: price,
      category: _selectedCategory,
      img: imageUrl,
      stock: stock,
      minStock: minStock,
      storageLocation: _selectedStorageLocation,
      codeProduct: codeProduct,
      unit: _selectedUnit,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(productProvider.notifier).createProduct(product);

      // Limpiar formulario
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
    // ELIMINADO: ref.watch(productProvider) → NO NECESARIO
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: storageOptions
                      .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                      .toList(),
                  onChanged: _isSubmitting ? null : (value) => setState(() => _selectedStorageLocation = value!),
                ),
                const SizedBox(height: 12),

                // === Unidad ===
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de medida',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: unitOptions
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: _isSubmitting ? null : (value) => setState(() => _selectedUnit = value!),
                ),
                const SizedBox(height: 12),

                // === Código ===
                // === Código con Escáner ===
                TextFormField(
                  controller: _codeProductController,
                  decoration: InputDecoration(
                    labelText: 'Código de barras',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: const OutlineInputBorder(),
                    // === WIDGET DE ICONO PARA ESCANEAR ===
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _isSubmitting ? null : () async {
                        // Navega a la pantalla del escáner y espera un resultado (aunque lo maneja el onBarcodeDetected)
                        // Se usa el callback para actualizar el controlador del texto
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BarcodeScannerScreen(
                              onBarcodeDetected: (barcode) {
                                // Popula el TextField con el código escaneado
                                _codeProductController.text = barcode;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    // ===================================
                  ),
                ),
                const SizedBox(height: 12), // Mantén el espaciado

                // === Categoría ===
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: categoryOptions
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: _isSubmitting ? null : (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // === Imagen ===
               /* TextButton.icon(
                  onPressed: _isSubmitting ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Seleccionar imagen'),
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
                  ),

                const SizedBox(height: 12), */

                // === Botón Agregar ===
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitProduct,
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.add),
                    label: Text(_isSubmitting ? 'Agregando...' : 'Agregar producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 220, 90, 222),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // === Botón Ver Productos ===
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductViewScreen()),
                      );
                    },
                    icon: const Icon(Icons.storage),
                    label: const Text('PRODUCTOS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 186, 64, 176),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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