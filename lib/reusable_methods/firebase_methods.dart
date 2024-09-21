import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format the date

Future<String?> getName(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot =
  await _firestore.collection("users").where("uid", isEqualTo: uid).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return (doc.get('first_name') + " " + doc.get('last_name')) as String?;
  } else {
    return 'No matching document found';
  }
}

Future<String?> getAvgMood(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? avgMood = '';
  QuerySnapshot querySnapshot =
  await _firestore.collection("users").where("uid", isEqualTo: uid).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    avgMood = doc.get('avg_mood').toString();
  } else if (querySnapshot.docs.isEmpty || avgMood == null) {
    avgMood = 'No matching document found';
  }
  return avgMood;
}

Future<DocumentSnapshot?> getEntryTitleByDay(
    List<Map<String, String>> weeklyEntries, String uid) async {
  DateTime now = DateTime.now();
  DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('notes')
      .where("uid", isEqualTo: uid)
      .where('entry_date',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .orderBy('entry_date')
      .get();

  for (var doc in querySnapshot.docs) {
    Timestamp timestamp = doc['entry_date'];
    DateTime entryDate = timestamp.toDate();
    String dayOfWeek = DateFormat('EEEE').format(entryDate); // e.g., "Monday"

    // Find the matching day in weeklyEntries and update the summary
    for (var entry in weeklyEntries) {
      if (entry['day'] == dayOfWeek) {
        entry['summary'] =
        doc['entry_title']; // Update the summary for that day
      }
    }
  }
}

void createAccount(String fName, String lName, String uid) async {
  FirebaseFirestore.instance.collection("users").add({
    "first_name": fName,
    "last_name": lName,
    "avg_mood": 0,
    "uid": uid,
  }).catchError((error) => print("Failed to Create Account $error"));
}

Future<bool> canAddEntryToday(String uid) async {
  DateTime today = DateTime.now().toLocal();
  DateTime startOfDay = DateTime(today.year, today.month, today.day);
  DateTime endOfDay = startOfDay.add(Duration(days: 1)); // End of today

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('notes')
      .where("uid", isEqualTo: uid)
      .where('entry_date', isGreaterThan: startOfDay)
      .where('entry_date', isLessThan: endOfDay)
      .limit(1)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    return false;
  }
  return true;
}
