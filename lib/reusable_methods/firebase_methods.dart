import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getName(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore
      .collection("users")
      .where("uid", isEqualTo: uid)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return (doc.get('first_name')+" "+doc.get('last_name')) as String?;
  } else {
    return 'No matching document found';
  }
}

Future<String?> getAvgMood(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore
      .collection("users")
      .where("user_id", isEqualTo: uid)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return doc.get('avg_mood') as String?;
  } else {
    return 'No matching document found';
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