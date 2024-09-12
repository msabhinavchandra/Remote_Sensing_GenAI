import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PhoneVerificationPage.dart';
import 'package:email_otp/email_otp.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email OTP instance
  final EmailOTP _emailOTP = EmailOTP();

  // To store OTP verification status
  bool isOTPVerified = false;

  // Store verification ID for OTP verification
  String? _verificationId;

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First name field
                buildTextField(_firstNameController, 'First Name'),
                const SizedBox(height: 16),
                //Last name
                buildTextField(_lastNameController, 'Last Name'),
                const SizedBox(height: 16),

                // Username field
                buildTextField(_usernameController, 'Username'),
                const SizedBox(height: 16),

                // Address field
                buildTextField(_addressController, 'Address'),
                const SizedBox(height: 16),

                // Phone number field
                buildTextField(_phoneController, 'Phone Number',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                // Password field
                buildTextField(_passwordController, 'Password',
                    obscureText: true),
                const SizedBox(height: 16),

                // Submit button to register user
                ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneVerificationPage(),  // Replace with the actual page constructor
      ),
    );
  },
  child: const Text('Submit'),
),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Step 1: Send OTP to the phone number

  // Step 2: Register the user (after OTP verification)

// Helper method to build text fields
  // Helper method to build text fields
  Widget buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
