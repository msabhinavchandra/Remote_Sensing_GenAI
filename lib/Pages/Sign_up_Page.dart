// import 'package:flutter/material.dart';
// import 'PhoneVerificationPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   // Text editing controllers for the sign-up fields
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // Firebase instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     // Get the height and width of the screen
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             constraints: BoxConstraints(
//               minHeight: screenHeight,
//             ),
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/Background.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // First name field
//                 TextField(
//                   controller: _firstNameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'First Name',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Last name field
//                 TextField(
//                   controller: _lastNameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Last Name',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Username field
//                 TextField(
//                   controller: _usernameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Address field
//                 TextField(
//                   controller: _addressController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Address',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Phone number field
//                 TextField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Phone Number',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Password field
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Submit button to register user
//                 ElevatedButton(
//                   onPressed: _registerUser,
//                   child: const Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _registerUser() async {
//     try {
//       String firstName = _firstNameController.text.trim();
//       String lastName = _lastNameController.text.trim();
//       String username = _usernameController.text.trim();
//       String phone = _phoneController.text.trim();
//       String address = _addressController.text.trim();
//       String password = _passwordController.text.trim();

//       // Firebase authentication doesn't support direct username-based sign up, so you can use email field as placeholder.
//       String fakeEmail = "$username@yourapp.com";

//       // Register user with Firebase Email and Password (using username as a placeholder email)
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: fakeEmail,
//         password: password,
//       );

//       // Store additional details in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user?.uid)
//           .set({
//         'firstName': firstName,
//         'lastName': lastName,
//         'username': username,
//         'phone': phone,
//         'address': address,
//       });

//       // Navigate to phone verification page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const PhoneVerificationPage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PhoneVerificationPage.dart';

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

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
                TextField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Last name field
                TextField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username field
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address field
                TextField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone number field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit button to register user
                ElevatedButton(
                  onPressed: _sendOTP,  // Send OTP when pressed
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
  Future<void> _sendOTP() async {
    final phoneNumber = _phoneController.text.trim();  // Get the phone number

    if (phoneNumber.isNotEmpty) {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',  // Add country code (replace with the relevant country code)
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification for Android devices
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // If verification fails
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to verify phone number: ${e.message}'),
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          // OTP successfully sent
          setState(() {
            _verificationId = verificationId;  // Store verification ID
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerificationPage(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout: $verificationId');
        },
      );
    } else {
      // Show error if phone number is empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid phone number'),
      ));
    }
  }

  // Step 2: Register the user (after OTP verification)
  Future<void> _registerUser(String otp) async {
    try {
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String username = _usernameController.text.trim();
      String phone = _phoneController.text.trim();
      String address = _addressController.text.trim();
      String password = _passwordController.text.trim();

      // Create credential from OTP and verification ID
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in the user with the credential
      await _auth.signInWithCredential(credential);

      // Fake email for Firebase sign-up (since we don't use real email here)
      String fakeEmail = "$username@yourapp.com";

      // Register the user with Firebase using fake email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      // Store additional user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'phone': phone,
        'address': address,
      });

      // Navigate to home or success page
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully!'),
      ));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
