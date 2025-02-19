import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_methods/mood_calculations.dart';
import 'package:mobile_app/reusable_widgets/reusable_widget.dart';

import '../reusable_methods/tensorFlow_methods.dart';

class EntryEditorScreen extends StatefulWidget {
  final String uid;

  EntryEditorScreen(this.uid, {super.key});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState(uid);
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  final Timestamp date2 = Timestamp.now();
  double mood = 3;
  double intensity = 3;
  final String uid;
  late List<dynamic> classification;
  String firstClassification = '';

  _EntryEditorScreenState(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,  // Light, neutral background
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.teal.shade900,  // Dark teal for consistency
        title: const Text(
          "Add New Entry",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entry Title TextField
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade900, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Entry Title',
                  hintStyle: TextStyle(color: Colors.teal.shade400),
                ),
              ),
              const SizedBox(height: 16.0),

              // Entry Date
              Text(
                date2.toDate().toLocal().toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16.0),

              // Mood Slider
              const Text(
                "How are you feeling today?",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              Slider(
                value: mood,
                max: 5,
                divisions: 5,
                activeColor: Colors.teal.shade900,
                onChanged: (double value) {
                  setState(() {
                    mood = value;
                  });
                },
              ),

              // Intensity Slider
              const Text(
                "How strong are you feeling that?",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              Slider(
                value: intensity,
                max: 5,
                divisions: 5,
                activeColor: Colors.teal.shade900,
                onChanged: (double value) {
                  setState(() {
                    intensity = value;
                  });
                },
              ),

              const SizedBox(height: 28.0),

              // Entry Content TextField
              TextField(
                controller: _mainController,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade900, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Entry Content',
                  hintStyle: TextStyle(color: Colors.teal.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          classification = await classify(_mainController.text);
          firstClassification = classification[0];
          FirebaseFirestore.instance.collection("notes").add({
            "entry_title": _titleController.text,
            "entry_date": date2,
            "entry_mood": mood,
            "entry_mood_intensity": intensity,
            "entry_content": _mainController.text,
            "entry_classification": classification,
            "uid": uid,
          }).then((value) {
            updateMood(uid, mood);
            Navigator.pop(context);
            showSnackBar(context, "Entry Saved Successfully");
          }).catchError((error) => {showSnackBar(context, "Failed to save entry")});
        },
        child: const Icon(Icons.save),
        backgroundColor: Colors.teal.shade900,
      ),
    );
  }
}
