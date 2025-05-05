class ClassificationEncoder {
  static final List<String> _distortions = [
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

  /// Encode a single label into a one-hot encoded vector of 15 stringified bits ("0"/"1")
  static List<String> encode(String label) {
    List<String> vector = List.filled(_distortions.length, "0");
    int index = _distortions.indexOf(label);
    if (index != -1) {
      vector[index] = "1";
    }
    return vector;
  }

  /// Decode a one-hot vector into the corresponding cognitive distortion label
  static String? decode(List<String> oneHotVector) {
    int index = oneHotVector.indexOf("1");
    if (index >= 0 && index < _distortions.length) {
      return _distortions[index];
    }
    return null;
  }

  /// Get the full list of labels (optional utility)
  static List<String> get allLabels => _distortions;

  static List<String> fetchLabelEncodingOrder()
  {
    return _distortions;
  }
}
