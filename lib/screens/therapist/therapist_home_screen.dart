import 'package:flutter/material.dart';
import 'package:mobile_app/screens/therapist/patients_overview_screen.dart';
import 'package:mobile_app/utils/NavBar.dart';
import 'package:mobile_app/screens/entry_editor.dart';

import '../../reusable_methods/firebase_methods.dart';
import '../../reusable_widgets/reusable_widget.dart';
import '../../utils/TherapistNavBar.dart';


class TherapistHomeScreen extends StatefulWidget {
  String uid = "";

  TherapistHomeScreen(this.uid, {super.key});

  @override
  State<TherapistHomeScreen> createState() => _TherapistHomeScreenState(this.uid);
}

class _TherapistHomeScreenState extends State<TherapistHomeScreen> {
  String uid = "";
  String name = "";

  _TherapistHomeScreenState(this.uid);

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: TherapistNavBar(name, uid),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Centers the content vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          // Centers the content horizontally
          children: [
            Text(
              'Hello, Welcome!',
              style: TextStyle(
                fontSize: 32, // Large font for the welcome message
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            // Add some space between the text and the button
            ElevatedButton(
              onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PatientOverviewScreen(uid)));
              },
              child: Text(
                'View Patients',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchName() async {
    String? result = await getName(uid);
    setState(() {
      name = result!;
    });
  }
}
