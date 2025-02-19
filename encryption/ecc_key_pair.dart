import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'dart:convert';

AsymmetricKeyPair<PublicKey, PrivateKey> generateECCKeyPair() {
  final keyGen = KeyGenerator("EC")
    ..init(ECKeyGeneratorParameters(ECDomainParameters('secp256r1')));

  return keyGen.generateKeyPair();
}

Uint8List encryptJournalEntry(String entry, PublicKey publicKey) {
  final plaintext = utf8.encode(entry);
  final cipher = AsymmetricBlockCipher('ECIES')..init(true, PublicKeyParameter(publicKey));
  return cipher.process(Uint8List.fromList(plaintext));
}

Uint8List signEntry(Uint8List hash, PrivateKey privateKey) {
  final signer = Signer('SHA-256/ECDSA')..init(true, PrivateKeyParameter(privateKey));
  return signer.generateSignature(hash).bytes;
}