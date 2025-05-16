import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/utils/color_utils.dart';

import '../encryption/classification_encoder.dart';
import '../encryption/entry_encryption.dart';
import '../encryption/phe_encryption.dart';

class EntryReaderScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const EntryReaderScreen(this.doc, {super.key});

  @override
  State<EntryReaderScreen> createState() => _EntryReaderScreenState();
}

class _EntryReaderScreenState extends State<EntryReaderScreen> {
  String mood = '';
  String intensity = '';
  String entry = '';
  String classification = '';
  final EncryptionService encryptionService = EncryptionService();
  final PHEEncryptionService pheencryptionService = PHEEncryptionService();

  @override
  void initState() {
    super.initState();
    decryptValues();
  }

  void decryptValues() async {
    String moodDecrypted =
        await pheencryptionService.decryptValue(widget.doc["entry_mood"]);
    String intensityDecrypted = await pheencryptionService
        .decryptValue(widget.doc["entry_mood_intensity"]);
    String entryDecrypted =
        await encryptionService.decryptEntry(widget.doc["entry_content"]);

    // Decrypt classification vector (one-hot encoded)
    List<String> encClass = List<String>.from(widget.doc["entry_classification"]);
    List<String> decryptedVector = await pheencryptionService.decryptVector(encClass);

    // Find the classification label
    String? label = await ClassificationEncoder.decode(decryptedVector);

    setState(() {
      mood = moodDecrypted;
      intensity = intensityDecrypted;
      entry = entryDecrypted;
      classification = label!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#DCDCDC"),
      // Set the background color to match the theme
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        // Use a solid color for the AppBar
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            const Text("Entry Details", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry Title
            Text(
              widget.doc["entry_title"],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),

            // Entry Date
            Text(
              widget.doc["entry_date"].toDate().toString(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20.0),

            // Mood and Intensity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mood: ${mood}",
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Intensity: ${intensity}",
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Text(
              "Classification: ${classification}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20.0),

            // Entry Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  entry,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.5, // Line spacing for better readability
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
