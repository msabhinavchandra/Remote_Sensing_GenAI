import 'package:flutter/material.dart';
import 'EmailInputPage.dart'; // Assuming you have an EmailInputPage.dart file

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({Key? key}) : super(key: key);

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController _otpController =
      TextEditingController(); // OTP input field controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // OTP input field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to navigate to EmailInputPage
            ElevatedButton(
              onPressed: () {
                // Navigate to the EmailInputPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EmailInputPage(), // Replace with your actual page
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
