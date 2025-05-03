import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget PatientCard(Function()? onTap, Map<String, dynamic> doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade300, // A solid color, similar to the teal theme
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Soft shadow for depth
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title of the entry
          Text(
            doc["firstName"]+" "+doc["lastName"],
            style: const TextStyle(
              color: Colors.white, // White text for contrast on the teal background
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis, // Truncate long titles
          ),
          const SizedBox(height: 6.0),
          // Date of the entry
          // Text(
          //   doc["entry_date"].toDate().toString(),
          //   style: const TextStyle(
          //     color: Colors.white70, // Dimmed white for the date
          //     fontSize: 14.0,
          //   ),
          // ),
        ],
      ),
    ),
  );
}

