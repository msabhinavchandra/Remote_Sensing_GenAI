import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:remote_sensing/Pages/CommonBackground.dart';
import 'PhoneVerificationPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text editing controllers for the sign-up fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  Future<void> sendOtp(String phoneNumber) async {
    // Load IP from the .env file
    final serverIp = dotenv.env['SERVER_IP'];
    final serverPort = dotenv.env['PORT'];

    // Ensure the phone number starts with +91
    if (!phoneNumber.startsWith('+91')) {
      phoneNumber = '+91' + phoneNumber;
    }

    final response = await http.post(
      Uri.parse('http://$serverIp:$serverPort/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerificationPage(
            phoneNumber: phoneNumber,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            username: _usernameController.text,
            address: _addressController.text,
          ),
        ),
      );
    } else {
      _showErrorDialog('Failed to send OTP. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the height and width of the screen
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: CommonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    // Logo or header image
                    SizedBox(
                      height: 100,
                      child: Image.asset(
                          'assets/icon.jpg'), // Ensure you have a logo image
                    ),
                    const SizedBox(height: 20),
                    // Form wrapped inside a card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // First name field
                              _buildTextFormField(
                                controller: _firstNameController,
                                labelText: 'First Name',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              // Last name field
                              _buildTextFormField(
                                controller: _lastNameController,
                                labelText: 'Last Name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              // Username field
                              _buildTextFormField(
                                controller: _usernameController,
                                labelText: 'Username',
                                icon: Icons.account_circle,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              // Address field
                              _buildTextFormField(
                                controller: _addressController,
                                labelText: 'Address',
                                icon: Icons.home,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              // Phone number field with +91 prefix
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      '+91',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildTextFormField(
                                      controller: _phoneController,
                                      labelText: 'Phone Number',
                                      icon: Icons.phone,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        } else if (value.length != 10) {
                                          return 'Phone number must be 10 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Submit button to register user
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      sendOtp(_phoneController.text);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    foregroundColor:
                                        Colors.white, // Light blue color
                                  ),
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a common TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: labelText,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
