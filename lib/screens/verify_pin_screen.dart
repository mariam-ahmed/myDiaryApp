import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/reusable_methods/firebase_methods.dart';
import 'package:mobile_app/screens/entries_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  String uid = "";
  PinVerificationScreen(this.uid, {super.key});

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState(uid);
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  String uid = "";
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  _PinVerificationScreenState(this.uid);

  Future<void> _verifyPin() async {
    final enteredPin = _pinController.text.trim();

    if (enteredPin.length != 4 || int.tryParse(enteredPin) == null) {
      setState(() => _errorMessage = "Enter a valid 4-digit PIN");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      final storedPin = doc.docs.first?["pin"] ?? '';
      print("The stored pin is: "+storedPin);

      if (storedPin == enteredPin) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => EntriesScreen(uid)));
      } else {
        setState(() => _errorMessage = "Incorrect PIN");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error verifying PIN");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter your 4-digit PIN to access your entries"),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: "PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyPin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
