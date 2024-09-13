import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_methods.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<int> countFieldOccurrences(String id) async {
  QuerySnapshot querySnapshot = await _firestore
      .collection("entries")
      .where('user_id', isEqualTo: id)
      .get();
  return querySnapshot.size;
}

 fetchAvgMood() async{
  String? result = await getAvgMood();
  return result;
}

Future<double> calculateNewAvgMood(String id, double mood)
async {
  int count = await countFieldOccurrences(id);
  double avg_mood = fetchAvgMood();
  double current_sum = avg_mood*(count-1);
  current_sum += mood;
  return current_sum/count;
}


void updateMood(String id, double mood) async
{
  //TODO: continue to make it work
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('users').where("user_id", isEqualTo: getUser()).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update({
        'avg_mood': await calculateNewAvgMood(id, mood),
      });
      print('Field updated successfully');
    }
  } catch (e) {
    print('Error updating field: $e');
  }
}
