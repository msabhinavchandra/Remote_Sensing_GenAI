import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ColorizeSARPage extends StatefulWidget {
  const ColorizeSARPage({super.key});

  @override
  State<ColorizeSARPage> createState() => _ColorizeSARPageState();
}

class _ColorizeSARPageState extends State<ColorizeSARPage>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  String? _colorizedImage;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  // Pick image from gallery
  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _colorizedImage = null; // Reset the colorized image
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Send image to backend for colorization
  Future<void> _predictImage() async {
    final serverIp = dotenv.env['SERVER_IP'];
    final serverPort = dotenv.env['PORT'];
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
            'http://$serverIp:$serverPort/colorize'), // Update server URL accordingly
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _colorizedImage = responseData['colorizedImage'];
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to colorize image: ${response.statusCode}')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        shadowColor: Colors.black,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_selectedImage != null && _colorizedImage != null) {
      // Display both images side by side with animation
      return FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Original Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  const SizedBox(height: 10),
                  Hero(
                    tag: 'originalImage',
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text(
                    'Colorized Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  const SizedBox(height: 10),
                  Hero(
                    tag: 'colorizedImage',
                    child: Image.memory(
                      base64Decode(_colorizedImage!),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_selectedImage != null) {
      // Display selected image
      return FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            const Text(
              'Selected Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            const SizedBox(height: 10),
            Hero(
              tag: 'selectedImage',
              child: Image.file(
                _selectedImage!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      );
    } else {
      return const Text(
        'No image selected',
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTitle() {
    return const Text(
      'Colorize SAR Image',
      style: TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black54,
            offset: Offset(3.0, 3.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar to make a full-screen immersive UI
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.deepPurple, Colors.black],
            center: Alignment(0, -0.5),
            radius: 1.0,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 30),
                  _buildImageSection(),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  if (!_isLoading) ...[
                    _buildButton(
                        'Upload Image', Icons.upload_file, _uploadImage),
                    const SizedBox(height: 20),
                    _buildButton('Colorize', Icons.color_lens, _predictImage),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ColorizeSARPage extends StatefulWidget {
//   const ColorizeSARPage({super.key});

//   @override
//   State<ColorizeSARPage> createState() => _ColorizeSARPageState();
// }

// class _ColorizeSARPageState extends State<ColorizeSARPage>
//     with SingleTickerProviderStateMixin {
//   File? _selectedImage;
//   String? _colorizedImage;

//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//   }

//   // Pick image from gallery
//   Future<void> _uploadImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//         _colorizedImage = null; // Reset the colorized image
//       });
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }

//   // Send image to backend for colorization
//   Future<void> _predictImage() async {
//     final serverIp = dotenv.env['SERVER_IP'];
//     final serverPort = dotenv.env['PORT'];
//     if (_selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image first')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final bytes = await _selectedImage!.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       final response = await http.post(
//         Uri.parse(
//             'http://$serverIp:$serverPort/colorize'), // Update server URL accordingly
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'image': base64Image}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         setState(() {
//           _colorizedImage = responseData['colorizedImage'];
//           _isLoading = false;
//         });
//         _animationController.reset();
//         _animationController.forward();
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Failed to colorize image: ${response.statusCode}')),
//         );
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $error')),
//       );
//     }
//   }

//   Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 24),
//       label: Text(
//         text,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.deepPurple,
//         shadowColor: Colors.black,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     if (_selectedImage != null && _colorizedImage != null) {
//       // Display both images side by side with animation
//       return FadeTransition(
//         opacity: _animationController,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Column(
//                 children: [
//                   const Text(
//                     'Original Image',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white, // Set text color to white
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Hero(
//                     tag: 'originalImage',
//                     child: Image.file(
//                       _selectedImage!,
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 20),
//               Column(
//                 children: [
//                   const Text(
//                     'Colorized Image',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white, // Set text color to white
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Hero(
//                     tag: 'colorizedImage',
//                     child: Image.memory(
//                       base64Decode(_colorizedImage!),
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     } else if (_selectedImage != null) {
//       // Display selected image
//       return FadeTransition(
//         opacity: _animationController,
//         child: Column(
//           children: [
//             const Text(
//               'Selected Image',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white, // Set text color to white
//               ),
//             ),
//             const SizedBox(height: 10),
//             Hero(
//               tag: 'selectedImage',
//               child: Image.file(
//                 _selectedImage!,
//                 height: 200,
//                 width: 200,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return const Text(
//         'No image selected',
//         style: TextStyle(fontSize: 16, color: Colors.white),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Widget _buildTitle() {
//     return const Text(
//       'Colorize SAR Image',
//       style: TextStyle(
//         fontSize: 30,
//         color: Colors.white,
//         fontFamily: 'Roboto',
//         fontWeight: FontWeight.bold,
//         shadows: [
//           Shadow(
//             blurRadius: 10.0,
//             color: Colors.black54,
//             offset: Offset(3.0, 3.0),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Remove the AppBar to make a full-screen immersive UI
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: RadialGradient(
//             colors: [Colors.deepPurple, Colors.black],
//             center: Alignment(0, -0.5),
//             radius: 1.0,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildTitle(),
//                   const SizedBox(height: 30),
//                   _buildImageSection(),
//                   const SizedBox(height: 30),
//                   if (_isLoading)
//                     const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   if (!_isLoading) ...[
//                     _buildButton(
//                         'Upload Image', Icons.upload_file, _uploadImage),
//                     const SizedBox(height: 20),
//                     _buildButton('Colorize', Icons.color_lens, _predictImage),
//                   ],
//                   if (_colorizedImage != null) ...[
//                     const SizedBox(height: 30),
//                     Column(
//                       children: [
//                         const Text(
//                           'Ground Truth Image',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Image.asset(
//                           'assets/Ground.png',
//                           height: 200,
//                           width: 200,
//                           fit: BoxFit.cover,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
