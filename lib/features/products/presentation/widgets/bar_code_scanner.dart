import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart'; // Importamos el handler

class BarcodeScannerScreen extends StatefulWidget {
  // Función de callback para devolver el código escaneado
  final Function(String) onBarcodeDetected;

  const BarcodeScannerScreen({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  // 1. Estado para almacenar el resultado del permiso
  PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  // 2. Lógica para solicitar y verificar el permiso de la cámara
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _cameraPermissionStatus = status;
      });

      // Si el permiso es permanentemente denegado, redirigimos al usuario a la configuración
      if (status.isPermanentlyDenied) {
        // Usamos un pequeño retraso para asegurar que setState se complete antes de mostrar el diálogo.
        await Future.delayed(Duration.zero);
        _showPermissionDeniedDialog();
      }
    }
  }

  // 3. Diálogo de ayuda si el permiso fue denegado permanentemente
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permiso Requerido"),
          content: const Text(
            "La aplicación necesita acceso a la cámara para escanear códigos. Por favor, actívelo en la configuración de su dispositivo.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ir a Configuración"),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Abre la configuración de la app
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
                // Navega de vuelta a la pantalla del formulario
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 4. Widget principal que renderiza el escáner o el mensaje de permiso
  @override
  Widget build(BuildContext context) {
    if (_cameraPermissionStatus.isGranted) {
      // ✅ Permiso concedido: Muestra el escáner
      return Scaffold(
        appBar: AppBar(
          title: const Text('Escanear Código de Barras'),
          backgroundColor: const Color.fromARGB(255, 227, 113, 202),
        ),
        body: MobileScanner(
          controller: MobileScannerController(
            detectionTimeoutMs: 1000,
          ),
          onDetect: (BarcodeCapture capture) {
            final String? barcode = capture.barcodes.first.rawValue;
            if (barcode != null) {
              widget.onBarcodeDetected(barcode);
              Navigator.of(context).pop();
            }
          },
        ),
      );
    } else if (_cameraPermissionStatus.isDenied || _cameraPermissionStatus.isPermanentlyDenied) {
      // ❌ Permiso denegado: Muestra un mensaje de error o la opción de reintentar/configuración
      return Scaffold(
        appBar: AppBar(
          title: const Text('Permiso de Cámara'),
          backgroundColor: const Color.fromARGB(255, 227, 113, 202),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.no_photography, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Acceso a la cámara denegado.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No podemos iniciar el escáner sin permiso. Reintente la solicitud.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _requestCameraPermission,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar Solicitud'),
                ),
                const SizedBox(height: 12),
                if (_cameraPermissionStatus.isPermanentlyDenied)
                  TextButton(
                    onPressed: _showPermissionDeniedDialog,
                    child: const Text('Habilitar en Configuración'),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      // ⏳ Permiso pendiente: Muestra un cargando (si aún no se ha resuelto el estado)
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando'),
          backgroundColor: const Color.fromARGB(255, 227, 113, 202),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
