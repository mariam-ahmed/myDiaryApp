import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final algorithm = AesGcm.with256bits();
  final _storage = FlutterSecureStorage();

  Future<String> encryptEntry(String text, SecretKey key) async {
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      utf8.encode(text),
      secretKey: key,
      nonce: nonce,
    );
    return base64Encode(secretBox.concatenation());
  }

  // Generate a new encryption key & store it securely
  Future<void> generateAndStoreKey() async {
    final secretKey = await algorithm.newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    await _storage.write(key: 'encryption_key', value: keyBytes.toString());
  }

  // Retrieve stored encryption key
  Future<SecretKey?> getStoredKey() async {
    String? keyString = await _storage.read(key: 'encryption_key');
    if (keyString == null) return null;

    final keyBytes = keyString.replaceAll(RegExp(r'[\[\]]'), '')  // Remove brackets
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();
    return SecretKey(keyBytes);
  }

  /// Decrypts a base64-encoded AES-GCM ciphertext using the stored secret key
  Future<String> decryptEntry(String base64Ciphertext) async {
    try {
      final secretBoxBytes = base64Decode(base64Ciphertext);

      // Parse full secret box
      final secretBox = SecretBox.fromConcatenation(
        secretBoxBytes,
        nonceLength: 12, // GCM uses 12-byte nonce
        macLength: 16,   // GCM uses 16-byte tag
      );

      final secretKey = await getStoredKey();
      if (secretKey == null) {
        throw Exception("Encryption key not found");
      }

      final clearBytes = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(clearBytes);
    } catch (e) {
      print("Decryption error: $e");
      return "Decryption failed";
    }
  }

}
