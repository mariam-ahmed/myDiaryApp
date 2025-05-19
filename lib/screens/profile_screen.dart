import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';

class ProfileScreen extends StatefulWidget {
  String name = "";
  String uid = "";

  ProfileScreen(this.name, this.uid, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(name, uid);
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  String name = 'Loading...';
  String avg_mood = 'Loading...';
  String uid = "";
  List<Map<String, String>> weeklyEntries = [
    {'day': 'Monday', 'summary': ''},
    {'day': 'Tuesday', 'summary': ''},
    {'day': 'Wednesday', 'summary': ''},
    {'day': 'Thursday', 'summary': ''},
    {'day': 'Friday', 'summary': ''},
    {'day': 'Saturday', 'summary': ''},
    {'day': 'Sunday', 'summary': ''},
  ];

  _ProfileScreenState(this.name, this.uid);

  @override
  void initState() {
    super.initState();
    fetchAvgMood();
    fetchEntryTitles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User's Name and Average Mood Section
            _buildUserInfoSection(),

            SizedBox(height: 24),

            // Weekly Summary Section
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Expanded(
              child: _buildWeeklySummary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Average Mood: ${avg_mood} / 5',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.teal,
          child: Text(
            avg_mood,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    return ListView.builder(
      itemCount: weeklyEntries.length,
      itemBuilder: (context, index) {
        final entry = weeklyEntries[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                entry['day']!.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(entry['day']!),
            subtitle: Text(entry['summary']!.isEmpty? 'No entry for this day': entry['summary']!),
          ),
        );
      },
    );
  }

  void fetchAvgMood() async {
    double? result = await getAvgMood(uid);
    setState(() {
      avg_mood = result.toString()!;
    });
  }

  Future<void> fetchEntryTitles() async {
    getEntryTitleByDay(weeklyEntries,uid);
  }
}
