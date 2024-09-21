import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_widgets/entry_card.dart';
import 'package:mobile_app/reusable_widgets/reusable_widget.dart';
import 'package:mobile_app/screens/entry_editor.dart';
import 'package:mobile_app/utils/color_utils.dart';

import '../reusable_methods/firebase_methods.dart';
import 'entry_reader.dart';

class EntriesScreen extends StatefulWidget {
  String uid = "";
   EntriesScreen(String uid, {super.key}){
     this.uid = uid;
   }

  @override
  State<EntriesScreen> createState() => _EntriesScreenState(this.uid);
}

class _EntriesScreenState extends State<EntriesScreen> {

  String uid = "";
  _EntriesScreenState(String uid)
  {
    this.uid = uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#DCDCDC"),
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Entries"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your recent entries",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("notes").where("uid", isEqualTo: uid).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        children: snapshot.data!.docs
                            .map((entry) => EntryCard(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EntryReaderScreen(entry),
                                      ));
                                }, entry))
                            .toList());
                  }
                  return const Text("There's no notes yet");
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if(await canAddEntryToday(uid)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EntryEditorScreen(uid)));
          }
          else
            {
              showSnackBar(context, "You've already created today's entry");
            }
        },
        label: const Text("Create Entry"),
        icon: const Icon(Icons.add),
      ),
    );
  }


}
