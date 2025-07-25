// screens/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:myapp/presentation/screens/home/dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../onboarding/onboarding_screen.dart'; // Import your onboarding screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const SplashScreen();
        }

        // User is not authenticated - show login
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // User is authenticated but setup incomplete - show onboarding
        if (!authProvider.isSetupComplete) {
          return const OnboardingScreen(); // Replace with your onboarding screen
        }

        // User is authenticated and setup complete - show dashboard
        return const DashboardScreen(); // Replace with your dashboard screen
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sahayak',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Teaching Assistant',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
