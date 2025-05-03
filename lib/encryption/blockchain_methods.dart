import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<String> computeHash(String uid) async {

  final previousEntry = await FirebaseFirestore.instance
      .collection('notes')
      .where('uid', isEqualTo: uid)
      .orderBy('entry_date', descending: true)
      .limit(1)
      .get();
  if(previousEntry.docs.isNotEmpty)
    {
      String text = previousEntry.docs.first.data()['prev_entry_hash'];
      return sha256.convert(utf8.encode(text)).toString();
    }
  else
    {
      return "GENESIS";
    }
}

