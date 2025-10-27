import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// DataSource y repositorio
import 'features/products/data/datasources/firebase_product_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';

// Casos de uso
import 'features/products/domain/use_cases/add_product_case.dart';
import 'features/products/domain/use_cases/get_products_case.dart';

// Provider y pantalla
import 'features/products/presentation/providers/product_provider.dart';
import 'features/products/presentation/screens/product_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔧 Inyección manual de dependencias
  final datasource = FirebaseProductDatasource();
  final productRepository = ProductRepositoryImpl(datasource);
  final addProductCase = AddProductCase(productRepository);
  final getProductsCase = GetProductsCase(productRepository);

  runApp(
    MyApp(
      addProductCase: addProductCase,
      getProductsCase: getProductsCase,
      productRepository: productRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AddProductCase addProductCase;
  final GetProductsCase getProductsCase;
  final ProductRepositoryImpl productRepository;

  const MyApp({
    super.key,
    required this.addProductCase,
    required this.getProductsCase,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            addProductCase: addProductCase,
            getProductsCase: getProductsCase,
            repository: productRepository,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventario de Productos',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home:
            const ProductFormScreen(), // 👈 Ejecuta esta pantalla para pruebas
      ),
    );
  }
}
