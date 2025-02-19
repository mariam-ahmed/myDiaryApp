import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/utils/color_utils.dart';

class EntryReaderScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const EntryReaderScreen(this.doc, {super.key});

  @override
  State<EntryReaderScreen> createState() => _EntryReaderScreenState();
}

class _EntryReaderScreenState extends State<EntryReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#DCDCDC"),  // Set the background color to match the theme
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,  // Use a solid color for the AppBar
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Entry Details", style: TextStyle(color: Colors.white)),
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
                  "Mood: ${widget.doc["entry_mood"]}",
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Intensity: ${widget.doc["entry_mood_intensity"]}",
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),

            // Entry Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.doc["entry_content"],
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.5,  // Line spacing for better readability
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
