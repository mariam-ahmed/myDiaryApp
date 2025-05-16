import 'dart:math';

class DPNoise
{
  // Differential Privacy - Laplace Noise
  static double generateLaplaceNoise(double sensitivity, double epsilon) {
    final random = Random();
    final u = random.nextDouble() - 0.5;
    final noise = -sensitivity / epsilon * sign(u) * log(1 - 2 * u.abs());
    return noise;
  }

  static int sign(double value) => value >= 0 ? 1 : -1;
}