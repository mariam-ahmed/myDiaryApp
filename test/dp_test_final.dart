import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/encryption/dp_noise.dart';

double addLaplaceNoise(double value, double epsilon, double sensitivity) {
  double noise = DPNoise.generateLaplaceNoise(epsilon, sensitivity);
  return value + noise;
}

void main() {
  group('DP Noise Test', () {
    late File csvFile;

    setUp(() {
      csvFile = File('dp_convergence_test.csv');
    });

    test('Compute Noisy Averages for 15 Users (DP)', () async {
      final List<List<dynamic>> csvRows = [];
      csvRows.add(['Config', 'Trial', 'User', 'TrueValue', 'NoisyValue']); // Header

      const int numUsers = 15;
      final Random rand = Random();

      // Fixed 15 user scores between 0–25
      List<double> userScores = List.generate(numUsers, (_) => rand.nextDouble() * 25);

      // Parameter sets: (ε, Δ)
      final parameterSets = [
        {'eps': 0.1, 'sens': 1.0},
        {'eps': 0.5, 'sens': 1.0},
        {'eps': 1.0, 'sens': 1.0},
        {'eps': 0.5, 'sens': 2.0},
        {'eps': 1.0, 'sens': 0.5},
      ];

      for (final param in parameterSets) {
        final epsilon = param['eps']!;
        final sensitivity = param['sens']!;

        for (int trial = 0; trial < 100; trial++) {
          for (int user = 0; user < numUsers; user++) {
            double trueValue = userScores[user];
            double noisyValue = addLaplaceNoise(trueValue, epsilon, sensitivity);
            csvRows.add([
              'E${epsilon}_S$sensitivity',
              trial,
              user,
              trueValue.toStringAsFixed(3),
              noisyValue.toStringAsFixed(3)
            ]);
          }
        }
      }

      // Write to CSV
      final csvContent = csvRows.map((row) => row.join(',')).join('\n');
      await csvFile.writeAsString(csvContent);

      print("CSV saved at: ${csvFile.path}");
      expect(await csvFile.exists(), isTrue);
      expect(csvRows.length, greaterThan(1000));
    });
  });
}
