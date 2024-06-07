import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EntryEditorScreen extends StatefulWidget {
  const EntryEditorScreen({super.key});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _mainController = TextEditingController();
  DateTime date = DateTime.now();
  Timestamp date2 = Timestamp.now();

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
            Text(date2.toString()),
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
            "entry_content": _mainController.text
          }).then((value) {
            print(value.id);
            Navigator.pop(context);
          }).catchError((error) => print("Failed to Save Note"));
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
