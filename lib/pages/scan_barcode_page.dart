import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isCameraPermissionGranted = false;
  bool isScanning = false;
  bool isTorchOn = false;
  CameraFacing cameraFacing = CameraFacing.back;
  String? scannedBarcode;
  bool isScannerActive = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      isCameraPermissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      await _requestCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      isCameraPermissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'Camera access is required to scan barcodes. Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
          scannedBarcode = barcode.rawValue;
          isScannerActive = false;
        });

        _showBarcodeResult(barcode.rawValue!);
        break;
      }
    }
  }

  void _showBarcodeResult(String barcodeValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barcode Scanned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barcode: $barcodeValue'),
              const SizedBox(height: 16),
              const Text('What would you like to do with this barcode?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                  isScannerActive = true;
                });
              },
              child: const Text('Scan Another'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to product details page with barcode
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Searching for product: $barcodeValue'),
                  ),
                );
              },
              child: const Text('Search Product'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleTorch() async {
    try {
      await cameraController.toggleTorch();
      if (mounted) {
        setState(() {
          isTorchOn = !isTorchOn;
        });
      }
    } catch (e) {
      // Torch might not be available on all devices
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Torch not available on this device')),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await cameraController.switchCamera();
      if (mounted) {
        setState(() {
          cameraFacing = cameraFacing == CameraFacing.back
              ? CameraFacing.front
              : CameraFacing.back;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to switch camera')),
        );
      }
    }
  }

  void _startScanning() {
    setState(() {
      isScannerActive = true;
      isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      isScannerActive = false;
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraPermissionGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Barcode'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Permission Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please grant camera permission to scan barcodes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isScannerActive) ...[
            IconButton(
              icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleTorch,
            ),
            IconButton(
              icon: Icon(
                cameraFacing == CameraFacing.front
                    ? Icons.camera_front
                    : Icons.camera_rear,
              ),
              onPressed: _switchCamera,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Prominent Scan Button
          if (!isScannerActive) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display scanned barcode result
                    if (scannedBarcode != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Barcode Scanned Successfully!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              scannedBarcode!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ready to Scan Barcode',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the button below to start scanning',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Prominent Scan Button
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _startScanning,
                        icon: const Icon(Icons.qr_code_scanner, size: 24),
                        label: const Text(
                          'Scan Barcode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Scanner View
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: _onDetect,
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Position the barcode within the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  // Stop scanning button
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _stopScanning,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Scanning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
