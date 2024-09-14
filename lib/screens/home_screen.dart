import 'package:flutter/material.dart';
import 'package:mobile_app/NavBar.dart';

import '../reusable_methods/firebase_methods.dart';

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
      body: Center(),
    );
  }

  void fetchName() async {
    String? result = await getName(uid);
    setState(() {
      name = result!;
    });
  }
}
