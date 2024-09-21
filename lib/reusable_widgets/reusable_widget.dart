import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(imageName, fit: BoxFit.fitWidth, width: 240, height: 240);
}

Image bgImage(String imageName) {
  return Image.asset(imageName, fit: BoxFit.cover, width: double.infinity, height: 280);
}

Widget reusableTextField(String hintText, IconData icon, bool isPasswordType, TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    cursorColor: Colors.black87, // Cursor color
    style: TextStyle(color: Colors.black87), // Text color
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black54),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black38), // Hint text color
      filled: true,
      fillColor: Colors.white, // Background color of TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Remove the border line
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  );
}

Container signInSignUpButton(BuildContext context, bool isLogin,
    Function onTap) {
  return Container(
    width: MediaQuery
        .of(context)
        .size
        .width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
          isLogin ? "LOG IN" : "SIGN UP",
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
          )
      ),
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2), // How long the snackbar is displayed
  );

  // Use ScaffoldMessenger to show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}