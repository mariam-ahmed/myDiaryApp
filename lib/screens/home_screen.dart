import 'package:flutter/material.dart';
import 'package:mobile_app/NavBar.dart';
import 'package:mobile_app/screens/entry_editor.dart';

import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';

class HomeScreen extends StatefulWidget {
  String uid = "";

  HomeScreen(this.uid, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(this.uid);
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = "";
  String name = "";

  _HomeScreenState(this.uid);

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(name, uid),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Centers the content vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          // Centers the content horizontally
          children: [
            Text(
              'Hello, Welcome!',
              style: TextStyle(
                fontSize: 32, // Large font for the welcome message
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            // Add some space between the text and the button
            ElevatedButton(
              onPressed: () async {
                if (await canAddEntryToday(uid)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EntryEditorScreen(uid)));
                } else {
                  showSnackBar(context, "You've already created today's entry");
                }
              },
              child: Text(
                'Add Today\'s Entry',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchName() async {
    String? result = await getName(uid);
    setState(() {
      name = result!;
    });
  }
}
