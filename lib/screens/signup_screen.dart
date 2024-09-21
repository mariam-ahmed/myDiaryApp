import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white), // White text to match the teal theme
        ),
      ),
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(image: DecorationImage(
          image: AssetImage('assets/images/bg-gradient.jpg'),
          fit: BoxFit.cover,
        ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery
                .of(context)
                .size
                .height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),

                // First Name Field
                reusableTextField(
                    "Enter First Name", Icons.person_outlined, false,
                    _firstNameTextController),
                const SizedBox(height: 20),

                // Last Name Field
                reusableTextField(
                    "Enter Last Name", Icons.person_outlined, false,
                    _lastNameTextController),
                const SizedBox(height: 20),

                // Email Field
                reusableTextField(
                    "Enter Email", Icons.email, false, _emailTextController),
                const SizedBox(height: 20),

                // Password Field
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 30),

                // Sign Up Button
                signInSignUpButton(context, false, () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text)
                      .then((value) {
                    print("Created New Account");
                    createAccount(_firstNameTextController.text,
                        _lastNameTextController.text, FirebaseAuth.instance
                            .currentUser!.uid);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(
                                  FirebaseAuth.instance.currentUser!.uid)),
                    );
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}