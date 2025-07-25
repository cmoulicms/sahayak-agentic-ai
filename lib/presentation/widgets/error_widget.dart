// widgets/error_widget.dart
import 'package:flutter/material.dart';

class SahayakErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;
  final bool showDetails;

  const SahayakErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.retryButtonText,
    this.icon,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getDisplayError(error),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (showDetails) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDisplayError(String error) {
    // Convert technical errors to user-friendly messages
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toLowerCase().contains('permission') ||
        error.toLowerCase().contains('auth')) {
      return 'You don\'t have permission to access this resource.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'The request is taking too long. Please try again.';
    } else if (error.toLowerCase().contains('server') ||
        error.toLowerCase().contains('500')) {
      return 'Our servers are temporarily unavailable. Please try again later.';
    } else if (error.toLowerCase().contains('not found') ||
        error.toLowerCase().contains('404')) {
      return 'The requested resource was not found.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
