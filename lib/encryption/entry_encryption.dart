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

  //
  //
  // PLATFORM CHANNELING
  //
  //

  static const platform = MethodChannel('phe_channel');

  Future<String> getPublicKey() async {
    try {
      final String encrypted = await platform.invokeMethod('getPublicKey');
      return encrypted;
    } catch (e) {
      print("Public Key Fetch Error: $e");
      return "";
    }
  }

  // Encrypt classification tag
  Future<List<String>> encryptVector(List<String> oneHotVector) async {
    List<String> encryptedVector = [];
    for (var element in oneHotVector) {
      try {
        final String encrypted = await platform.invokeMethod('encrypt', {'value': element});
        encryptedVector.add(encrypted);
      } catch (e) {
        print("Encryption Error for element $element: $e");
        encryptedVector.add(""); // Optional: mark errors
      }
    }
    return encryptedVector;
  }

  Future<List<String>> decryptVector(List<String> encryptedVector) async {
    List<String> decryptedVector = [];
    for (var encrypted in encryptedVector) {
      try {
        final String decrypted = await platform.invokeMethod('decrypt', {'ciphertext': encrypted});
        decryptedVector.add(decrypted);
      } catch (e) {
        print("Decryption Error for element $encrypted: $e");
        decryptedVector.add(""); // Optional: mark errors
      }
    }
    return decryptedVector;
  }

  //Encrypt and decrypt single value (mood)
  Future<String> encryptValue(String value) async {
    String encryptedValue = "";
      try {
        final String encrypted = await platform.invokeMethod('encrypt', {'value': value});
        encryptedValue = encrypted;
      } catch (e) {
        print("Encryption Error for element $encryptedValue: $e");
      }

    return encryptedValue;
  }

  Future<String> decryptValue(String encryptedValue) async {
    String deccryptedValue = "";
      try {
        final String decrypted = await platform.invokeMethod('decrypt', {'ciphertext': encryptedValue});
        deccryptedValue = decrypted;
      } catch (e) {
        print("Decryption Error for element $encryptedValue: $e");
      }
    return deccryptedValue;
  }

  Future<List<String>> addEncryptedVectors(
      List<List<String>> vectors) async {
    if (vectors.isEmpty) return [];
    if (vectors.length == 1) return vectors.first;

    // Start with the first vector as initial result
    List<String> result = List.from(vectors.first);

    // Iterate through remaining vectors
    for (int i = 1; i < vectors.length; i++) {
      final currentVector = vectors[i];
      // Ensure vectors are of same length
      if (currentVector.length != result.length) {
        throw Exception("All vectors must be of the same length");
      }

      // Add current vector to result
      for (int j = 0; j < result.length; j++) {
        try {
          final String sum = await platform.invokeMethod(
              'addEncrypted', {'c1': result[j], 'c2': currentVector[j]});
          result[j] = sum;
        } catch (e) {
          print("Addition Error at index $j: $e");
          result[j] = ""; // or handle error differently
        }
      }
    }

    return result;
  }



  //
  //
  // DIFFERENTIAL PRIVACY
  //
  //
  // Differential Privacy - Laplace Noise
  double addLaplaceNoise(int value, double sensitivity, double epsilon) {
    final random = Random();
    final u = random.nextDouble() - 0.5;
    final noise = -sensitivity / epsilon * sign(u) * log(1 - 2 * u.abs());
    return value + noise;
  }

  int sign(double value) => value >= 0 ? 1 : -1;

}
