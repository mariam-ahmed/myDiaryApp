import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart'; // To format the date
import 'package:mobile_app/encryption/classification_encoder.dart';
import 'package:mobile_app/reusable_methods/tensorFlow_methods.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../encryption/blockchain_methods.dart';
import '../encryption/entry_encryption.dart';
import '../encryption/phe_encryption.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'mood_calculations.dart';

Future<String?> getName(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot =
      await _firestore.collection("users").where("uid", isEqualTo: uid).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return (doc.get('first_name') + " " + doc.get('last_name')) as String?;
  } else {
    return 'No matching name to given uid found';
  }
}

Future<String?> getTherapistName(String uid) async {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore
      .collection("users")
      .where("uid", isEqualTo: uid)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return (doc.get('therapist')) as String?;
  } else {
    return 'No matching therapist to provided patient uid';
  }
}

Future<String?> getAvgMood(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PHEEncryptionService pes = PHEEncryptionService();
  String? avgMood = '';
  String davgMood = '';
  QuerySnapshot querySnapshot =
      await _firestore.collection("users").where("uid", isEqualTo: uid).get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    avgMood = doc.get('avg_mood').toString();
    davgMood = await pes.decryptValue(avgMood);
  } else if (querySnapshot.docs.isEmpty || avgMood == null) {
    davgMood = 'No matching document found';
  }
  return davgMood;
}

Future<String?> getDecryptedAvgMood(String uid) async {
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

void createUserAccount(String fName, String lName, String therapist, String pin,
    String uid) async {
  PHEEncryptionService pes = PHEEncryptionService();
  String eAvgMood = await pes.encryptValue("0");

  FirebaseFirestore.instance.collection("users").add({
    "first_name": fName,
    "last_name": lName,
    "avg_mood": eAvgMood,
    "avg_mood_last_week": eAvgMood,
    "role": "user",
    "therapist": therapist,
    "pin": pin,
    "uid": uid,
  }).catchError((error) => print("Failed to Create Account $error"));
}

void createTherapistAccount(String fName, String lName, String uid) async {
  FirebaseFirestore.instance.collection("users").add({
    "first_name": fName,
    "last_name": lName,
    "role": "therapist",
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

Future<bool> addEntry(String uid, String title, double mood, double intensity,
    bool visibility, String entry, BuildContext context) async {
  bool status = false;
  late String classification;
  final Timestamp date2 = Timestamp.now();
  classification = await classify();
  final es = new EncryptionService();
  PHEEncryptionService pes = PHEEncryptionService();

  //Check hash safety of blockchain
  bool isValid = await verifyEntryChain(uid);
  if (!isValid) {
    showSnackBar(context, "Hash chain integrity failed!");
    return false;
  }

  //Encrypt Entry
  SecretKey? key = await es.getStoredKey();
  var keyBytes = await key?.extractBytes();
  String prevHash = await computeHash(uid, entry, mood, date2);
  final encryptedEntry = await es.encryptEntry(entry, key!);

  //Encrypt Classification
  final encodedClassification = ClassificationEncoder.encode(classification);
  final encryptedClassification =
      await pes.encryptVector(encodedClassification!);

  //Encrypt mood and intensity
  double totalMood = mood*intensity;
  String eMood = await pes.encryptValue(mood.toString());
  String eIntenity = await pes.encryptValue(intensity.toString());
  String eTotalMood = await pes.encryptValue(totalMood.toString());

  FirebaseFirestore.instance.collection("notes").add({
    "entry_title": title,
    "entry_date": date2,
    "entry_mood": eMood,
    "entry_mood_intensity": eIntenity,
    "entry_mood_total": eTotalMood,
    "entry_content": encryptedEntry,
    "entry_classification": encryptedClassification,
    "prev_entry_hash": prevHash,
    "visibility": visibility,
    "uid": uid,
    "public_key": keyBytes,
  }).then((value) {
    updateMood(uid, totalMood);
    Navigator.pop(context);
    showSnackBar(context, "Entry Saved Successfully");
    status = true;
  }).catchError((error) => {showSnackBar(context, "Failed to save entry")});

  // Uint8List encrypted_data = encryptJournalEntry(entry, publicKey);
  // print(encrypted_data);
  return status;
}

Future<String?> getUserRole(String uid) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: uid)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first["role"] as String?;
  }
  return null;
}

Future<List<String>> fetchTherapists() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'therapist')
        .get();

    List<String> therapistNames = snapshot.docs.map((doc) {
      return "${doc['first_name']} ${doc['last_name']}"; // Concatenates first and last name
    }).toList();

    return therapistNames;
  } catch (e) {
    print("Error fetching therapists: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchUsersForTherapist(
    String therapistName) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('therapist', isEqualTo: therapistName) // Match therapist name
        .get();

    List<Map<String, dynamic>> userList = snapshot.docs.map((doc) {
      return {
        'uid': doc['uid'],
        'firstName': doc['first_name'],
        'lastName': doc['last_name'],
      };
    }).toList();

    return userList;
  } catch (e) {
    print("Error fetching users for therapist: $e");
    return [];
  }
}

