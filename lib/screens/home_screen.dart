import 'package:flutter/material.dart';
import 'package:mobile_app/NavBar.dart';

class HomeScreen extends StatefulWidget {
  String email = "";
  HomeScreen(String email, {super.key}){
    this.email = email;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState(this.email);
}

class _HomeScreenState extends State<HomeScreen> {
  String email = "";
  _HomeScreenState(String email){
    this.email = email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(email),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(),
    );
  }
}
