import 'package:Sahayak/presentation/providers/lesson_provider.dart';
import 'package:Sahayak/presentation/providers/stress_analysis_provider.dart';
import 'package:Sahayak/presentation/widgets/shayakCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MorningPrepScreen extends StatefulWidget {
  const MorningPrepScreen({super.key});

  @override
  State<MorningPrepScreen> createState() => _MorningPrepScreenState();
}

class _MorningPrepScreenState extends State<MorningPrepScreen> {
  final Map<String, int> _currentStressLevels = {
    'workload': 3,
    'resources': 3,
    'behavior': 3,
    'admin': 3,
    'parents': 3,
    'technology': 3,
  };

  int _overallWellness = 7;
  final List<String> _selectedTriggers = [];
  final List<String> _selectedRelievers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stressProvider = context.read<StressAnalysisProvider>();
      final teacherId = 'current_teacher_id'; // Get from auth
      stressProvider.loadStressData(teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Enhanced Morning Prep'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showStressAnalytics(),
          ),
        ],
      ),
      body: Consumer2<LessonProvider, StressAnalysisProvider>(
        builder: (context, lessonProvider, stressProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stress Check-in Card
                _buildStressCheckInCard(stressProvider),
                const SizedBox(height: 16),

                // Wellness Overview
                _buildWellnessOverviewCard(stressProvider),
                const SizedBox(height: 16),

                // AI-Powered Stress Interventions
                _buildStressInterventionsCard(stressProvider),
                const SizedBox(height: 16),

                // Enhanced Morning Tasks with Stress Context
                _buildEnhancedTasksCard(lessonProvider, stressProvider),
                const SizedBox(height: 16),

                // Personalized Recommendations
                _buildPersonalizedRecommendations(stressProvider),
                const SizedBox(height: 16),

                // Quick Actions for Stress Management
                _buildQuickStressActions(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _completeStressCheckIn,
        icon: const Icon(Icons.check_circle),
        label: const Text('Complete Check-in'),
      ),
    );
  }

  Widget _buildStressCheckInCard(StressAnalysisProvider stressProvider) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  'Morning Stress Check-in',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'How are you feeling about these areas today?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Stress level sliders
            ..._currentStressLevels.entries.map(
              (entry) => _buildStressLevelSlider(entry.key, entry.value),
            ),

            const SizedBox(height: 16),

            // Overall wellness
            Text(
              'Overall Wellness (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _overallWellness.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _overallWellness.toString(),
              onChanged: (value) =>
                  setState(() => _overallWellness = value.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressLevelSlider(String factor, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_getStressFactorTitle(factor)),
        Row(
          children: [
            const Text('Low'),
            Expanded(
              child: Slider(
                value: level.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: level.toString(),
                onChanged: (value) => setState(
                  () => _currentStressLevels[factor] = value.round(),
                ),
              ),
            ),
            const Text('High'),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStressColor(level).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                level.toString(),
                style: TextStyle(
                  color: _getStressColor(level),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWellnessOverviewCard(StressAnalysisProvider stressProvider) {
    final insights = stressProvider.getStressInsights();

    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Wellness Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (insights.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Trend',
                      insights['trendDirection'] ?? 'stable',
                      _getTrendIcon(insights['trendDirection'] ?? 'stable'),
                      _getTrendColor(insights['trendDirection'] ?? 'stable'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Wellness',
                      '$_overallWellness/10',
                      Icons.favorite,
                      _getWellnessColor(_overallWellness),
                    ),
                  ),
                ],
              ),
              if (insights['recommendations'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Quick Recommendations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...(insights['recommendations'] as List<String>).map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStressInterventionsCard(StressAnalysisProvider stressProvider) {
    final highStressAreas = _currentStressLevels.entries
        .where((entry) => entry.value >= 4)
        .toList();

    if (highStressAreas.isEmpty) {
      return const SizedBox.shrink();
    }

    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Stress Alert & Interventions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'High stress detected in: ${highStressAreas.map((e) => _getStressFactorTitle(e.key)).join(", ")}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Immediate interventions
            Text(
              'Immediate Relief Actions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            ..._getStressInterventions(highStressAreas).map(
              (intervention) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(intervention)),
                    IconButton(
                      icon: Icon(Icons.play_arrow, size: 16),
                      onPressed: () => _startIntervention(intervention),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTasksCard(
    LessonProvider lessonProvider,
    StressAnalysisProvider stressProvider,
  ) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Smart Morning Tasks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI-adjusted tasks based on stress levels
            ..._getSmartTasks().map((task) => _buildSmartTaskItem(task)),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _generatePersonalizedTasks(stressProvider),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate AI Tasks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedRecommendations(
    StressAnalysisProvider stressProvider,
  ) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Personalized Recommendations',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getPersonalizedRecommendations().map(
              (rec) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(rec['description']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(rec['category']),
                          backgroundColor: Colors.purple.withOpacity(0.2),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _implementRecommendation(rec),
                          child: const Text('Try Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStressActions() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stress Relief',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Breathing Exercise',
                    Icons.air,
                    Colors.blue,
                    () => _startBreathingExercise(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Mindful Moment',
                    Icons.self_improvement,
                    Colors.green,
                    () => _startMindfulMoment(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Energy Boost',
                    Icons.flash_on,
                    Colors.orange,
                    () => _startEnergyBoost(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Focus Session',
                    Icons.center_focus_strong,
                    Colors.purple,
                    () => _startFocusSession(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods and utility functions

  String _getStressFactorTitle(String factor) {
    switch (factor) {
      case 'workload':
        return 'Workload & Time Management';
      case 'resources':
        return 'Teaching Resources';
      case 'behavior':
        return 'Student Behavior';
      case 'admin':
        return 'Administrative Tasks';
      case 'parents':
        return 'Parent Communication';
      case 'technology':
        return 'Technology Challenges';
      default:
        return factor;
    }
  }

  Color _getStressColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> _getStressInterventions(
    List<MapEntry<String, int>> highStressAreas,
  ) {
    final interventions = <String>[];

    for (final area in highStressAreas) {
      switch (area.key) {
        case 'workload':
          interventions.add('Use AI lesson planner to reduce prep time by 60%');
          break;
        case 'resources':
          interventions.add(
            'Access instant teaching materials from AI library',
          );
          break;
        case 'admin':
          interventions.add('Enable automated progress tracking');
          break;
        case 'behavior':
          interventions.add('Quick classroom management strategies');
          break;
      }
    }

    return interventions;
  }

  void _completeStressCheckIn() async {
    final stressProvider = context.read<StressAnalysisProvider>();

    await stressProvider.logDailyStress(
      teacherId: 'current_teacher_id', // Get from auth
      stressLevels: _currentStressLevels,
      triggers: _selectedTriggers,
      relievers: _selectedRelievers,
      overallWellness: _overallWellness,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stress check-in completed!')));
  }

  // Implement other helper methods...
  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Additional helper methods would continue here...
  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getWellnessColor(int wellness) {
    if (wellness >= 8) return Colors.green;
    if (wellness >= 6) return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> _getSmartTasks() {
    return [
      {
        'title': 'Review Today\'s Lessons',
        'description': 'Quick scan of lesson objectives and materials',
        'category': 'preparation',
        'estimatedMinutes': 5,
        'priority': 'high',
        'stressImpact': 'reduces planning anxiety',
      },
      {
        'title': 'Check Student Alerts',
        'description': 'Review any student-specific notes or concerns',
        'category': 'student_management',
        'estimatedMinutes': 3,
        'priority': 'medium',
        'stressImpact': 'prevents behavior surprises',
      },
      // Add more smart tasks...
    ];
  }

  Widget _buildSmartTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false, // You'd track this in state
            onChanged: (value) {
              // Handle task completion
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(task['description']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text('${task['estimatedMinutes']}min'),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(task['priority']),
                      backgroundColor: _getPriorityColor(
                        task['priority'],
                      ).withOpacity(0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getPersonalizedRecommendations() {
    return [
      {
        'title': 'Use AI Lesson Templates',
        'description': 'Reduce planning time by 70% with pre-built templates',
        'category': 'Time Saving',
        'action': 'generate_template',
      },
      {
        'title': 'Enable Smart Notifications',
        'description': 'Get reminders for important tasks and deadlines',
        'category': 'Organization',
        'action': 'setup_notifications',
      },
      // Add more recommendations...
    ];
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Action methods
  void _showStressAnalytics() {
    Navigator.pushNamed(context, '/stress-analytics');
  }

  void _startIntervention(String intervention) {
    // Implement intervention logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Starting: $intervention')));
  }

  void _generatePersonalizedTasks(StressAnalysisProvider stressProvider) async {
    // Generate AI-powered personalized tasks based on stress profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating personalized tasks...')),
    );
  }

  void _implementRecommendation(Map<String, dynamic> recommendation) {
    // Implement the specific recommendation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Implementing: ${recommendation['title']}')),
    );
  }

  void _startBreathingExercise() {
    // Start guided breathing exercise
    showDialog(
      context: context,
      builder: (context) => const BreathingExerciseDialog(),
    );
  }

  void _startMindfulMoment() {
    // Start mindfulness session
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting mindful moment...')));
  }

  void _startEnergyBoost() {
    // Start energy boosting activity
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting energy boost...')));
  }

  void _startFocusSession() {
    // Start focus enhancement session
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting focus session...')));
  }
}

// Breathing Exercise Dialog Widget
class BreathingExerciseDialog extends StatefulWidget {
  const BreathingExerciseDialog({super.key});

  @override
  State<BreathingExerciseDialog> createState() =>
      _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<BreathingExerciseDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInhaling = true;
  int _currentCycle = 0;
  final int _totalCycles = 5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isInhaling = false;
        });
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isInhaling = true;
          _currentCycle++;
        });
        if (_currentCycle < _totalCycles) {
          _animationController.forward();
        } else {
          Navigator.of(context).pop();
        }
      }
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        height: 420,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Breathing Exercise',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Cycle ${_currentCycle + 1} of $_totalCycles'),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      _isInhaling
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              _isInhaling ? 'Breathe In' : 'Breathe Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
