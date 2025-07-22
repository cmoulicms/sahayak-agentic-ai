import 'package:flutter/material.dart';

class LocalContent extends StatefulWidget {
  const LocalContent({super.key});

  @override
  State<LocalContent> createState() => _LocalContentState();
}

class _LocalContentState extends State<LocalContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local Context')),
      body: Column()
    );
  }
}