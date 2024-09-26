import 'dart:async';
import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

// PICK MEDIA
Future<File?> function_PickMedia() async {
  final picker = ImagePicker();
  try {
    // Pick an image or video from gallery
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No file selected.');
      return null;
    }
  } catch (e) {
    print('Error picking media: $e');
    return null; // Handle error gracefully
  }
}

// PICK MULTUPLE MEDIA
Future<List<File>?> function_PickMultipleMedia() async {
  final picker = ImagePicker();
  try {
    // Pick multiple images from the gallery
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      return pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    } else {
      print('No files selected.');
      return null;
    }
  } catch (e) {
    print('Error picking media: $e');
    return null; // Handle error gracefully
  }
}

// CHECK TYPE
String function_CheckType(File file) {
  // Use the mime package to determine the MIME type
  final mimeType = lookupMimeType(file.path);
  if (mimeType != null) {
    return mimeType
        .split('/')
        .first; // Return the primary type (e.g., 'image', 'video', 'application', etc.)
  } else {
    return 'Unknown'; // Handle case where MIME type cannot be determined
  }
}

// TAKE PHOTO
Future<File?> function_TakePhoto() async {
  final ImagePicker picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    print('No image selected.');
    return null;
  }
}

Future<String?> function_ScanQRCode(BuildContext context) async {
  String? qrResult;

  // Create a Completer to handle asynchronous result
  final Completer<String?> completer = Completer<String?>();

  // Navigate to QR Scanner Screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => QRScannerScreen(
        onQRCodeScanned: (result) {
          qrResult = result;
          completer.complete(qrResult);
        },
      ),
    ),
  );

  // Wait for the QR scan result
  final result = await completer.future;

  if (result == null) {
    return null; // Return null if no QR code was scanned
  }

  // Return the scanned QR code result
  return result;
}

class QRScannerScreen extends StatelessWidget {
  final void Function(String) onQRCodeScanned;

  const QRScannerScreen({super.key, required this.onQRCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          // Extract the raw value from the BarcodeCapture
          final qrResult = barcodeCapture.barcodes.first.rawValue;
          if (qrResult != null) {
            onQRCodeScanned(qrResult);
            Navigator.pop(context); // Close the screen after scanning
          }
        },
        fit: BoxFit.cover,
      ),
    );
  }
}
