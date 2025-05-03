import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/reusable_widgets/reusable_widget.dart';
import 'package:mobile_app/screens/entries_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';
import 'package:mobile_app/screens/signin_screen.dart';
import 'package:mobile_app/screens/verify_pin_screen.dart';
import 'package:mobile_app/utils/color_utils.dart';

class NavBar extends StatelessWidget {
  String name = "";
  String uid = "";

  NavBar(this.name, this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(children: [
      UserAccountsDrawerHeader(
          accountName: Text(name),
          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: logoWidget("assets/images/user.png")
            )
          ),
        decoration: BoxDecoration(
          color: hexStringToColor("#7ED6DF")
        ), accountEmail: null,
      ),
          ListTile(
            leading: Icon(Icons.sticky_note_2),
            title: Text("Entries"),
            onTap: () {
              print("Entries");
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PinVerificationScreen(uid)));
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {
              print("Profile");
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(name,uid)));
              });
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              print("Settings");
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              print("Logged Out");
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              });
            },
          )
    ]));
  }

}
