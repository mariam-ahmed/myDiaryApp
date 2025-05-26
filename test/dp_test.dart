// File: test/dp_convergence_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/encryption/dp_noise.dart';

void main() {
  group('DP Noise Test', () {
    late File csvFile, csvFile2;
    late List<double> results;

    setUp(() {
      results = [];
      csvFile = File('dp_convergence_test.csv');
      csvFile2 = File('dp_subtraction_attack_test.csv');
    });

    test('Scenario 1.1: Repeated Same Query (100x) on Single User', () async {

      double avgMood = 14.245;
      double noise;
      // Generate noise samples
      for (int i = 0; i < 100; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 0.5);
        results.add(avgMood + noise);
      }

      // Save to CSV
      await csvFile.writeAsString(results.join('\n'));

      // Verify file was created
      expect(await csvFile.exists(), isTrue);
      expect(results.length, 100);
    });

    test('Scenario 1.2: Subtraction Attack on Overlapping User Sets', () async{

      final groupAResults = <double>[];
      final groupBResults = <double>[];
      double noise;

      // True values for our example (hypothetical mood scores)
      const double u1 = 12.0, u2 = 15.0, u3 = 10.0, u4 = 8.0;
      const double trueGroupA = (u1 + u2 + u3 + u4)/4.0;  // 12 + 15 + 10 = 37
      const double trueGroupB = (u1 + u2 + u3)/3.0;   // 15 + 10 + 8 = 33

      for (int i = 0; i < 50; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 0.5);
        final responseA = trueGroupA+noise;
        groupAResults.add(responseA);

        noise = DPNoise.generateLaplaceNoise(1, 0.5);
        final responseB = trueGroupB + noise;
        groupBResults.add(responseB);
      }

      final csvData = StringBuffer('Query,GroupA,GroupB\n');
      for (int i = 0; i < 50; i++) {
        csvData.write('${i + 1},${groupAResults[i]},${groupBResults[i]}\n');
      }

      await csvFile2.writeAsString(csvData.toString());

      // Verify file was created
      expect(await csvFile2.exists(), isTrue);

    });


  });
}