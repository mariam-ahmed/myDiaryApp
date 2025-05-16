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

/// Verifies the hash chain for a user's entries (like a blockchain)
Future<bool> verifyEntryChain(String uid) async {
  final entriesSnapshot = await FirebaseFirestore.instance
      .collection('notes')
      .where('uid', isEqualTo: uid)
      .orderBy('entry_date')
      .get();

  final entries = entriesSnapshot.docs;

  // If no entries or only one (GENESIS), the chain is trivially valid
  if (entries.isEmpty) return true;

  String expectedPrevHash = "GENESIS";

  for (int i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final data = entry.data();
    final actualPrevHash = data['prev_entry_hash'];

    if (actualPrevHash != expectedPrevHash) {
      print("Hash mismatch at entry ${entry.id}");
      return false;
    }

    // Compute hash of this entry to match with next one
    expectedPrevHash = sha256.convert(utf8.encode(actualPrevHash)).toString();
  }

  return true;
}
