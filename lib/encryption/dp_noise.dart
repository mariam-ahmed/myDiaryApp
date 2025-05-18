import 'dart:math';

import 'package:mobile_app/encryption/phe_encryption.dart';

class DPNoise
{
  DPNoise()
  {

  }
  // Differential Privacy - Laplace Noise
  static double generateLaplaceNoise(double sensitivity, double epsilon) {
    final random = Random();
    final u = random.nextDouble() - 0.5;
    final noise = -sensitivity / epsilon * sign(u) * log(1 - 2 * u.abs());
    return noise;
  }

  static int sign(double value) => value >= 0 ? 1 : -1;


  /// Wrap/unwrap noise if it is negative to encrypt and decrypt easily

  static Future<BigInt> fetchN() async
  {
    PHEEncryptionService pes = PHEEncryptionService();
    return BigInt.parse(await pes.getPublicKey());
  }
  static Future<BigInt> wrapNoise(double noise) async{
    BigInt n = await fetchN();
    if (noise < 0) {
      return n + BigInt.from(noise); // e.g., -3 → n - 3
    }
    return BigInt.from(noise);
  }

  static Future<double> unwrapNoise(double decrypted) async{
    BigInt n = await fetchN();
    BigInt halfN = n ~/ BigInt.from(2);
    BigInt bd = BigInt.from(decrypted);

    // If the decrypted value is in the upper half of Z_n, it was originally negative
    if (bd > halfN) {
      return (bd - n).toDouble(); // e.g., n - 3 → -3
    }
    return decrypted;
  }
}