import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_methods.dart';
import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<int> countFieldOccurrences(String id) async {
  QuerySnapshot querySnapshot = await _firestore
      .collection("notes")
      .where('uid', isEqualTo: id)
      .get();
  return querySnapshot.size;
}

Future<String?> fetchAvgMood(String uid) async{
  String? result = await getAvgMood(uid);
  return result;
}

Future<String?> calculateNewAvgMood(String uid, double mood)
async {
  int count = await countFieldOccurrences(uid);
  String? sAvgMood = (await fetchAvgMood(uid));
  double avgMood = double.parse(sAvgMood!);
  double currentSum = avgMood*(count-1);
  currentSum += mood;
  double newAvg = currentSum/count;
  return (newAvg.toStringAsFixed(2));
}


void updateMood(String uid, double mood) async
{
  //TODO: continue to make it work
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
    print('Error updating field: $e');
  }
}
