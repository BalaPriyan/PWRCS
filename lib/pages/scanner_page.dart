import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // Importing barcode_scan2 package
import 'package:dio/dio.dart'; // Importing Dio for HTTP requests

class QRScannerLoadingScreen extends StatefulWidget {
  const QRScannerLoadingScreen({Key? key}) : super(key: key);

  @override
  _QRScannerLoadingScreenState createState() => _QRScannerLoadingScreenState();
}

class _QRScannerLoadingScreenState extends State<QRScannerLoadingScreen> {
  bool _isLoading = false;

  // Function to start scanning
  Future<void> _scanQR() async {
    try {
      var result = await BarcodeScanner.scan(); // Initiating the scan
      String scannedCode = result.rawContent; // Getting the scanned QR code

      // Send scanned QR code to the Flask backend for validation
      var response = await Dio().post(
        'http://10.100.3.34:8080/validate_qr', // Use host's IP for emulator
        data: {'qr_code': scannedCode},
      );

      if (response.statusCode == 200) {
        var result = response.data;

        if (result['status'] == 'valid') {
          // Proceed to connect with the valid QR code
          var connectResponse = await Dio().post(
            'http://10.100.3.34:8080/connect',
            data: {'pin': '1234', 'connection_id': result['connection_id']}, // Include the connection ID
          );

          if (connectResponse.statusCode == 200) {
            setState(() {
              _isLoading = true; // Switch to loading mode
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error connecting with QR code!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code!')),
          );
        }
      } else {
        // Handle non-200 response from server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error validating QR code!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error scanning QR code!')),
      );
    }
  }


  void _finishLoading() async {
    await Dio().post(
      'http://10.100.3.34:8080/new_qr',
    );

    // Navigate back to the Home screen after finishing
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _finishLoading,
              child: const Text('Finish'),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: _scanQR,
          child: const Text('Start Scanning'),
        ),
      ),
    );
  }
}
