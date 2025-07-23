import 'package:flutter/material.dart';
import 'package:myapp/features/local_content/local_content_screen.dart';

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocalContentScreen(canScroll: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: 150,
                    height: 100,
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Icon(Icons.file_open), Text('Local Content')],
                    ),
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
