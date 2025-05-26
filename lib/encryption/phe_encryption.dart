import 'package:flutter/services.dart';

class PHEEncryptionService
{

  static final PHEEncryptionService _instance = PHEEncryptionService._internal();
  factory PHEEncryptionService() => _instance;

  PHEEncryptionService._internal();

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

  void initKeys() async
  {
    try {
      await platform.invokeMethod('initKeys');
    } catch (e) {
      print("Public Key Fetch Error: $e");
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
        print("Decryption Error in vector for element $encrypted: $e");
        decryptedVector.add(""); // Optional: mark errors
      }
    }
    return decryptedVector;
  }

  //Encrypt and decrypt single value (mood)
  Future<String> encryptValue(String value) async {
    String encryptedValue = "";
    double doubleValue = double.parse(value);
    int scaledValue = (doubleValue * 1000).round();

    try {
      final String encrypted = await platform.invokeMethod('encrypt', {'value': scaledValue.toString()});
      encryptedValue = encrypted;
    } catch (e) {
      print("Encryption Error for element $encryptedValue: $e");
    }

    return encryptedValue;
  }

  Future<String> decryptValue(String encryptedValue) async {
    String decryptedValue = "";
    try {
      final String decrypted = await platform.invokeMethod('decrypt', {'ciphertext': encryptedValue});

      int scaledInt = int.parse(decrypted);
      double result = scaledInt / 1000.0; // reverse scaling
      decryptedValue = result.toStringAsFixed(3);
    } catch (e) {
      print("Decryption Error for element $encryptedValue: $e");
    }
    return decryptedValue;
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

  Future<String> addEncryptedvalues(String c1, String c2)
  async {
    String sum = "";
    try {
      final String s = await platform.invokeMethod(
          'addEncrypted', {'c1': c1, 'c2': c2});
      sum = s;
    } catch (e) {
      print("Addition Error of Noise");
      sum = ""; // or handle error differently
    }
    return sum;
  }
}