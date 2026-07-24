import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/course_model.dart';
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/profile_avatar.dart';
import 'student_submit_assignment_screen.dart';
import 'student_course_modules_screen.dart';
import 'student_reviews_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabTitles = [
    'Dashboard',
    'My Courses',
    'Assignments',
    'Profile',
  ];

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      drawer: AppDrawer(
        currentRole: AppConstants.roleStudent,
        currentIndex: _currentIndex,
        onNavigate: _navigateToTab,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(onNavigate: _navigateToTab),
          const _CoursesTab(),
          const _AssignmentsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = context.watch<AuthProvider>().currentUser;
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabTitles[_currentIndex],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (_currentIndex == 0)
            Text(
              'Welcome back, ${user?.firstName ?? "Student"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.rate_review_outlined,
              color: AppColors.textSecondary),
          tooltip: 'My Reviews',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentReviewsScreen(),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileAvatar(
              imageUrl: user?.profilePicture,
              initials: user != null
                  ? '${user.firstName[0]}${user.lastName[0]}'
                  : 'S',
              size: 36,
              backgroundColor: AppColors.primaryGreen,
              editable: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _navigateToTab,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Assignments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ============================================================
// TAB 1: DASHBOARD
// ============================================================

class _DashboardTab extends StatelessWidget {
  final void Function(int index) onNavigate;

  const _DashboardTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingDashboard) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => provider.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(context, provider),
                const SizedBox(height: 24),
                _buildStatsGrid(context, provider),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  title: 'Enrolled Courses',
                  actionLabel: 'View All',
                  onAction: () => onNavigate(1),
                ),
                const SizedBox(height: 12),
                _buildEnrolledCoursesList(context, provider),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  title: 'Recent Assignments',
                  actionLabel: 'View All',
                  onAction: () => onNavigate(2),
                ),
                const SizedBox(height: 12),
                _buildRecentAssignments(context, provider),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  title: 'Recent Reviews',
                  actionLabel: 'View All',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StudentReviewsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildRecentReviews(context, provider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, StudentProvider provider) {
    final dashData = provider.dashboardData;
    final studentData = dashData?['student'];
    final vocation =
        studentData?['vocation']?.toString() ?? 'Vocational Program';
    final level = studentData?['level']?.toString() ?? '';
    final department = studentData?['department']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded,
                    color: AppColors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocation,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (department.isNotEmpty || level.isNotEmpty)
                      Text(
                        '$department'
                        '${department.isNotEmpty && level.isNotEmpty ? ' · ' : ''}'
                        '$level',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.totalEnrollments} '
              'Course${provider.totalEnrollments != 1 ? 's' : ''} Enrolled',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, StudentProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context,
          icon: Icons.menu_book_rounded,
          label: 'Enrolled',
          value: provider.totalEnrollments.toString(),
          color: AppColors.primaryGreen,
          onTap: () => onNavigate(1),
        ),
        _buildStatCard(
          context,
          icon: Icons.check_circle_rounded,
          label: 'Completed',
          value: provider.completedCourses.toString(),
          color: AppColors.success,
          onTap: () => onNavigate(1),
        ),
        _buildStatCard(
          context,
          icon: Icons.assignment_outlined,
          label: 'Assignments',
          value: provider.pendingAssignments.toString(),
          color: AppColors.orange,
          onTap: () => onNavigate(2),
        ),
        _buildStatCard(
          context,
          icon: Icons.grade_rounded,
          label: 'Graded',
          value: provider.gradedAssignments.toString(),
          color: AppColors.gold,
          onTap: () => onNavigate(2),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEnrolledCoursesList(
    BuildContext context,
    StudentProvider provider,
  ) {
    if (provider.isLoadingCourses) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (provider.enrolledCourses.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.menu_book_outlined,
        message: 'No enrolled courses yet.\nGo to Courses tab to enroll.',
      );
    }

    return Column(
      children: provider.enrolledCourses
          .take(3)
          .map((course) => _buildDashCourseCard(context, course))
          .toList(),
    );
  }

  Widget _buildDashCourseCard(BuildContext context, CourseModel course) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudentCourseModulesScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.moduleCount ?? 0} '
                      'module${(course.moduleCount ?? 0) != 1 ? 's' : ''} · Tap to open',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssignments(
    BuildContext context,
    StudentProvider provider,
  ) {
    if (provider.isLoadingAssignments) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (provider.assignments.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.assignment_outlined,
        message: 'No assignments yet.',
      );
    }

    return Column(
      children: provider.assignments.take(3).map((assignment) {
        SubmissionModel? submission;
        for (final s in provider.submissions) {
          if (s.assignmentId == assignment.id) {
            submission = s;
            break;
          }
        }
        return _buildDashAssignmentCard(
          context,
          assignment,
          submission,
          provider,
        );
      }).toList(),
    );
  }

  Widget _buildDashAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
    SubmissionModel? submission,
    StudentProvider provider,
  ) {
    final bool isGraded = submission?.isGraded ?? false;
    final bool isSubmitted = submission != null;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isGraded) {
      statusColor = AppColors.success;
      statusText = 'Graded';
      statusIcon = Icons.grade_rounded;
    } else if (isSubmitted) {
      statusColor = AppColors.blue;
      statusText = 'Submitted';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = AppColors.orange;
      statusText = 'Pending';
      statusIcon = Icons.pending_outlined;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isGraded
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentSubmitAssignmentScreen(
                      assignment: assignment,
                      provider: provider,
                      existingSubmission: submission,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Max: ${assignment.maxScore.toInt()}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (isGraded &&
                            submission != null &&
                            submission.score != null) ...[
                          Text(
                            ' · Score: ${submission.score!.toInt()}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReviews(BuildContext context, StudentProvider provider) {
    final gradedWithFeedback = provider.submissions
        .where((s) => s.isGraded && s.feedback != null)
        .take(2)
        .toList();

    if (gradedWithFeedback.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.rate_review_outlined,
        message: 'No reviews yet.\nGraded assignments will appear here.',
      );
    }

    return Column(
      children: gradedWithFeedback.map((submission) {
        AssignmentModel? assignment;
        for (final a in provider.assignments) {
          if (a.id == submission.assignmentId) {
            assignment = a;
            break;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.grade_rounded,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment?.title ?? 'Assignment',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (submission.score != null && assignment != null) ...[
                          Text(
                            'Score: ${submission.score!.toInt()}'
                            '/${assignment.maxScore.toInt()}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (submission.feedback != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.feedback_outlined,
                        size: 14,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          submission.feedback!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 2: COURSES
// ============================================================

class _CoursesTab extends StatefulWidget {
  const _CoursesTab();

  @override
  State<_CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<_CoursesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryGreen,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Available'),
              Tab(text: 'Enrolled'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AvailableCoursesView(),
              _EnrolledCoursesView(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailableCoursesView extends StatelessWidget {
  const _AvailableCoursesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingCourses) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (provider.availableCourses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses available\nfor your vocation yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => provider.loadAvailableCourses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: provider.availableCourses.length,
            itemBuilder: (context, index) {
              final course = provider.availableCourses[index];
              final isEnrolled =
                  provider.enrolledCourses.any((e) => e.id == course.id);
              return _buildAvailableCourseCard(
                context,
                course,
                isEnrolled,
                provider,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvailableCourseCard(
    BuildContext context,
    CourseModel course,
    bool isEnrolled,
    StudentProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: isEnrolled
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.layers_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.moduleCount ?? 0} modules',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrollmentCount ?? 0} enrolled',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (course.description != null &&
                course.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                course.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isEnrolled
                  ? OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StudentCourseModulesScreen(
                              course: course,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Open Course'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _handleEnroll(context, course, provider),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Enroll Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEnroll(
    BuildContext context,
    CourseModel course,
    StudentProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Enroll in Course'),
        content: Text(
          'Enroll in "${course.title}"?\n\n'
          'You will get access to all course modules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Enroll'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.enrollInCourse(course.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Successfully enrolled in ${course.title}'
                  : provider.errorMessage ?? 'Enrollment failed',
            ),
            backgroundColor:
                success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

class _EnrolledCoursesView extends StatelessWidget {
  const _EnrolledCoursesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingCourses) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (provider.enrolledCourses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.library_books_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'You have not enrolled in any courses yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => provider.loadEnrolledCourses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: provider.enrolledCourses.length,
            itemBuilder: (context, index) {
              return _buildEnrolledCard(
                context,
                provider.enrolledCourses[index],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnrolledCard(BuildContext context, CourseModel course) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCourseModules(context, course),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_lesson_rounded,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.moduleCount ?? 0} modules · Tap to study',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCourseModules(BuildContext context, CourseModel course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentCourseModulesScreen(course: course),
      ),
    );
  }
}

// ============================================================
// TAB 3: ASSIGNMENTS
// ============================================================

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingAssignments) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (provider.assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No assignments yet.\n'
                  'Enroll in courses to see assignments.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            await provider.loadAssignments();
            await provider.loadSubmissions();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: provider.assignments.length,
            itemBuilder: (context, index) {
              final AssignmentModel assignment = provider.assignments[index];
              SubmissionModel? submission;
              for (final s in provider.submissions) {
                if (s.assignmentId == assignment.id) {
                  submission = s;
                  break;
                }
              }
              return _buildAssignmentCard(
                context,
                assignment,
                submission,
                provider,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
    SubmissionModel? submission,
    StudentProvider provider,
  ) {
    final bool isGraded = submission?.isGraded ?? false;
    final bool isSubmitted = submission != null;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isGraded) {
      statusColor = AppColors.success;
      statusText = 'Graded';
      statusIcon = Icons.grade_rounded;
    } else if (isSubmitted) {
      statusColor = AppColors.blue;
      statusText = 'Submitted';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = AppColors.orange;
      statusText = 'Pending';
      statusIcon = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: isGraded
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (assignment.description != null &&
                              assignment.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              assignment.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.gold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Max: ${assignment.maxScore.toInt()} pts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.goldDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              if (isGraded &&
                                  submission != null &&
                                  submission.score != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Score: ${submission.score!.toInt()}'
                                    '/${assignment.maxScore.toInt()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                if (isGraded &&
                    submission != null &&
                    submission.feedback != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.feedback_outlined,
                          size: 16,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Feedback: ${submission.feedback}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isSubmitted &&
                    submission != null &&
                    submission.submissionText != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your submission:',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          submission.submissionText!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isGraded) ...[
            const Divider(height: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _openSubmitScreen(
                  context,
                  assignment,
                  provider,
                  existingSubmission: submission,
                ),
                icon: Icon(
                  isSubmitted
                      ? Icons.edit_note_rounded
                      : Icons.upload_file_outlined,
                  size: 18,
                ),
                label:
                    Text(isSubmitted ? 'Edit Submission' : 'Submit Assignment'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openSubmitScreen(
    BuildContext context,
    AssignmentModel assignment,
    StudentProvider provider, {
    SubmissionModel? existingSubmission,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentSubmitAssignmentScreen(
          assignment: assignment,
          provider: provider,
          existingSubmission: existingSubmission,
        ),
      ),
    );
  }
}

// ============================================================
// TAB 4: PROFILE
// ============================================================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: ProfileAvatar(
              imageUrl: user?.profilePicture,
              initials: user != null
                  ? '${user.firstName[0]}${user.lastName[0]}'
                  : 'S',
              size: 100,
              backgroundColor: AppColors.primaryGreen,
              editable: true,
              isTutor: false,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Student',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Student',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the camera icon to update your photo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(context, [
            _buildInfoRow(
              context,
              icon: Icons.badge_outlined,
              label: 'Matric Number',
              value: user?.matricNumber ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user?.phoneNumber ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              icon: Icons.school_outlined,
              label: 'Academic Level',
              value: user?.academicLevel ?? 'N/A',
            ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(context, [
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: _formatDate(user?.createdAt),
            ),
            _buildInfoRow(
              context,
              icon: Icons.verified_outlined,
              label: 'Account Status',
              value: (user?.isActive ?? false) ? 'Active' : 'Inactive',
              valueColor: (user?.isActive ?? false)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map(
              (entry) => Column(
                children: [
                  entry.value,
                  if (entry.key < rows.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}