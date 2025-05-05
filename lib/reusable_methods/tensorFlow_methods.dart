
//import 'package:tflite_flutter/tflite_flutter.dart';

import 'dart:math';

// Future<List> classify(String text)
// async {
//   late Interpreter _interpreter;
//   _interpreter = await Interpreter.fromAsset('model.tflite');
//   var output = List.filled(1, 0).reshape([1, 1]);
//
//   // Run inference
//   _interpreter.run(text, output);
//
//   // Return the classification result
//   return output;
// }

String classify() {
  final List<String> classifications = [
    "All-or-Nothing Thinking",
    "Overgeneralization",
    "Mental Filter",
    "Discounting the Positive",
    "Jumping to Conclusions",
    "Mind Reading",
    "Fortune Telling",
    "Magnification or Minimization",
    "Emotional Reasoning",
    "Should Statements",
    "Labeling",
    "Personalization",
    "Blaming",
    "Catastrophizing",
    "Control Fallacies"
  ];

  final random = Random();
  int index = random.nextInt(classifications.length);
  return classifications[index];
}