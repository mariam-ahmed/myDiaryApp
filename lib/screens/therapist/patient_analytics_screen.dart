import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/encryption/entry_encryption.dart';

import '../../encryption/classification_encoder.dart';
import '../../encryption/phe_encryption.dart';

class PatientAnalyticsScreen extends StatefulWidget {
  final String uid;
  const PatientAnalyticsScreen(this.uid, {super.key});

  @override
  State<PatientAnalyticsScreen> createState() => _PatientAnalyticsScreenState(uid);
}

class _PatientAnalyticsScreenState extends State<PatientAnalyticsScreen> {
  String uid = "";
  bool isLoading = false;
  EncryptionService es = new EncryptionService();
  PHEEncryptionService pes = PHEEncryptionService();

  double avgMoodThisWeek = 0;
  double avgMoodLastWeek = 0;
  Map<String, List<String>> labelsPerDay = {};

  _PatientAnalyticsScreenState(this.uid);

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);

    final now = DateTime.now();
    final thisWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    try {
      // Fetch average moods directly from user's profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      String avgThisWeek = await pes.decryptValue(userDoc.docs.first.get('avg_mood'));
      String avgLastWeek = await pes.decryptValue(userDoc.docs.first.get('avg_mood_last_week'));

      double dAvgThisWeek = double.parse(avgThisWeek);
      double dAvgLastWeek = double.parse(avgLastWeek);

      // Fetch this week's entries for label distribution
      final entriesSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('uid', isEqualTo: uid)
          .get();

      Map<String, List<String>> dayLabels = {};

      for (var doc in entriesSnapshot.docs) {
        final data = doc.data();
        final entryDate = (data['entry_date'] as Timestamp).toDate();

        if (entryDate.isAfter(thisWeekStart)) {
          final encryptedVector = List<String>.from(data['entry_classification']);
          final decryptedStrVector = await pes.decryptVector(encryptedVector);

          // Convert string values to integers (assuming one-hot encoding)
          final List<String> decodedVector = decryptedStrVector.map((e) => e ?? "0").toList();
          final decodedLabel = ClassificationEncoder.decode(decodedVector);

          final day = DateFormat.E().format(entryDate);
          dayLabels.putIfAbsent(day, () => []).add(decodedLabel!);
        }
      }

      setState(() {
        avgMoodThisWeek = dAvgThisWeek;
        avgMoodLastWeek = dAvgLastWeek;
        labelsPerDay = dayLabels;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading analytics: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildLabelList() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((day) {
        final labels = labelsPerDay[day] ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text("$day: ${labels.join(', ')}"),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 Average Mood This Week: ${avgMoodThisWeek.toStringAsFixed(2)}"),
            Text("📉 Average Mood Last Week: ${avgMoodLastWeek.toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            const Text("🏷️ Labels by Day of This Week:", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildLabelList(),
          ],
        ),
      ),
    );
  }
}
