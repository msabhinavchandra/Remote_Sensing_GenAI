import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'MyHomePage.dart';
import 'dashboard.dart';

class FloodDetection extends StatefulWidget {
  const FloodDetection({Key? key}) : super(key: key);

  @override
  _FloodDetectionState createState() => _FloodDetectionState();
}

class _FloodDetectionState extends State<FloodDetection> {
  File? _image;
  Image? _originalImage;
  Image? _predictedMask;
  Image? _resultImage;
  bool? _floodDetected;
  bool _isLoading = false; // Loading state

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _originalImage = Image.file(_image!);
          _predictedMask = null;
          _resultImage = null;
          _floodDetected = null;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _detectFlood() async {
    final serverIp = dotenv.env['SERVER_IP'];
    final serverPort = dotenv.env['PORT'];

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Convert image to Base64
    String base64Image = base64Encode(_image!.readAsBytesSync());

    // Prepare the request payload
    var response = await http.post(
      Uri.parse('http://$serverIp:$serverPort/flood'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);

      // Decode base64 images
      Uint8List predictedMaskBytes = base64Decode(resBody['predicted_mask']);
      Uint8List resultImageBytes = base64Decode(resBody['result_image']);

      setState(() {
        _predictedMask = Image.memory(predictedMaskBytes);
        _resultImage = Image.memory(resultImageBytes);
        _floodDetected = resBody['flood_detected'];
      });
    } else {
      print('Error: ${response.body}');
      setState(() {
        _floodDetected = null;
      });
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Login Page')),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Detection'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            children: [
              // const Text(
              //   'Welcome to the Flood Detection App!',
              //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: _originalImage != null
                          ? DecorationImage(
                              image: _originalImage!.image, fit: BoxFit.cover)
                          : null,
                    ),
                    child: _originalImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tap to select an image',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image from Gallery'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _detectFlood,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Detect Flood'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Loading indicator or results
              _isLoading
                  ? const CircularProgressIndicator()
                  : _floodDetected != null
                      ? Card(
                          color: _floodDetected!
                              ? Colors.red[100]
                              : Colors.green[100],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _floodDetected!
                                  ? 'Flood Detected!'
                                  : 'No Flood Detected',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const Text(
                          'Detection results will appear here.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
              const SizedBox(height: 24),
              if (_predictedMask != null) ...[
                const Text(
                  'Predicted Flood Mask:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _predictedMask!,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_resultImage != null) ...[
                const Text(
                  'Result Image with Flood Contours:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _resultImage!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
