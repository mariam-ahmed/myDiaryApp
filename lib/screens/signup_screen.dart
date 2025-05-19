import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/therapist/therapist_home_screen.dart';

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
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _pinTextController = TextEditingController();
  String selectedRole = 'User'; // Default role
  String? selectedTherapist;
  List<String> therapistList = [];

  void _loadTherapists() {
    fetchTherapists().then((names) {
      setState(() {
        therapistList = names;
      });
    }).catchError((error) {
      print("Error loading therapists: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTherapists(); // Fetch therapist names when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white), // White text to match the teal theme
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-gradient.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),

                // First Name Field
                reusableTextField("Enter First Name", Icons.person_outlined,
                    false, _firstNameTextController),
                const SizedBox(height: 20),

                // Last Name Field
                reusableTextField("Enter Last Name", Icons.person_outlined,
                    false, _lastNameTextController),
                const SizedBox(height: 20),

                // Email Field
                reusableTextField(
                    "Enter Email", Icons.email, false, _emailTextController),
                const SizedBox(height: 20),

                // Password Field
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 30),

                reusableTextField(
                  "Enter 4-digit PIN",
                  Icons.lock,
                  true,
                  _pinTextController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),

                // Role Selection (Radio Buttons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: 'User',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value.toString();
                        });
                      },
                    ),
                    const Text("User", style: TextStyle(color: Colors.white)),

                    SizedBox(width: 20),

                    Radio(
                      value: 'Therapist',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value.toString();
                        });
                      },
                    ),
                    const Text("Therapist", style: TextStyle(color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 20),

                if (selectedRole == 'User')
                  Column(
                    children: [
                      const Text(
                        "Select a Therapist",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedTherapist,
                        hint: const Text("Choose a therapist"),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: therapistList.map((therapist) {
                          return DropdownMenuItem<String>(
                            value: therapist,
                            child: Text(therapist),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedTherapist = value;
                          });
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Sign Up Button
                signInSignUpButton(context, false, () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) async {
                    if (selectedRole == "User") {
                      createUserAccount(
                          _firstNameTextController.text,
                          _lastNameTextController.text,
                           selectedTherapist!,
                          _pinTextController.text,
                          FirebaseAuth.instance.currentUser!.uid,
                          );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                FirebaseAuth.instance.currentUser!.uid)),
                      );
                    } else if (selectedRole == "Therapist") {
                      createTherapistAccount(
                          _firstNameTextController.text,
                          _lastNameTextController.text,
                          FirebaseAuth.instance.currentUser!.uid);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TherapistHomeScreen(
                                FirebaseAuth.instance.currentUser!.uid)),
                      );
                    }
                    else {
                      print("Could not figure out role for signup");
                    }
                    ;
                    print("Created New Account");
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
