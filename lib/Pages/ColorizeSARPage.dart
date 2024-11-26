import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import this library for the File class


class ColorizeSARPage extends StatefulWidget {
  const ColorizeSARPage({Key? key}) : super(key: key);

  @override
  State<ColorizeSARPage> createState() => _ColorizeSARPageState();
}

class _ColorizeSARPageState extends State<ColorizeSARPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colorize SAR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            _imageFile != null
                ? Image.file(
                    File(_imageFile!.path),
                    height: 200,
                  )
                : const Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
