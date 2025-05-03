import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_methods/firebase_methods.dart';
import 'package:mobile_app/screens/therapist/patient_analytics_screen.dart';

import '../../reusable_widgets/patient_card.dart';

class PatientOverviewScreen extends StatefulWidget {
  final String uid;

  PatientOverviewScreen(this.uid, {super.key});

  @override
  State<PatientOverviewScreen> createState() => _PatientOverviewScreenState();
}

class _PatientOverviewScreenState extends State<PatientOverviewScreen> {
  List<Map<String, dynamic>> assignedUsers = [];
  String therapistName = "";

  @override
  void initState() {
    super.initState();
    loadAssignedUsers();
  }

  // 🔹 Load assigned users for this therapist
  Future<void> loadAssignedUsers() async {
    String? fetchedName = await getName(widget.uid);
    if (fetchedName != null) {
      List<Map<String, dynamic>> users = await fetchUsersForTherapist(fetchedName);
      setState(() {
        therapistName = fetchedName;
        assignedUsers = users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-gradient.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              const Text(
                "Patients Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20.0),

              // 🔹 Entry list
              Expanded(
                child: assignedUsers.isEmpty
                    ? const Center(
                  child: Text(
                    "No patients assigned yet.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: assignedUsers.length,
                  itemBuilder: (context, index) {
                    var patient = assignedUsers[index];
                    String patientID = patient["uid"];
                    return PatientCard(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientAnalyticsScreen(patientID),
                        ),
                      );
                    }, patient);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
