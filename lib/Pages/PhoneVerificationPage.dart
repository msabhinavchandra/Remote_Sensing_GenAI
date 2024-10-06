

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remote_sensing/Pages/CommonBackground.dart';
import 'dart:convert';
import 'EmailInputPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Import pin_code_fields
import 'dart:async';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String username;
  final String address;

  const PhoneVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.address,
  }) : super(key: key);

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  StreamController<ErrorAnimationType>? _errorController;
  bool hasError = false;
  String currentText = "";
  late Timer _timer;
  int _start = 30; // Countdown timer in seconds
  bool isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _errorController = StreamController<ErrorAnimationType>();
    startTimer();
  }

  @override
  void dispose() {
    _errorController?.close();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 30;
    isResendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          isResendEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final serverIp = dotenv.env['SERVER_IP'];
    final response = await http.post(
      Uri.parse('http://$serverIp:5000/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      _showSuccessDialog();
      return true;
    } else {
      setState(() {
        hasError = true;
      });
      return false;
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: const Text('OTP verified successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailInputPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    username: widget.username,
                    address: widget.address,
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void resendOtp() {
    // Logic to resend OTP
    // You can implement the resend OTP API call here
    startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP has been resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: CommonBackground(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter the 6-digit code sent to ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PinCodeTextField(
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 6) {
                        return "Please enter all 6 digits";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      inactiveFillColor: Colors.white,
                      inactiveColor: Colors.white,
                      selectedFillColor: Colors.white,
                      selectedColor: Colors.blue,
                      activeFillColor: hasError ? Colors.orange : Colors.white,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    errorAnimationController: _errorController,
                    controller: _otpController,
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                        hasError = false;
                      });
                    },
                    beforeTextPaste: (text) {
                      return true;
                    },
                    appContext: context,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      hasError ? "*Please fill up all the cells properly" : "",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_otpController.text.length != 6) {
                        _errorController!.add(ErrorAnimationType.shake);
                        setState(() => hasError = true);
                      } else {
                        verifyOtp(widget.phoneNumber, _otpController.text);
                      }
                    },
                    child: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: isResendEnabled ? resendOtp : null,
                    child: Text(
                      isResendEnabled
                          ? 'Resend OTP'
                          : 'Resend OTP in $_start seconds',
                      style: TextStyle(
                        color: isResendEnabled ? Colors.blue : Colors.grey,
                      ),
                    ),
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
