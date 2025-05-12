import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/encryption/entry_encryption.dart';

import 'firebase_methods.dart';
import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<int> countFieldOccurrences(String id) async {
  DateTime now = DateTime.now();
  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
  Timestamp startTimestamp = Timestamp.fromDate(
    DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
  );

  QuerySnapshot querySnapshot = await _firestore
      .collection("notes")
      .where('uid', isEqualTo: id)
      .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
      .get();

  return querySnapshot.size;
}


Future<String?> fetchAvgMood(String uid) async{
  String? result = await getAvgMood(uid);
  return result;
}

Future<String?> calculateNewAvgMood(String uid, double mood)
async {
  EncryptionService es = new EncryptionService();

  int count = await countFieldOccurrences(uid);
  String? sAvgMood = (await fetchAvgMood(uid));
  double avgMood = double.parse(sAvgMood!);
  double currentSum = avgMood*(count-1);
  currentSum += mood;
  double newAvg = currentSum/(count+1);
  String eNewAvg = await es.encryptValue(newAvg.toString());
  return (eNewAvg);
}

void updateMood(String uid, double mood) async
{
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update({
        'avg_mood': await calculateNewAvgMood(uid, mood),
      });
      print('Field updated successfully');
    }
  } catch (e) {
    print('Error updating fields: $e');
  }
}

Future<void> checkAndResetWeeklyMood(String userId) async {
  final now = DateTime.now();
  final startOfThisWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final endOfThisWeek = startOfThisWeek.add(Duration(days: 7));

  final entriesSnapshot = await FirebaseFirestore.instance
      .collection('notes')
      .where('uid', isEqualTo: userId)
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfThisWeek))
      .where('timestamp', isLessThan: Timestamp.fromDate(endOfThisWeek))
      .get();

  // If it's Monday and no mood entries exist this week, reset mood
  if (DateTime.now().weekday == DateTime.monday && entriesSnapshot.docs.isEmpty) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userData = await userRef.get();

    if (userData.exists) {
      double currentMood = userData['avg_mood'] ?? 0;

      await userRef.update({
        'avg_mood_last_week': currentMood,
        'avg_mood': 0,
      });
    }
  }
}


