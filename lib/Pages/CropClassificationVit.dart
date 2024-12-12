// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

// class CropClassificationVit extends StatefulWidget {
//   const CropClassificationVit({super.key});

//   @override
//   _CropClassificationVitState createState() => _CropClassificationVitState();
// }

// class _CropClassificationVitState extends State<CropClassificationVit> {
//   File? _image;
//   String? _prediction;
//   String? _serverIp;

//   @override
//   void initState() {
//     super.initState();
//     // Load the environment variables
//     // _loadEnv();
//   }

//   // Future<void> _loadEnv() async {
//   //   await dotenv.load(); // Load the environment variables
//   //   setState(() {
//   //     _serverIp = dotenv.env['SERVER_IP']; // Get the SERVER_IP
//   //     print('Server IP loaded: $_serverIp'); // Debugging line
//   //   });
//   // }

//   Future<void> _pickImage() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedImage =
//           await picker.pickImage(source: ImageSource.gallery);

//       if (pickedImage != null) {
//         setState(() {
//           _image = File(pickedImage.path);
//           print('Image selected: ${_image!.path}'); // Debugging line
//         });
//       }
//     } catch (e) {
//       print("Error picking image: $e");
//     }
//   }

//   Future<void> _uploadImage() async {
//     final serverIp = dotenv.env['SERVER_IP'];
//     if (_image == null) {
//       print('No image to upload'); // Debugging line
//       return;
//     }

//     // Convert image to Base64
//     String base64Image = base64Encode(_image!.readAsBytesSync());
//     print(
//         'Base64 image size: ${base64Image.length} characters'); // Debugging line

//     // Prepare the request payload
//     var response = await http.post(
//       Uri.parse('http://$serverIp:8080/predictvit'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'image': base64Image,
//       }),
//     );

//     // Handle the response
//     print('Response status: ${response.statusCode}'); // Debugging line
//     if (response.statusCode == 200) {
//       var resBody = json.decode(response.body);
//       setState(() {
//         _prediction = resBody['crop'];
//         print('Prediction received: $_prediction'); // Debugging line
//       });
//     } else {
//       print('Error: ${response.body}'); // Debugging line
//       setState(() {
//         _prediction = 'Error: Could not predict the crop.';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Crop Classification',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Color.fromARGB(255, 79, 79, 79)),
//             ),
//             Text(
//               '(VIT)',
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 79, 79, 79)),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Color.fromARGB(
//             255, 174, 232, 214), // A nice green color for agricultural theme
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 16),
//             _image == null
//                 ? Text(
//                     'No image selected.',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                     ),
//                   )
//                 : Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(
//                         _image!,
//                         height: 200,
//                         width: 200,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _pickImage,
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: const Color.fromARGB(255, 110, 179, 164),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text('Select Image from Gallery'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _uploadImage,
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Colors.blue[600],
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text('Upload and Predict'),
//             ),
//             const SizedBox(height: 16),
//             _prediction == null
//                 ? Text(
//                     'Prediction will appear here.',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                     ),
//                   )
//                 : Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Color.fromARGB(255, 180, 225, 151),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.green[200]!),
//                     ),
//                     child: Text(
//                       'Predicted crop: $_prediction',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromARGB(255, 79, 79, 79)),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'MyHomePage.dart';
import 'dashboard.dart';

class CropClassificationVit extends StatefulWidget {
  const CropClassificationVit({Key? key}) : super(key: key);

  @override
  _CropClassificationVitState createState() => _CropClassificationVitState();
}

class _CropClassificationVitState extends State<CropClassificationVit> {
  File? _image;
  String? _prediction;
  bool _isLoading = false; // Indicates whether a prediction is in progress

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _prediction = null; // Reset prediction when a new image is selected
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
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
      Uri.parse('http://$serverIp:$serverPort/predictvit'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'image': base64Image}),
    );

    // Handle the response
    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);
      setState(() {
        _prediction = resBody['crop'];
      });
    } else {
      setState(() {
        _prediction = 'Error: Could not predict the crop.';
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
        title: const Text('Crop Predictor'),
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
            onPressed: _logout, // Call the logout method
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            children: [
              const Text(
                'Welcome to the Crop Predictor App!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
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
                onPressed: _uploadImage,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload and Predict'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _prediction != null
                      ? Card(
                          color: Colors.green[100],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Predicted Crop: $_prediction',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const Text(
                          'Prediction will appear here.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
