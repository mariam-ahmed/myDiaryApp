import 'package:flutter/material.dart';
import 'package:mobile_app/encryption/dp_noise.dart';
import 'package:mobile_app/encryption/entry_encryption.dart';
import 'package:mobile_app/encryption/phe_encryption.dart';
import 'package:mobile_app/utils/NavBar.dart';
import 'package:mobile_app/screens/entry_editor.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this to pubspec.yaml

import '../reusable_methods/firebase_methods.dart';
import '../reusable_methods/mood_calculations.dart';
import '../reusable_widgets/reusable_widget.dart';

class HomeScreen extends StatefulWidget {
  String uid = "";

  HomeScreen(this.uid, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(uid);
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = "";
  _HomeScreenState(this.uid);

  List<Map<String, dynamic>> assignedUsers = [];
  Map<int, int> moodDistribution = {};
  double avgMood = 0;
  String therapistName = "";

  String name = "";
  List<double> currentWeek = List.filled(7, 0);
  List<double> lastWeek = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    fetchName();
    loadAssignedUsers();
    checkAndResetWeeklyMood(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(name, widget.uid),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Hello, Welcome!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (await canAddEntryToday(widget.uid)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EntryEditorScreen(widget.uid)),
                  );
                } else {
                  showSnackBar(context, "You've already created today's entry");
                }
              },
              child: Text('Add Today\'s Entry', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
            const SizedBox(height: 40),
            const Text("Mood Distribution (1–25 Scale)", style: TextStyle(color: Colors.black)),
            buildMoodTrendGraph(),

          ],
        ),
      ),
    );
  }

  Future<void> fetchName() async {
    final result = await getName(widget.uid);
    if (result != null) {
      setState(() {
        name = result;
      });
    }
  }

  Future<void> loadAssignedUsers() async {
    String? fetchedName = await getName(widget.uid);
    if (fetchedName != null) {
      List<Map<String, dynamic>> users =
          await fetchUsersForTherapist(fetchedName);
      setState(() {
        therapistName = fetchedName;
        assignedUsers = users;
      });
      await loadAverageMood();
    }
  }

  Future<void> loadAverageMood() async {
    String totalMood = "";
    int moodCount = 0;
    List<String> moods = [];
    PHEEncryptionService pes = PHEEncryptionService();

    // 🔹 Aggregate encrypted mood values
    for (var user in assignedUsers) {
      String puid = user["uid"];
      String? mood = await getDecryptedAvgMood(puid);
      if (mood != null) {
        totalMood = await pes.addEncryptedvalues(totalMood.toString(), mood.toString());
        moodCount++;
        moods.add(mood); // still encrypted
      }
    }

    // 🔹 Add noise to total and decrypt average mood
    DPNoise dp = DPNoise();
    double epsilon = 1.0;
    double noise = DPNoise.generateLaplaceNoise(1, epsilon);

    String noisyTotalMoodEnc = await pes.addEncryptedvalues(totalMood.toString(), noise.toString());
    String decryptedTotal = await pes.decryptValue(noisyTotalMoodEnc);
    double dNoisyTotal = double.tryParse(decryptedTotal) ?? 0;

    // 🔹 Final average mood with noise
    double finalAvgMood = moodCount > 0 ? dNoisyTotal / moodCount : 0;

    // 🔹 Initialize mapping buckets
    Map<int, int> moodCounts = {5: 0, 10: 0, 15: 0, 20: 0, 25: 0};

    // 🔹 Decrypt each mood value, add noise, and map to bucket
    for (String encMood in moods) {
      String noisyMoodEnc = await pes.addEncryptedvalues(encMood, noise.toString());
      String decrypted = await pes.decryptValue(noisyMoodEnc);
      double dMood = double.tryParse(decrypted) ?? 0;

      if (dMood <= 5) {
        moodCounts[5] = moodCounts[5]! + 1;
      } else if (dMood <= 10) {
        moodCounts[10] = moodCounts[10]! + 1;
      } else if (dMood <= 15) {
        moodCounts[15] = moodCounts[15]! + 1;
      } else if (dMood <= 20) {
        moodCounts[20] = moodCounts[20]! + 1;
      } else {
        moodCounts[25] = moodCounts[25]! + 1;
      }
    }

    // 🔹 Update state
    setState(() {
      avgMood = finalAvgMood;
      moodDistribution = moodCounts;
    });
  }


  Widget buildMoodTrendGraph() {
    // 🔹 Mood Distribution Chart
    return SizedBox(
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
    );
  }
}
