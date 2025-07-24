import 'package:flutter/material.dart';
import 'package:myapp/screens/local_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text('AI Tools', style: TextStyle(fontSize: 20)),
            Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              runSpacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LocalContent()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueAccent.shade100,
                    ),
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Icon(Icons.file_open), Text('Local Content')],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueAccent.shade100,
                  ),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.file_open),
                      Text('Differentiate Materials'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueAccent.shade100,
                  ),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Icon(Icons.file_open), Text('Knowleadge Base')],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueAccent.shade100,
                  ),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Icon(Icons.file_open), Text('Visual Aids')],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
