import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_widgets/entry_card.dart';
import 'package:mobile_app/reusable_widgets/reusable_widget.dart';
import 'package:mobile_app/screens/entry_editor.dart';

import '../reusable_methods/firebase_methods.dart';
import 'entry_reader.dart';

class EntriesScreen extends StatefulWidget {
  String uid = "";
  EntriesScreen(this.uid, {super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState(uid);
}

class _EntriesScreenState extends State<EntriesScreen> {
  String uid = "";
  _EntriesScreenState(this.uid);

  @override
  void initState() {
    // TODO: implement initState
    getMood();
  }

  void getMood() async
  {
    double mood = (await FirebaseFirestore.instance
        .collection("notes")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get())
        .docs
        .first["entry_mood"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a light background color that matches the rest of your app
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-gradient.jpg"), // Background image from assets
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text
              Text(
                "Your recent entries",
                style: TextStyle(
                  color: Colors.white, // White text for better contrast on dark background
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20.0),
              // Entry list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notes")
                      .where("uid", isEqualTo: uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White loading spinner
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var entry = snapshot.data!.docs[index];
                          return EntryCard(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EntryReaderScreen(entry),
                                ));
                          }, entry );
                        },
                      );
                    }
                    return const Center(
                      child: Text(
                        "No entries available yet.",
                        style: TextStyle(color: Colors.white), // White text for empty state
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white, // Dark teal to match the app's theme
        onPressed: () async {
          if (await canAddEntryToday(uid)) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryEditorScreen(uid),
              ),
            );
          } else {
            showSnackBar(context, "You've already created today's entry");
          }
        },
        label: const Text("Create Entry"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
