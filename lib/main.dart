import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/features/local_content/local_content_view_model.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_in.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;
  geminiVisionProModel = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-pro-vision',
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: 4096,
    ),
  );

  geminiProModel = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: 4096,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocalContentViewModel(
            multiModalModel: geminiVisionProModel,
            textModel: geminiProModel,
          ),
        ),
        // other providers here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;
  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),

    // ProfileScreen()
    LoginScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _incrementCounter(int index) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sahayak AI')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _incrementCounter,
      ),
    );
  }
}
