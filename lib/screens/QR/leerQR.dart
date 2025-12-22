import 'package:catsa/screens/QR/send_bitacora.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:catsa/screens/QR/send_bitacora.dart';

class LeerQR extends StatefulWidget {
  const LeerQR({super.key});

  @override
  State<LeerQR> createState() => _LeerQRState();
}

class _LeerQRState extends State<LeerQR> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose(); // 🔹 libera la cámara
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) async {
          if (!_isScanning) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              setState(() => _isScanning = false);
              print('Código detectado: $code');

              // 🔹 Detén la cámara antes de navegar
              await controller.stop();

              // 🔹 Navega y espera a que regrese
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendQR(qrCode: code)),
              );

              // 🔹 Reanuda cámara al volver
              await controller.start();
              setState(() => _isScanning = true);
              break;
            }
          }
        },
      ),
    );
  }
}
