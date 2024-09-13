import 'package:flutter/material.dart';
import 'package:mobile_app/NavBar.dart';

import '../reusable_methods/firebase_methods.dart';

class HomeScreen extends StatefulWidget {
  String email = "";

  HomeScreen(String email, {super.key}) {
    this.email = email;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState(this.email);
}

class _HomeScreenState extends State<HomeScreen> {
  String email = "";
  String name = "";

  _HomeScreenState(String email) {
    this.email = email;
  }

  @override
  void initState() {
    super.initState();
    fetchName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(name),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(),
    );
  }

  void fetchName() async {
    String? result = await getName();
    setState(() {
      name = result!;
    });
  }
}