Future<Map<String, List<double>>> getAllUserAnalyticsUnderTherapist(
    String therapistUid) async {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final startOfThisWeek =
      now.subtract(Duration(days: now.weekday - 1)); // Monday
  final startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));

  // Initialize mood sums and counts
  List<double> currentWeekSum = List.filled(7, 0);
  List<int> currentWeekCount = List.filled(7, 0);
  List<double> lastWeekSum = List.filled(7, 0);
  List<int> lastWeekCount = List.filled(7, 0);

  // 1. Get all patients under this therapist
  final patientsSnapshot = await firestore
      .collection('users')
      .where('therapistId', isEqualTo: therapistUid)
      .get();

  final patientUids = patientsSnapshot.docs.map((doc) => doc.id).toList();

  // 2. Get all mood entries for these patients within the last 14 days
  final fourteenDaysAgo = now.subtract(Duration(days: 14));
  final entriesSnapshot = await firestore
      .collection('journal_entries')
      .where('uid', whereIn: patientUids)
      .where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fourteenDaysAgo))
      .get();

  for (var doc in entriesSnapshot.docs) {
    final data = doc.data();
    final mood = data['mood']?.toDouble() ?? 0;
    final uid = data['uid'];
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    final dayIndex = timestamp.weekday - 1; // 0 (Mon) to 6 (Sun)

    if (timestamp.isAfter(startOfThisWeek)) {
      currentWeekSum[dayIndex] += mood;
      currentWeekCount[dayIndex]++;
    } else if (timestamp.isAfter(startOfLastWeek) &&
        timestamp.isBefore(startOfThisWeek)) {
      lastWeekSum[dayIndex] += mood;
      lastWeekCount[dayIndex]++;
    }
  }

  List<double> currentWeekAvg = List.generate(7, (i) {
    return currentWeekCount[i] == 0
        ? 0
        : currentWeekSum[i] / currentWeekCount[i];
  });

  List<double> lastWeekAvg = List.generate(7, (i) {
    return lastWeekCount[i] == 0 ? 0 : lastWeekSum[i] / lastWeekCount[i];
  });

  return {
    'currentWeek': currentWeekAvg,
    'lastWeek': lastWeekAvg,
  };
}

Future<String> checkEntryVisibility(String entryId, String uid) async {
  EncryptionService es = new EncryptionService();
  try {
    final doc = await FirebaseFirestore.instance
        .collection('notes')
        .doc(entryId)
        .get();

    if (!doc.exists) return "Entry not found";

    final data = doc.data()!;
    if (data['visibility'] == false) return "Entry is private";

    // Extract fields
    final String encryptedText = data['entry_content'];
    final List<int> keyBytes = (data['public_key'] as List).cast<int>();
    final SecretKey secretKey = SecretKey(keyBytes);

    final decryptedText = await es.decryptUserEntry(encryptedText, secretKey);

    return decryptedText;
  } catch (e) {
    print("Decryption error: $e");
    return "Decryption failed or entry not accessible";
  }
}
