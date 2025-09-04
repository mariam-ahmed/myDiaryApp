// File: test/dp_convergence_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/encryption/dp_noise.dart';

void main() {
  group('DP Noise Test', () {
    late File csvFile, csvFile2, csvFile3, csvFile4, csvFile5, csvFile6;
    late List<double> results1, results2, results3;

    setUp(() {
      results1 = [];
      results2 = [];
      results3 = [];

      csvFile = File('dp_convergence_test1.csv');
      csvFile2 = File('dp_convergence_test2.csv');
      csvFile3 = File('dp_convergence_test3.csv');
      csvFile4 = File('dp_subtraction_attack_test1.csv');
      csvFile5 = File('dp_subtraction_attack_test2.csv');
      csvFile6 = File('dp_subtraction_attack_test3.csv');

    });

    test('Scenario 1.1.1: Repeated Same Query (100x) on Single User', () async {

      double avgMood = 15;
      double noise;
      // Generate noise samples
      for (int i = 0; i < 100; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        results1.add(avgMood + noise);
      }

      // Save to CSV
      await csvFile.writeAsString(results1.join('\n'));

      // Verify file was created
      expect(await csvFile.exists(), isTrue);
      expect(results1.length, 100);
    });

    test('Scenario 1.1.2: Repeated Same Query (1,000x) on Single User', () async {

      double avgMood = 15;
      double noise;
      // Generate noise samples
      for (int i = 0; i < 1000; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        results2.add(avgMood + noise);
      }

      // Save to CSV
      await csvFile2.writeAsString(results2.join('\n'));

      // Verify file was created
      expect(await csvFile2.exists(), isTrue);
      expect(results2.length, 1000);
    });

    test('Scenario 1.1.3: Repeated Same Query (10,000x) on Single User', () async {

      double avgMood = 15;
      double noise;
      // Generate noise samples
      for (int i = 0; i < 10000; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        results3.add(avgMood + noise);
      }

      // Save to CSV
      await csvFile3.writeAsString(results3.join('\n'));

      // Verify file was created
      expect(await csvFile.exists(), isTrue);
      expect(results3.length, 10000);
    });

    test('Scenario 1.2.1: Subtraction Attack 100x on Overlapping User Sets', () async{

      final groupAResults = <double>[];
      final groupBResults = <double>[];
      double noise;

      // True values for our example (hypothetical mood scores)
      const double u1 = 12.0, u2 = 15.0, u3 = 10.0, u4 = 8.0;
      const double trueGroupA = (u1 + u2 + u3 + u4)/4.0;  // 12 + 15 + 10 = 37
      const double trueGroupB = (u1 + u2 + u3)/3.0;   // 15 + 10 + 8 = 33

      for (int i = 0; i < 100; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseA = trueGroupA+noise;
        groupAResults.add(responseA);

        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseB = trueGroupB + noise;
        groupBResults.add(responseB);
      }

      final csvData = StringBuffer('Query,GroupA,GroupB\n');
      for (int i = 0; i < 100; i++) {
        csvData.write('${i + 1},${groupAResults[i]},${groupBResults[i]}\n');
      }

      await csvFile4.writeAsString(csvData.toString());

      // Verify file was created
      expect(await csvFile4.exists(), isTrue);

    });

    test('Scenario 1.2.2: Subtraction Attack 1,000x on Overlapping User Sets', () async{

      final groupAResults = <double>[];
      final groupBResults = <double>[];
      double noise;

      // True values for our example (hypothetical mood scores)
      const double u1 = 12.0, u2 = 15.0, u3 = 10.0, u4 = 8.0;
      const double trueGroupA = (u1 + u2 + u3 + u4)/4.0;  // 12 + 15 + 10 = 37
      const double trueGroupB = (u1 + u2 + u3)/3.0;   // 15 + 10 + 8 = 33

      for (int i = 0; i < 1000; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseA = trueGroupA+noise;
        groupAResults.add(responseA);

        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseB = trueGroupB + noise;
        groupBResults.add(responseB);
      }

      final csvData = StringBuffer('Query,GroupA,GroupB\n');
      for (int i = 0; i < 1000; i++) {
        csvData.write('${i + 1},${groupAResults[i]},${groupBResults[i]}\n');
      }

      await csvFile5.writeAsString(csvData.toString());

      // Verify file was created
      expect(await csvFile5.exists(), isTrue);

    });

    test('Scenario 1.2.3: Subtraction Attack 10,000x on Overlapping User Sets', () async{

      final groupAResults = <double>[];
      final groupBResults = <double>[];
      double noise;

      // True values for our example (hypothetical mood scores)
      const double u1 = 12.0, u2 = 15.0, u3 = 10.0, u4 = 8.0;
      const double trueGroupA = (u1 + u2 + u3 + u4)/4.0;  // 12 + 15 + 10 = 37
      const double trueGroupB = (u1 + u2 + u3)/3.0;   // 15 + 10 + 8 = 33

      for (int i = 0; i < 10000; i++) {
        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseA = trueGroupA+noise;
        groupAResults.add(responseA);

        noise = DPNoise.generateLaplaceNoise(1, 1);
        final responseB = trueGroupB + noise;
        groupBResults.add(responseB);
      }

      final csvData = StringBuffer('Query,GroupA,GroupB\n');
      for (int i = 0; i < 10000; i++) {
        csvData.write('${i + 1},${groupAResults[i]},${groupBResults[i]}\n');
      }

      await csvFile6.writeAsString(csvData.toString());

      // Verify file was created
      expect(await csvFile6.exists(), isTrue);

    });


  });
}