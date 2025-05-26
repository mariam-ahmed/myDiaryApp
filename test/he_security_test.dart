import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/encryption/he_service.dart';
import 'package:mobile_app/encryption/phe_encryption.dart';

void main() {
  group('HE Security Tests', () {
    late PHEEncryptionService he;
    late String publicKey, privateKey;

    setUp(() async {
      he = PHEEncryptionService();
      publicKey = await he.generatePublicKey();
      privateKey = await he.generatePrivateKey();
    });

    test('S2.1: Unauthorized decryption fails', () async {
      final encrypted = await he.encryptValue(publicKey, '14.5');
      expect(() => he.decryptValue('wrong_key', encrypted), throwsException);
    });

    test('S2.2: Ciphertexts are non-deterministic', () async {
      final encrypted1 = await he.encrypt(publicKey, '14.5');
      final encrypted2 = await he.encrypt(publicKey, '14.5');
      expect(encrypted1, isNot(equals(encrypted2)));
    });
  });
}