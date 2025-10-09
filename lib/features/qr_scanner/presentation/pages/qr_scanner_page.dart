import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_event.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_state.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController? cameraController;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    context.read<QrScannerBloc>().add(RequestCameraPermissionEvent());
  }

  @override
  void dispose() {
    cameraController?.dispose();
    cameraController = null;
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        _isScanned = true;
      });
      context.read<QrScannerBloc>().add(
        QrCodeScannedEvent(barcodes.first.rawValue!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<QrScannerBloc, QrScannerState>(
        listener: (context, state) {
          if (state is QrScannerSuccess) {
            Navigator.pop(context, state.result.data);
          } else if (state is QrScannerPermissionDenied) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is QrScannerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QrScannerPermissionGranted ||
              state is QrScannerSuccess) {
            cameraController ??= MobileScannerController();
            return Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Align QR code within frame',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Requesting camera permission...'));
        },
      ),
    );
  }
}
