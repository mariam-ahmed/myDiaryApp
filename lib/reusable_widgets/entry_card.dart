import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget EntryCard(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          doc["entry_title"],
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.0,),
        Text(
            doc["entry_date"].toDate().toString()
        ),
      ]),
    ),
  );
}
