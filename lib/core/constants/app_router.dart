import 'package:flutter/material.dart';
import 'package:myapp/presentation/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:myapp/presentation/screens/features/history_screen.dart';
import 'package:myapp/presentation/screens/features/saved_content_screen.dart';
import 'package:myapp/presentation/screens/features/settings_screen.dart';

// import '../screens/ai_assistant_screen.dart';
// import '../screens/history_screen.dart';
// import '../screens/settings_screen.dart';
// import '../screens/saved_content_screen.dart';

class AppRouter {
  static const String aiAssistant = '/ai-assistant';
  static const String history = '/history';
  static const String settingss = '/settings';
  static const String savedContent = '/saved-content';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case aiAssistant:
        return MaterialPageRoute(
          builder: (_) => const AIAssistantScreen(),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: settings,
        );

      case savedContent:
        return MaterialPageRoute(
          builder: (_) => const SavedContentScreen(),
          settings: settings,
        );

      case settingss:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const AIAssistantScreen(),
        );
    }
  }
}
