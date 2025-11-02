import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Importaciones de otras features/pantallas
import '../../../../features/products/presentation/screens/product_view_screen.dart'; // Tu pantalla de productos
// Asumo que estas pantallas existen en su ubicación

// Importación del provider de autenticación para el cierre de sesión
import '../provider/sign_in_notifier.dart';
import '../provider/sign_in_provider.dart';
import '../provider/sign_in_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de widgets para el cuerpo del Scaffold
  // 🟢 IMPORTANTE: Estas son las pantallas a las que navega el BottomNavigationBar
  final List<Widget> _screens = <Widget>[
    const ProductViewScreen(), // Índice 0: Pantalla de Productos (Inventario)
    const Center(child: Text('Pantalla de Usuarios (WIP)')),
    const Center(child: Text('Pantalla de Ajustes (WIP)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define el AppBar de forma dinámica o unificada para toda la aplicación
  AppBar _buildAppBar(BuildContext context, AuthState authState, AuthNotifier notifier) {
    String title = 'Inventario UTH';

    // Puedes cambiar el título según la pestaña
    switch (_selectedIndex) {
      case 0:
        title = 'Inventario de Productos';
        break;
      case 1:
        title = 'Administración de Usuarios';
        break;
      case 2:
        title = 'Ajustes del Sistema';
        break;
    }

    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).primaryColor, // Color principal (verde)
      actions: [
        TextButton(
          onPressed: authState.isLoading ? null : () {
            // Llama al método signOut del AuthNotifier
            notifier.signOut();
          },
          child: authState.isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observar el estado de autenticación (para el botón de cerrar sesión)
    final authState = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(context, authState, notifier),

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
