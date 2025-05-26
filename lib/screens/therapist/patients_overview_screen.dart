import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/encryption/classification_encoder.dart';
import 'package:mobile_app/encryption/entry_encryption.dart';
import 'package:mobile_app/reusable_methods/firebase_methods.dart';
import 'package:mobile_app/screens/therapist/patient_analytics_screen.dart';
import 'package:mobile_app/reusable_widgets/patient_card.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../encryption/phe_encryption.dart';

class PatientOverviewScreen extends StatefulWidget {
  final String uid;

  PatientOverviewScreen(this.uid, {super.key});

  @override
  State<PatientOverviewScreen> createState() => _PatientOverviewScreenState();
}

class _PatientOverviewScreenState extends State<PatientOverviewScreen> {
  List<Map<String, dynamic>> assignedUsers = [];
  Map<int, int> moodDistribution = {};
  String therapistName = "";
  double avgMood = 0;
  Map<String, String> todayLabelDistribution = {};
  EncryptionService es = EncryptionService();
  PHEEncryptionService pes = PHEEncryptionService();

  final task = TimelineTask();

  @override
  void initState() {
    super.initState();
    loadAssignedUsers();
  }

  Future<void> loadAssignedUsers() async {

    task.start('Therapist: View User');

    String? fetchedName = await getName(widget.uid);
    if (fetchedName != null) {
      List<Map<String, dynamic>> users = await fetchUsersForTherapist(fetchedName);
      setState(() {
        therapistName = fetchedName;
        assignedUsers = users;
      });
      await loadAverageMood();
      await loadTodayClassifications();
    }

    task.finish();
  }

  Future<void> loadAverageMood() async {
    double totalMood = 0;
    int moodCount = 0;
    List<double> moods = [];

    for (var user in assignedUsers) {
      String puid = user["uid"];
      String? mood = await getAvgMood(puid);
      if (mood != null) {
        double dmood = double.parse(mood);
        totalMood += dmood;
        moodCount++;
        moods.add(dmood);
      }
    }

    Map<int, int> moodCounts = {5: 0, 10: 0, 15: 0, 20: 0, 25: 0};
    for (var score in moods) {
      if (score <= 5) {
        moodCounts[5] = moodCounts[5]! + 1;
      } else if (score <= 10) {
        moodCounts[10] = moodCounts[10]! + 1;
      } else if (score <= 15) {
        moodCounts[15] = moodCounts[15]! + 1;
      } else if (score <= 20) {
        moodCounts[20] = moodCounts[20]! + 1;
      } else {
        moodCounts[25] = moodCounts[25]! + 1;
      }
    }

    setState(() {
      avgMood = moodCount > 0 ? totalMood / moodCount : 0;
      moodDistribution = moodCounts;
    });
  }

  Future<void> loadTodayClassifications() async {
    List<List<String>> encryptedVectors = [];
    List<String> encodingOrder = await ClassificationEncoder.fetchLabelEncodingOrder();

    DateTime todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime tomorrowStart = todayStart.add(const Duration(days: 1));

    for (var user in assignedUsers) {
      String puid = user["uid"];

      var encDoc = await FirebaseFirestore.instance
          .collection("notes")
          .where("uid", isEqualTo: puid)
          .where('entry_date', isGreaterThanOrEqualTo: todayStart)
          .where('entry_date', isLessThan: tomorrowStart)
          .get();

      if (encDoc.docs.isNotEmpty != null) {
        List<String> encrypted = List<String>.from(encDoc.docs.first.get("entry_classification"));
        encryptedVectors.add(encrypted);
      }
    }

    List<String> sumVector = await pes.addEncryptedVectors(encryptedVectors);
    List<String> decryptedCounts = await pes.decryptVector(sumVector);

    Map<String, String> labelCounts = {};
    for (int i = 0; i < decryptedCounts.length; i++) {
      labelCounts[encodingOrder[i]] = decryptedCounts[i];
    }

    setState(() {
      todayLabelDistribution = labelCounts;
    });
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
              const Text(
                "Patients Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20.0),

              Text("Average Mood This week: ${avgMood.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16)),

              const SizedBox(height: 20.0),

              // 🔹 Mood Distribution Chart
              const Text("Mood Distribution (1–25 Scale)", style: TextStyle(color: Colors.white)),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: moodDistribution.entries.map((e) {
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(toY: e.value.toDouble(), color: Colors.cyanAccent)
                      ]);
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (todayLabelDistribution.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: todayLabelDistribution.entries.map((e) {
                        return PieChartSectionData(
                          value: double.tryParse(e.value) ?? 0,
                          title: e.key,
                          radius: 50,
                        );
                      }).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 20.0),
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
