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
  Future<String> encrypt(String text) async {
    try {
      final String encrypted = await platform.invokeMethod('encrypt', {'text': text});
      return encrypted;
    } catch (e) {
      print("Encryption Error: $e");
      return "";
    }
  }

  Future<String> addEncrypted(String c1, String c2) async {
    return await platform.invokeMethod('addEncrypted', {'c1': c1, 'c2': c2});
  }

  // Decrypt classification tag
  Future<String> decrypt(String ciphertext) async {
    try {
      final String decrypted = await platform.invokeMethod('decrypt', {'ciphertext': ciphertext});
      return decrypted;
    } catch (e) {
      print("Decryption Error: $e");
      return "";
    }
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

  Future<double> computeAverage(List<int> values, double epsilon) async {
    final paillier = EncryptionService();
    List<String> encrypted = [];

    for (int val in values) {
      encrypted.add(await paillier.encrypt(val as String));
    }

    String sum = encrypted.first;
    for (int i = 1; i < encrypted.length; i++) {
      sum = await paillier.addEncrypted(sum, encrypted[i]);
    }

    int decryptedSum = (await paillier.decrypt(sum)) as int;
    double noisyAverage = paillier.addLaplaceNoise(
        decryptedSum ~/ values.length,  1, epsilon);

    return noisyAverage;
  }

}
