import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/encryption/phe_encryption.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PHEEncryptionService es = PHEEncryptionService();
  es.initKeys();
  //
  // // Firestore Emulator
  // FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  //
  // // Firebase Auth Emulator
  // FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   // Define the default brightness and colors.
      //   brightness: Brightness.light,
      //   primaryColor: Colors.teal,
      //   hintColor: Colors.tealAccent,
      //
      //   // Define the default font family.
      //   fontFamily: 'Roboto',
      //
      //   // Define the text styles.
      //   textTheme: TextTheme(
      //     displayLarge: const TextStyle(
      //         fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
      //     titleLarge: const TextStyle(
      //         fontSize: 20.0,
      //         fontWeight: FontWeight.normal,
      //         color: Colors.black),
      //     bodyMedium: TextStyle(
      //         fontSize: 14.0, fontFamily: 'Hind', color: Colors.grey[700]),
      //   ),
      //
      //   // Define button style.
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       foregroundColor: Colors.white,
      //       backgroundColor: Colors.teal, // text color
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(12), // rounded corners
      //       ),
      //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      //     ),
      //   ),
      //
      //   // Define input field style.
      //   inputDecorationTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.grey[100],
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(8.0),
      //       borderSide: BorderSide.none,
      //     ),
      //     hintStyle: TextStyle(color: Colors.grey[400]),
      //   ),
      //
      //   // Apply minimalistic card style
      //   cardTheme: CardTheme(
      //     elevation: 4,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(16),
      //     ),
      //     color: Colors.white,
      //   ),
      // ),
      home: const SignInScreen(),
    );
  }
}
