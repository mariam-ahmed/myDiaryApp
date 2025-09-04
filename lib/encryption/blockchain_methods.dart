import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:mobile_app/encryption/phe_encryption.dart';

Future<String> computeHash(String uid, String entry, double mood, Timestamp date) async {

  final previousEntry = await FirebaseFirestore.instance
      .collection('notes')
      .where('uid', isEqualTo: uid)
      .orderBy('entry_date', descending: true)
      .limit(1)
      .get();
  if(previousEntry.docs.isNotEmpty)
    {
      String prev_hash = previousEntry.docs.first.data()['prev_entry_hash'];
      String combined_text = entry + mood.toString() + date.toString() + prev_hash;
      return sha256.convert(utf8.encode(combined_text)).toString();
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

  if (entries.length <= 1) return true; // GENESIS case

  String prevHash = "GENESIS";

  for (final entry in entries) {
    final data = entry.data();
    final storedPrevHash = data['prev_entry_hash'];
    final storedCurrentHash = data['current_hash'];

    if (storedPrevHash != prevHash) {
      print("Chain broken at ${entry.id}: Previous hash mismatch.");
      return false;
    }

    // Recompute current hash from data
    final text = data['entry_text'];         // decrypted or plaintext
    final mood = data['entry_mood'].toString();
    final date = (data['entry_date'] as Timestamp).toDate().toIso8601String();

    var dText, dMood, dDate = decryptValues(text, mood, date);

    final hashInput = dText + dMood + dDate + storedPrevHash;
    final recomputedHash = sha256.convert(utf8.encode(hashInput)).toString();

    if (recomputedHash != storedCurrentHash) {
      print("Hash mismatch at ${entry.id}: Computed vs Stored.");
      return false;
    }

    prevHash = storedCurrentHash;
  }

  return true;
}

Future<(Future<String>, Future<String>, Future<String>)> decryptValues(String text, String mood, String date) async
{
  PHEEncryptionService pes = PHEEncryptionService();
  return (pes.decryptValue(text), pes.decryptValue(mood), pes.decryptValue(date));
}
