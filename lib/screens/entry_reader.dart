import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EntryReaderScreen extends StatefulWidget {
  EntryReaderScreen(this.doc, {super.key});
  QueryDocumentSnapshot doc;

  @override
  State<EntryReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<EntryReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        backgroundColor: Colors.white24,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.doc["entry_title"],
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0,),
          Text(
              widget.doc["entry_date"].toDate().toString()
          ),
          const SizedBox(height: 4.0,),
          Text(
              "Mood: ${widget.doc["entry_mood"]}"
          ),
          const SizedBox(height: 4.0,),
          Text(
              "Intensity: ${widget.doc["entry_mood_intensity"]}"
          ),
          const SizedBox(height: 18.0,),
          Text(
              widget.doc["entry_content"]
          ),
        ]),
      ),
    );
  }
}
