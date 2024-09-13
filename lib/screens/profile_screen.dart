import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';

class ProfileScreen extends StatefulWidget {

  String name = "";

  ProfileScreen(String name, {super.key}) {
    this.name = name;
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(this.name);
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  String name = 'Loading...';
  String avg_mood = 'Loading...';

  _ProfileScreenState(String name)
  {
    this.name = name;
  }

  @override
  void initState() {
    super.initState();
    fetchAvgMood();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(padding: EdgeInsets.zero, children: <Widget>[
      buildTop(),
      const SizedBox(height: 8),
      Text(
        textAlign: TextAlign.center,
        name,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
          const SizedBox(height: 50),
          Text(
            "Average Mood: $avg_mood"
          )
    ]));
  }

  void fetchAvgMood() async{
    String? result = await getAvgMood();
    setState((){
      avg_mood = result!;
    });
  }
}

Stack buildTop() {
  return Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
    Container(
      margin: EdgeInsets.only(bottom: 72),
      color: Colors.teal,
      child: bgImage("assets/images/profile_bg.png"),
    ),
    Positioned(
        top: 178,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 144 / 2,
          child: logoWidget("assets/images/user.png"),
        ))
  ]);
}
