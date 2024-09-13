import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String? getUser()
{
  return  FirebaseAuth.instance.currentUser?.uid ?? null;
}

Future<String?> getName() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore
      .collection("users")
      .where("user_id", isEqualTo: getUser())
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return (doc.get('first__name')+" "+doc.get('last_name')) as String?;
  } else {
    return 'No matching document found';
  }
}

Future<String?> getAvgMood() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore
      .collection("users")
      .where("user_id", isEqualTo: getUser())
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot doc = querySnapshot.docs.first;
    return doc.get('avg_mood') as String?;
  } else {
    return 'No matching document found';
  }
}