import 'package:flutter/material.dart';
import 'package:mobile_app/utils/NavBar.dart';
import 'package:mobile_app/screens/entry_editor.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this to pubspec.yaml

import '../reusable_methods/firebase_methods.dart';
import '../reusable_widgets/reusable_widget.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen(this.uid, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "";
  List<double> currentWeek = List.filled(7, 0);
  List<double> lastWeek = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    fetchName();
    fetchAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(name, widget.uid),
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Hello, Welcome!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (await canAddEntryToday(widget.uid)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EntryEditorScreen(widget.uid)),
                  );
                } else {
                  showSnackBar(context, "You've already created today's entry");
                }
              },
              child: Text('Add Today\'s Entry', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
            const SizedBox(height: 40),
            buildMoodTrendGraph(),
          ],
        ),
      ),
    );
  }

  Future<void> fetchName() async {
    final result = await getName(widget.uid);
    if (result != null) {
      setState(() {
        name = result;
      });
    }
  }

  Future<void> fetchAnalytics() async {
    final moodData = await getAllUserAnalyticsUnderTherapist(widget.uid);
    setState(() {
      currentWeek = moodData['currentWeek']!;
      lastWeek = moodData['lastWeek']!;
    });
  }

  Widget buildMoodTrendGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Weekly Mood Trend", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(7, (i) => FlSpot(i.toDouble(), currentWeek[i])),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: List.generate(7, (i) => FlSpot(i.toDouble(), lastWeek[i])),
                  isCurved: true,
                  color: Colors.grey,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
