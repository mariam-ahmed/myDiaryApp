import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_methods/mood_calculations.dart';

class EntryEditorScreen extends StatefulWidget {

  String uid = "";
  EntryEditorScreen(this.uid, {super.key});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState(uid);
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _mainController = TextEditingController();
  Timestamp date2 = Timestamp.now();
  double mood = 3;
  double intensity = 3;
  String uid = "";

  _EntryEditorScreenState(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Add new entry"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Entry Title',
              ),
            ),
            const SizedBox(height: 8.0,),
            Text(date2.toDate().toString()),
            const SizedBox(height: 8.0,),
            const Text("How are you feeling today?"),
            const SizedBox(height: 4.0,),
            Slider(
              value: mood,
              max: 5,
              divisions: 5,
              activeColor: Colors.teal,
              onChanged: (double value){
                setState(() {
                  mood = value;
                });
              },
            ),
            const SizedBox(height: 8.0,),
            const Text("How strong are you feeling that?"),
            Slider(
              value: intensity,
              max: 5,
              divisions: 5,
              activeColor: Colors.teal,
              onChanged: (double value){
                setState(() {
                  intensity = value;
                });
              },
            ),
            const SizedBox(height: 28.0,),
            TextField(
                controller: _mainController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Entry content',
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FirebaseFirestore.instance.collection("notes").add({
            "entry_title":_titleController.text,
            "entry_date": date2,
            "entry_mood": mood,
            "entry_mood_intensity": intensity,
            "entry_content": _mainController.text,
            "user_id": uid
          }).then((value) {
            updateMood(uid,mood);
            Navigator.pop(context);
          }).catchError((error) => print("Failed to Save Note $error"));
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
