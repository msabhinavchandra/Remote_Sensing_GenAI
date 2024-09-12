// import 'package:flutter/material.dart';
// import 'EmailInputPage.dart';
// import 'CommonBackground.dart';

// class PhoneVerificationPage extends StatefulWidget {
//   const PhoneVerificationPage({super.key});

//   @override
//   State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
// }

// class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
//   final TextEditingController _otpController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone Number Verification'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: CommonBackground(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 16), // Adds space from top

//                   // Text for OTP instruction
//                   const Text(
//                     'Please enter the OTP sent to the number you just entered.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16), // Space between text and input

//                   // TextField for OTP input
//                   TextField(
//                     controller: _otpController,
//                     keyboardType: TextInputType.number,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: const InputDecoration(
//                       labelText: 'Enter OTP',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Verify and Next button
//                   ElevatedButton(
//                     onPressed: () {
//                       String otp = _otpController.text;
//                       // Do something with the entered OTP
//                       print('Entered OTP: $otp');

//                       // Navigate to the EmailInputPage
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const EmailInputPage(),
//                         ),
//                       );
//                     },
//                     child: const Text('Verify & Next'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String verificationId;

  const PhoneVerificationPage({Key? key, required this.verificationId})
      : super(key: key);

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
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to verify OTP
            ElevatedButton(
              onPressed: _verifyOTP, // Verify OTP when button is pressed
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to verify the entered OTP
  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim(); // Get the entered OTP
    if (otp.isNotEmpty) {
      // Create a PhoneAuthCredential using the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      try {
        // Sign in the user with the OTP credential
        await FirebaseAuth.instance.signInWithCredential(credential);
        // OTP verification successful, navigate to a success page
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone number verified successfully'),
        ));
        // Navigate to the next page after verification (e.g., home page)
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Failed to verify OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to verify OTP: ${e.toString()}'),
        ));
      }
    } else {
      // Show an error if OTP is not entered
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter the OTP'),
      ));
    }
  }
}
