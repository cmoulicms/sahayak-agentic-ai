// screens/onboarding/onboarding_screen.dart
import 'package:Sahayak/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final List<String> _selectedClasses = [];
  final List<String> _selectedSubjects = [];
  String _selectedSyllabus = '';
  String _selectedMedium = '';
  String _schoolContext = '';
  final Map<String, int> _stressProfile = {};

  final List<String> _availableClasses = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  final List<String> _availableSubjects = [
    'Mathematics',
    'Science',
    'English',
    'Hindi',
    'Social Studies',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Computer Science',
    'Art',
    'Physical Education',
  ];

  final List<String> _syllabusTypes = [
    'CBSE',
    'ICSE',
    'State Board',
    'International Baccalaureate',
    'Cambridge',
    'Other',
  ];

  final List<String> _mediums = [
    'English',
    'Hindi',
    'Regional Language',
    'Bilingual',
  ];

  final List<String> _schoolContexts = [
    'Government School',
    'Private School',
    'International School',
    'Rural School',
    'Urban School',
    'Semi-Urban School',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final updates = {
      'classesHandling': _selectedClasses,
      'subjects': _selectedSubjects,
      'syllabusType': _selectedSyllabus,
      'medium': _selectedMedium,
      'schoolContext': _schoolContext,
      'stressProfile': _stressProfile,
      'lastActiveAt': DateTime.now().toIso8601String(),
    };

    await authProvider.updateTeacherProfile(updates);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${_currentPage + 1}/5'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: Colors.grey.shade300,
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildClassSelectionPage(),
                _buildSubjectSelectionPage(),
                _buildSchoolInfoPage(),
                _buildStressAssessmentPage(),
                _buildWelcomePage(),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextPage : null,
                    child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedClasses.isNotEmpty;
      case 1:
        return _selectedSubjects.isNotEmpty;
      case 2:
        return _selectedSyllabus.isNotEmpty &&
            _selectedMedium.isNotEmpty &&
            _schoolContext.isNotEmpty;
      case 3:
        return _stressProfile.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Widget _buildClassSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which classes do you teach?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select all the classes you currently handle',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _availableClasses.length,
              itemBuilder: (context, index) {
                final className = _availableClasses[index];
                final isSelected = _selectedClasses.contains(className);

                return FilterChip(
                  label: Text(className),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedClasses.add(className);
                      } else {
                        _selectedClasses.remove(className);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What subjects do you teach?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize content for you',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _availableSubjects.length,
              itemBuilder: (context, index) {
                final subject = _availableSubjects[index];
                final isSelected = _selectedSubjects.contains(subject);

                return CheckboxListTile(
                  title: Text(subject),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedSubjects.add(subject);
                      } else {
                        _selectedSubjects.remove(subject);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your school',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us provide relevant content',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Syllabus Type
          Text(
            'Curriculum/Syllabus',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _syllabusTypes.map((syllabus) {
              return ChoiceChip(
                label: Text(syllabus),
                selected: _selectedSyllabus == syllabus,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedSyllabus = syllabus);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Medium
          Text(
            'Medium of Instruction',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _mediums.map((medium) {
              return ChoiceChip(
                label: Text(medium),
                selected: _selectedMedium == medium,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedMedium = medium);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // School Context
          Text('School Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _schoolContexts.map((context) {
              return ChoiceChip(
                label: Text(context),
                selected: _schoolContext == context,
                onSelected: (selected) {
                  if (selected) setState(() => _schoolContext = context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStressAssessmentPage() {
    final stressFactors = {
      'workload': 'Heavy workload and long hours',
      'resources': 'Lack of teaching resources',
      'behavior': 'Student behavior management',
      'admin': 'Administrative tasks and paperwork',
      'parents': 'Parent-teacher communication',
      'technology': 'Keeping up with technology',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stress Assessment',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your challenges (1 = Low stress, 5 = High stress)',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: stressFactors.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            final rating = index + 1;
                            final isSelected =
                                _stressProfile[entry.key] == rating;

                            return GestureDetector(
                              onTap: () => setState(
                                () => _stressProfile[entry.key] = rating,
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$rating',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            'All Set! 🎉',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Sahayak! Your personalized teaching assistant is ready to help you with:',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFeaturePreview(
            Icons.wb_sunny,
            'Morning Preparation',
            'Start each day with a personalized 5-minute prep',
          ),
          _buildFeaturePreview(
            Icons.book,
            'Smart Lesson Plans',
            'AI-powered lesson planning tailored to your style',
          ),
          _buildFeaturePreview(
            Icons.class_,
            'In-Class Support',
            'Real-time assistance during teaching',
          ),
          _buildFeaturePreview(
            Icons.quiz,
            'Assessment Tools',
            'Quick quiz and worksheet generation',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
