

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AccountCreatedPage.dart';
import 'CommonBackground.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordCreationPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String address;
  final String phoneNumber;

  const PasswordCreationPage({
    Key? key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.address,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PasswordCreationPage> createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.red;

  Future<void> _createAccountAndSaveToFirestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user in Firebase Authentication using email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: _passwordController.text,
      );

      // Once the user is created, store additional user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': widget.email,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'username': widget.username,
        'address': widget.address,
        'phoneNumber': widget.phoneNumber,
        'created_at': DateTime.now(),
      });

      // Navigate to the Account Created Success Page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AccountCreatedPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      _showErrorMessage(
        e.code == 'weak-password'
            ? 'The password provided is too weak.'
            : e.code == 'email-already-in-use'
                ? 'The account already exists for that email.'
                : 'An error occurred: ${e.message}',
      );
    } catch (e) {
      // Handle other potential errors
      _showErrorMessage('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _buildInputDecoration(
      String label, bool isPasswordVisible, VoidCallback toggleVisibility) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.white70,
        ),
        onPressed: toggleVisibility,
      ),
    );
  }

  Widget _buildPasswordTextField(
      {required TextEditingController controller,
      required String label,
      required bool isPasswordVisible,
      required VoidCallback toggleVisibility,
      required void Function(String) onChanged}) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration:
          _buildInputDecoration(label, isPasswordVisible, toggleVisibility),
      onChanged: onChanged,
    );
  }

  void _checkPasswordStrength(String password) {
    String strength;
    Color strengthColor;

    if (password.isEmpty) {
      strength = '';
      strengthColor = Colors.red;
    } else if (password.length < 6) {
      strength = 'Too Short';
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strength = 'Weak';
      strengthColor = Colors.orange;
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength = 'Strong';
      strengthColor = Colors.green;
    } else {
      strength = 'Medium';
      strengthColor = Colors.yellow;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthColor = strengthColor;
    });
  }

  void _validateAndSubmit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showPasswordMismatchDialog();
    } else if (_passwordStrength == 'Too Short' || _passwordStrength == '') {
      _showErrorMessage('Please choose a stronger password.');
    } else {
      await _createAccountAndSaveToFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: CommonBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Set a secure password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a password that is at least 8 characters long.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildPasswordTextField(
                  controller: _passwordController,
                  label: 'Password',
                  isPasswordVisible: _isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onChanged: _checkPasswordStrength,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password Strength: $_passwordStrength',
                    style: TextStyle(
                      color: _passwordStrengthColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  isPasswordVisible: _isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  onChanged: (_) {},
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordMismatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwords Do Not Match'),
        content: const Text('Please make sure both passwords match.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
