import 'package:flutter/material.dart';
import 'CommonBackground.dart';
import 'PasswordCreationPage.dart';

// Email Verification Page
class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Enable content to adjust when keyboard is shown
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: CommonBackground(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the entered email
                  Text(
                    'A code has been sent to ${widget.email}.',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                      height: 16), // Space between text and input field

                  // TextField for code input
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white), // Text inside the field
                    decoration: const InputDecoration(
                      labelText: 'Enter Verification Code',
                      labelStyle:
                          TextStyle(color: Colors.white), // Label text color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.white), // Outline color when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white), // Outline color when focused
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                      height: 16), // Space between input field and button

                  ElevatedButton(
                    onPressed: () {
                      String code = _codeController.text;
                      // Handle verification logic here
                      print('Entered Code: $code');
                      // Navigate to Password Creation Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordCreationPage(),
                        ),
                      );
                    },
                    child: const Text('Verify and Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
