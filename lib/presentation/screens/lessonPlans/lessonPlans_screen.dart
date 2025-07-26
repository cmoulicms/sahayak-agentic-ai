// screens/lesson_planning/lesson_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/data/models/lesson/enhanced_lesson_plan.dart';
import 'package:myapp/presentation/widgets/shayakCard.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



import '../../providers/lesson_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

class LessonPlanningScreen extends StatefulWidget {
  const LessonPlanningScreen({super.key});

  @override
  State<LessonPlanningScreen> createState() => _LessonPlanningScreenState();
}

class _LessonPlanningScreenState extends State<LessonPlanningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSubject = 'All';
  final LessonStatus _selectedStatus = LessonStatus.draft;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessonPlans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Lesson Planning'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create New', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'My Lessons', icon: Icon(Icons.library_books)),
            Tab(text: 'AI Assistant', icon: Icon(Icons.auto_awesome)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Text('Filter Lessons'),
              ),
              const PopupMenuItem(value: 'export', child: Text('Export Plans')),
              const PopupMenuItem(value: 'templates', child: Text('Templates')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateNewTab(),
          _buildMyLessonsTab(),
          _buildAIAssistantTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickCreateDialog,
        icon: const Icon(Icons.smart_toy),
        label: const Text('Quick AI Create'),
      ),
    );
  }

  Widget _buildCreateNewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Lesson Plan',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickCreateCards(),
          const SizedBox(height: 24),
          _buildDetailedCreateForm(),
        ],
      ),
    );
  }

  Widget _buildQuickCreateCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Start',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickCreateCard(
                'AI Generated',
                'Let AI create a complete lesson plan',
                Icons.auto_awesome,
                Colors.purple,
                () => _showQuickCreateDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickCreateCard(
                'From Template',
                'Start with a proven template',
                Icons.content_copy,
                Colors.blue,
                () => _showTemplateSelector(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickCreateCard(
                'Import Content',
                'Upload existing materials',
                Icons.upload_file,
                Colors.green,
                () => _showImportDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickCreateCard(
                'Blank Canvas',
                'Create from scratch',
                Icons.edit_note,
                Colors.orange,
                () => _createBlankLesson(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickCreateCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SahayakCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedCreateForm() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual Creation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildFormField('Subject', 'Select subject'),
            const SizedBox(height: 16),
            _buildFormField('Grade Level', 'Select grade'),
            const SizedBox(height: 16),
            _buildFormField('Topic', 'Enter lesson topic'),
            const SizedBox(height: 16),
            _buildFormField('Duration', 'Lesson duration (minutes)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createDetailedLesson,
                icon: const Icon(Icons.create),
                label: const Text('Create Lesson Plan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildMyLessonsTab() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(
            child: LoadingWidget(message: 'Loading lesson plans...'),
          );
        }

        if (lessonProvider.error != null) {
          return SahayakErrorWidget(
            error: lessonProvider.error!,
            onRetry: () => lessonProvider.loadLessonPlans(),
          );
        }

        final lessons = _getFilteredLessons(lessonProvider);

        return Column(
          children: [
            _buildFilterBar(lessonProvider),
            Expanded(
              child: lessons.isEmpty
                  ? _buildEmptyState()
                  : _buildLessonsList(lessons, lessonProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(LessonProvider lessonProvider) {
    final stats = lessonProvider.getLessonStatistics();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  stats['total'] ?? 0,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Draft',
                  stats['draft'] ?? 0,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Complete',
                  stats['completed'] ?? 0,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Subjects', _selectedSubject == 'All', () {
                  setState(() => _selectedSubject = 'All');
                }),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Mathematics',
                  _selectedSubject == 'Mathematics',
                  () {
                    setState(() => _selectedSubject = 'Mathematics');
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Science', _selectedSubject == 'Science', () {
                  setState(() => _selectedSubject = 'Science');
                }),
                const SizedBox(width: 8),
                _buildFilterChip('English', _selectedSubject == 'English', () {
                  setState(() => _selectedSubject = 'English');
                }),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Social Studies',
                  _selectedSubject == 'Social Studies',
                  () {
                    setState(() => _selectedSubject = 'Social Studies');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildLessonsList(
    List<EnhancedLessonPlan> lessons,
    LessonProvider lessonProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () => lessonProvider.loadLessonPlans(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonCard(lesson, lessonProvider);
        },
      ),
    );
  }

  Widget _buildLessonCard(
    EnhancedLessonPlan lesson,
    LessonProvider lessonProvider,
  ) {
    return SahayakCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _openLessonDetails(lesson),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.topic,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lesson.subject} • Grade ${lesson.gradeLevel} • ${lesson.estimatedDuration}min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(lesson.status),
              ],
            ),
            const SizedBox(height: 12),

            // Progress indicators
            Row(
              children: [
                _buildProgressIndicator(
                  'Objectives',
                  lesson.objectives.where((obj) => obj.isCompleted).length,
                  lesson.objectives.length,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildProgressIndicator(
                  'Activities',
                  lesson.activities.length,
                  lesson.activities.length,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildProgressIndicator(
                  'Resources',
                  lesson.resources.where((res) => res.isRequired).length,
                  lesson.resources.length,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editLesson(lesson),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => lessonProvider.duplicateLessonPlan(lesson),
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: const Text('Duplicate'),
                ),
                const Spacer(),
                Text(
                  'Updated ${_getRelativeTime(lesson.lastModified ?? lesson.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(LessonStatus status) {
    Color color;
    String label;

    switch (status) {
      case LessonStatus.draft:
        color = Colors.orange;
        label = 'Draft';
        break;
      case LessonStatus.inProgress:
        color = Colors.blue;
        label = 'In Progress';
        break;
      case LessonStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case LessonStatus.needsRevision:
        color = Colors.red;
        label = 'Needs Revision';
        break;
      case LessonStatus.approved:
        color = Colors.purple;
        label = 'Approved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    String label,
    int completed,
    int total,
    Color color,
  ) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$completed/$total',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIAssistantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Teaching Assistant',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Get intelligent suggestions and assistance for your lesson planning',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildAIFeatureCards(),
          const SizedBox(height: 24),
          _buildRecentAISuggestions(),
        ],
      ),
    );
  }

  Widget _buildAIFeatureCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAIFeatureCard(
                'Content Generator',
                'Generate lesson content, activities, and assessments',
                Icons.auto_awesome,
                Colors.purple,
                () => _showContentGenerator(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAIFeatureCard(
                'Curriculum Alignment',
                'Ensure lessons match curriculum standards',
                Icons.assignment_turned_in,
                Colors.blue,
                () => _showCurriculumAlignment(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAIFeatureCard(
                'Differentiation Helper',
                'Adapt content for different learning styles',
                Icons.diversity_3,
                Colors.green,
                () => _showDifferentiationHelper(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAIFeatureCard(
                'Assessment Builder',
                'Create quizzes and rubrics automatically',
                Icons.quiz,
                Colors.orange,
                () => _showAssessmentBuilder(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SahayakCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAISuggestions() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent AI Suggestions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(
              'Interactive Math Activity',
              'For Grade 8 Algebra lesson on linear equations',
              Icons.calculate,
              '2 hours ago',
            ),
            _buildSuggestionItem(
              'Science Experiment',
              'Hands-on chemistry lab for molecular structure',
              Icons.science,
              '1 day ago',
            ),
            _buildSuggestionItem(
              'Reading Comprehension',
              'Differentiated activities for various reading levels',
              Icons.menu_book,
              '2 days ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    String title,
    String description,
    IconData icon,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No lesson plans yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first lesson plan to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.add),
            label: const Text('Create Lesson Plan'),
          ),
        ],
      ),
    );
  }

  // Helper methods and dialog functions
  List<EnhancedLessonPlan> _getFilteredLessons(LessonProvider lessonProvider) {
    var lessons = lessonProvider.lessonPlans;

    if (_selectedSubject != 'All') {
      lessons = lessons
          .where((lesson) => lesson.subject == _selectedSubject)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      lessons = lessonProvider.searchLessonPlans(_searchController.text);
    }

    return lessons;
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Dialog and action methods
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Lessons'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const AIQuickCreateDialog(),
    );
  }

  void _showTemplateSelector() {
    // Implementation for template selector
  }

  void _showImportDialog() {
    // Implementation for import dialog
  }

  void _createBlankLesson() {
    // Implementation for creating blank lesson
  }

  void _createDetailedLesson() {
    // Implementation for detailed lesson creation
  }

  void _openLessonDetails(EnhancedLessonPlan lesson) {
    // Navigate to lesson details screen
  }

  void _editLesson(EnhancedLessonPlan lesson) {
    // Navigate to lesson editing screen
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        // Show filter options
        break;
      case 'export':
        // Export lesson plans
        break;
      case 'templates':
        // Show templates
        break;
    }
  }

  void _showContentGenerator() {
    // Implementation for content generator
  }

  void _showCurriculumAlignment() {
    // Implementation for curriculum alignment
  }

  void _showDifferentiationHelper() {
    // Implementation for differentiation helper
  }

  void _showAssessmentBuilder() {
    // Implementation for assessment builder
  }
}

// Quick Create Dialog Widget
class AIQuickCreateDialog extends StatefulWidget {
  const AIQuickCreateDialog({super.key});

  @override
  State<AIQuickCreateDialog> createState() => _AIQuickCreateDialogState();
}

class _AIQuickCreateDialogState extends State<AIQuickCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _gradeController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Quick Create',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Mathematics, Science',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText: 'e.g., Linear Equations, Photosynthesis',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        hintText: '8',
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        hintText: '45',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  Consumer<LessonProvider>(
                    builder: (context, lessonProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: lessonProvider.isGeneratingLesson
                            ? null
                            : () => _generateLesson(context, lessonProvider),
                        icon: lessonProvider.isGeneratingLesson
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          lessonProvider.isGeneratingLesson
                              ? 'Generating...'
                              : 'Generate',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateLesson(
    BuildContext context,
    LessonProvider lessonProvider,
  ) async {
    if (_formKey.currentState?.validate() == true) {
      final lessonPlan = await lessonProvider.generateLessonPlan(
        subject: _subjectController.text,
        topic: _topicController.text,
        gradeLevel: _gradeController.text,
        duration: int.tryParse(_durationController.text) ?? 45,
      );

      if (mounted) {
        Navigator.pop(context);
        if (lessonPlan != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lesson plan generated successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate lesson plan')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _gradeController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
