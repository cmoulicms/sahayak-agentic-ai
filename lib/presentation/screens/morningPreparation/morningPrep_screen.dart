// screens/morning_prep/morning_prep_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/data/models/lesson/enhanced_lesson_plan.dart';
import 'package:myapp/data/models/morningPrep/morningPrep_model.dart';
import 'package:myapp/presentation/widgets/error_widget.dart';
import 'package:myapp/presentation/widgets/loading_widget.dart';
import 'package:myapp/presentation/widgets/shayakCard.dart';
import 'package:provider/provider.dart';

// import 'package:intl/intl.dart'; // Ensure this import is present for DateFormat

import '../../providers/lesson_provider.dart';

class MorningPrepScreen extends StatefulWidget {
  const MorningPrepScreen({super.key});

  @override
  State<MorningPrepScreen> createState() => _MorningPrepScreenState();
}

class _MorningPrepScreenState extends State<MorningPrepScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Load morning prep data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().generateMorningPrep();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Morning Preparation'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<LessonProvider>().generateMorningPrep(),
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          if (lessonProvider.isMorningPrepLoading) {
            return const Center(
                child: LoadingWidget(message: 'Preparing your day...'));
          }

          if (lessonProvider.error != null) {
            return SahayakErrorWidget(
              error: lessonProvider.error!,
              onRetry: () => lessonProvider.generateMorningPrep(),
            );
          }

          final morningPrep = lessonProvider.morningPrep;
          if (morningPrep == null) {
            return const Center(
              child: Text('No morning preparation available'),
            );
          }

          return AnimatedBuilder(
            animation: _fadeInAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeInAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _buildMorningPrepContent(
                      context, morningPrep, lessonProvider),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMorningPrepContent(BuildContext context,
      MorningPrepData morningPrep, LessonProvider lessonProvider) {
    final completedTasks =
        morningPrep.tasks.where((task) => task.isCompleted).length;
    final totalTasks = morningPrep.tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return RefreshIndicator(
      onRefresh: () => lessonProvider.generateMorningPrep(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and progress
            _buildHeaderCard(context, morningPrep, progress),
            const SizedBox(height: 16),

            // Mood check-in
            _buildMoodCheckInCard(context, morningPrep.moodCheckIn),
            const SizedBox(height: 16),

            // Weather info
            _buildWeatherCard(context, morningPrep.weather),
            const SizedBox(height: 16),

            // Tasks section
            _buildTasksSection(context, morningPrep.tasks, lessonProvider),
            const SizedBox(height: 16),

            // Quick tips
            _buildQuickTipsCard(
                context, morningPrep.aiTips.map((tip) => tip.title).toList()),
            const SizedBox(height: 16),

            // Today's lessons preview
            _buildTodayLessonsPreview(context, lessonProvider.todayLessons),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, MorningPrepData morningPrep, double progress) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.orange[400],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      // Text(
                      //   DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                      //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //         color: Theme.of(context)
                      //             .colorScheme
                      //             .onSurface
                      //             .withOpacity(0.7),
                      //       ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Morning Preparation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(progress * 100).round()}% Complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCheckInCard(BuildContext context, MoodCheckIn moodCheckIn) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.pink[400],
                ),
                const SizedBox(width: 8),
                Text(
                  'Mood Check-in',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _getMoodEmoji(moodCheckIn.mood),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feeling ${moodCheckIn.mood}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Energy Level: ${moodCheckIn.energyLevel}/10',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (moodCheckIn.motivationalQuote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        moodCheckIn.motivationalQuote,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherInfo weather) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getWeatherIcon(weather.condition),
              color: _getWeatherColor(weather.condition),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature}°C - ${weather.condition}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (weather.suggestion.isNotEmpty)
                    Text(
                      weather.suggestion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, List<MorningPrepTask> tasks,
      LessonProvider lessonProvider) {
    final tasksByCategory = <String, List<MorningPrepTask>>{};
    for (final task in tasks) {
      tasksByCategory.putIfAbsent(task.category, () => []).add(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Morning Tasks',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...tasksByCategory.entries.map((entry) {
          return _buildTaskCategory(
              context, entry.key, entry.value, lessonProvider);
        }).toList(),
      ],
    );
  }

  Widget _buildTaskCategory(BuildContext context, String category,
      List<MorningPrepTask> tasks, LessonProvider lessonProvider) {
    return SahayakCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getCategoryTitle(category),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tasks
                .map((task) => _buildTaskItem(context, task, lessonProvider))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, MorningPrepTask task,
      LessonProvider lessonProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => lessonProvider.markMorningPrepComplete(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)
                            : null,
                      ),
                ),
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${task.estimatedMinutes}m',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTipsCard(BuildContext context, List<String> tips) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips
                .take(3)
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLessonsPreview(
      BuildContext context, List<EnhancedLessonPlan> todayLessons) {
    if (todayLessons.isEmpty) return const SizedBox.shrink();

    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Lessons',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...todayLessons
                .take(3)
                .map((lesson) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text("Day ${lesson.scheduledFor.day}")
                              // Text(
                              //   DateFormat('HH:mm').format(lesson.scheduledFor),
                              //   style: Theme.of(context)
                              //       .textTheme
                              //       .bodySmall
                              //       ?.copyWith(
                              //         fontWeight: FontWeight.w600,
                              //       ),
                              // ),
                              ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.topic,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${lesson.subject} • Grade ${lesson.gradeLevel}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            if (todayLessons.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${todayLessons.length - 3} more lessons',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'calm':
        return '😌';
      case 'tired':
        return '😴';
      case 'stressed':
        return '😰';
      case 'focused':
        return '🎯';
      default:
        return '😊';
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.wb_cloudy;
      case 'rainy':
        return Icons.umbrella;
      case 'stormy':
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Colors.orange;
      case 'cloudy':
        return Colors.grey;
      case 'rainy':
        return Colors.blue;
      case 'stormy':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'materials':
        return Icons.inventory_2;
      case 'review':
        return Icons.book;
      case 'preparation':
        return Icons.assignment;
      case 'wellness':
        return Icons.self_improvement;
      default:
        return Icons.task_alt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'materials':
        return Colors.green;
      case 'review':
        return Colors.blue;
      case 'preparation':
        return Colors.orange;
      case 'wellness':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryTitle(String category) {
    switch (category.toLowerCase()) {
      case 'materials':
        return 'Materials Check';
      case 'review':
        return 'Content Review';
      case 'preparation':
        return 'Class Preparation';
      case 'wellness':
        return 'Wellness & Mindset';
      default:
        return category;
    }
  }
}
