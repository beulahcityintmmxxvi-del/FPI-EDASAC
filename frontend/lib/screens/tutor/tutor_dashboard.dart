import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tutor_provider.dart';
import '../../models/course_model.dart';
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';
import '../../models/vocation_model.dart';
import '../../services/tutor_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/profile_avatar.dart';
import 'tutor_manage_course_screen.dart';
import 'package:file_picker/file_picker.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabTitles = [
    'Dashboard',
    'My Courses',
    'Assignments',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      drawer: AppDrawer(
        currentRole: AppConstants.roleTutor,
        currentIndex: _currentIndex,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TutorDashboardTab(),
          _TutorCoursesTab(),
          _TutorAssignmentsTab(),
          _TutorProfileTab(),
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
              'Welcome, ${user?.firstName ?? "Tutor"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileAvatar(
              imageUrl: user?.profilePicture,
              initials: user != null
                  ? '${user.firstName[0]}${user.lastName[0]}'
                  : 'T',
              size: 36,
              backgroundColor: AppColors.blue,
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
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.blue,
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
// TAB 1: DASHBOARD  (unchanged from your original)
// ============================================================

class _TutorDashboardTab extends StatelessWidget {
  const _TutorDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingDashboard) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.blue));
        }
        return RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () => provider.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeBanner(context, provider),
                const SizedBox(height: 24),
                _sectionHeader(context, 'Overview'),
                const SizedBox(height: 12),
                _statsGrid(context, provider),
                const SizedBox(height: 24),
                _sectionHeader(context, 'My Courses'),
                const SizedBox(height: 12),
                _coursesList(context, provider),
                const SizedBox(height: 24),
                if (provider.pendingGrading > 0) ...[
                  _sectionHeader(context, 'Grading Required'),
                  const SizedBox(height: 12),
                  _gradingAlert(context, provider),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _welcomeBanner(BuildContext context, TutorProvider p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
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
                  color: AppColors.white.withOpacity(0.2),
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
                      'Tutor Portal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'EDASAC · ${AppConstants.appTagline}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withOpacity(0.85),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _bannerStat(context, 'Courses', p.totalCourses.toString()),
              const SizedBox(width: 12),
              _bannerStat(context, 'Published', p.publishedCourses.toString()),
              const SizedBox(width: 12),
              _bannerStat(
                  context, 'Assignments', p.totalAssignments.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(BuildContext ctx, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text(label,
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.85), fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String title) => Text(
        title,
        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      );

  Widget _statsGrid(BuildContext ctx, TutorProvider p) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard(ctx, Icons.menu_book_rounded, 'Total Courses',
            p.totalCourses.toString(), AppColors.blue),
        _statCard(ctx, Icons.layers_rounded, 'Total Modules',
            p.totalModules.toString(), AppColors.primaryGreen),
        _statCard(ctx, Icons.assignment_rounded, 'Assignments',
            p.totalAssignments.toString(), AppColors.orange),
        _statCard(
            ctx,
            Icons.grading_rounded,
            'Pending Grading',
            p.pendingGrading.toString(),
            p.pendingGrading > 0 ? AppColors.red : AppColors.success),
      ],
    );
  }

  Widget _statCard(BuildContext ctx, IconData icon, String label, String value,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: Theme.of(ctx)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              Text(label,
                  style: Theme.of(ctx)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coursesList(BuildContext ctx, TutorProvider p) {
    if (p.isLoadingCourses) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.blue));
    }
    if (p.courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Column(children: [
          Icon(Icons.menu_book_outlined,
              size: 48, color: AppColors.textTertiary),
          SizedBox(height: 12),
          Text('No courses yet.\nGo to "My Courses" to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    return Column(
      children: p.courses.take(3).map((c) => _dashCourseCard(ctx, c)).toList(),
    );
  }

  Widget _dashCourseCard(BuildContext ctx, CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: Theme.of(ctx)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    '${course.moduleCount ?? 0} modules · '
                    '${course.enrollmentCount ?? 0} students',
                    style: Theme.of(ctx)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: course.isPublished
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(course.isPublished ? 'Published' : 'Draft',
                style: TextStyle(
                    color: course.isPublished
                        ? AppColors.success
                        : AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _gradingAlert(BuildContext ctx, TutorProvider p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grading_rounded,
                color: AppColors.orange, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${p.pendingGrading} Submission'
                    '${p.pendingGrading != 1 ? 's' : ''} to Grade',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.orange)),
                Text('Go to Assignments to review and grade',
                    style: Theme.of(ctx)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 2: COURSES  ← REWORKED with tap-to-manage and edit
// ============================================================

class _TutorCoursesTab extends StatelessWidget {
  const _TutorCoursesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingCourses) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.blue));
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateCourseDialog(context, provider),
            backgroundColor: AppColors.blue,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: const Text('New Course',
                style: TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
          body: provider.courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined,
                          size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'No courses yet.\nTap + to create your first course.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.blue,
                  onRefresh: () => provider.loadCourses(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: provider.courses.length,
                    itemBuilder: (context, index) => _buildCourseCard(
                      context,
                      provider.courses[index],
                      provider,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    CourseModel course,
    TutorProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _openManageScreen(context, course),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: course.isPublished
                ? AppColors.success.withOpacity(0.3)
                : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2)),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: AppColors.blue, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                            '${course.moduleCount ?? 0} modules · '
                            '${course.enrollmentCount ?? 0} students',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleCourseAction(context, value, course, provider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'manage',
                        child: Row(children: [
                          Icon(Icons.layers_outlined,
                              size: 18, color: AppColors.blue),
                          SizedBox(width: 8),
                          Text('Manage Modules'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.blue),
                          SizedBox(width: 8),
                          Text('Edit Course'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: course.isPublished ? 'unpublish' : 'publish',
                        child: Row(children: [
                          Icon(
                            course.isPublished
                                ? Icons.unpublished_outlined
                                : Icons.publish_rounded,
                            size: 18,
                            color: course.isPublished
                                ? AppColors.orange
                                : AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(course.isPublished ? 'Unpublish' : 'Publish'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              if (course.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                Text(course.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: course.isPublished
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.isPublished ? '● Published' : '○ Draft',
                      style: TextStyle(
                        color: course.isPublished
                            ? AppColors.success
                            : AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openManageScreen(BuildContext context, CourseModel course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TutorManageCourseScreen(course: course),
      ),
    );
  }

  Future<void> _handleCourseAction(
    BuildContext context,
    String action,
    CourseModel course,
    TutorProvider provider,
  ) async {
    if (action == 'manage') {
      _openManageScreen(context, course);
    } else if (action == 'edit') {
      _showEditCourseDialog(context, course, provider);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Course'),
          content: Text('Delete "${course.title}"? This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await provider.deleteCourse(course.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Course deleted'
                  : provider.errorMessage ?? 'Failed to delete'),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    } else if (action == 'publish' || action == 'unpublish') {
      final success = await provider.updateCourse(
        courseId: course.id,
        isPublished: action == 'publish',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Course ${action}ed successfully'
                : provider.errorMessage ?? 'Update failed'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showCreateCourseDialog(
    BuildContext context,
    TutorProvider provider,
  ) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedVocationId;
    bool isLoading = false;
    List<VocationModel> vocations = [];

    final tutorService = TutorService();
    final vocationResponse = await tutorService.getVocations();
    if (vocationResponse.success && vocationResponse.data != null) {
      vocations = vocationResponse.data!;
    }
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create New Course'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Course Title', hintText: 'Enter title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedVocationId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vocation'),
                    items: vocations
                        .map((v) => DropdownMenuItem<int>(
                              value: v.id,
                              child:
                                  Text(v.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedVocationId = v),
                    validator: (v) =>
                        v == null ? 'Please select a vocation' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      final success = await provider.createCourse(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        vocationId: selectedVocationId!,
                        isPublished: false,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Course created successfully'
                                : provider.errorMessage ??
                                    'Failed to create course'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
    });
  }

  Future<void> _showEditCourseDialog(
    BuildContext context,
    CourseModel course,
    TutorProvider provider,
  ) async {
    final titleController = TextEditingController(text: course.title);
    final descController = TextEditingController(text: course.description);
    final formKey = GlobalKey<FormState>();
    int? selectedVocationId = course.vocationId;
    bool isLoading = false;
    List<VocationModel> vocations = [];

    final tutorService = TutorService();
    final vocationResponse = await tutorService.getVocations();
    if (vocationResponse.success && vocationResponse.data != null) {
      vocations = vocationResponse.data!;
    }
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Course'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Course Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedVocationId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vocation'),
                    items: vocations
                        .map((v) => DropdownMenuItem<int>(
                              value: v.id,
                              child:
                                  Text(v.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedVocationId = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      final success = await provider.updateCourse(
                        courseId: course.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        vocationId: selectedVocationId,
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Course updated'
                                : provider.errorMessage ?? 'Update failed'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
    });
 }
}

// ============================================================
// TAB 3: ASSIGNMENTS  (edit/delete + attachment support)
// ============================================================

class _TutorAssignmentsTab extends StatelessWidget {
  const _TutorAssignmentsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingAssignments) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.blue));
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateAssignmentDialog(context, provider),
            backgroundColor: AppColors.blue,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: const Text('New Assignment',
                style: TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
          body: provider.assignments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('No assignments yet.\nTap + to create one.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.blue,
                  onRefresh: () => provider.loadAssignments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: provider.assignments.length,
                    itemBuilder: (context, index) => _buildAssignmentCard(
                        context, provider.assignments[index], provider),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
    TutorProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2))
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_rounded,
                      color: AppColors.blue, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                'Max: ${assignment.maxScore.toInt()} pts',
                                style: const TextStyle(
                                    color: AppColors.goldDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (assignment.submissionCount != null) ...[
                            const SizedBox(width: 8),
                            Text(
                                '${assignment.submissionCount} submission'
                                '${assignment.submissionCount != 1 ? 's' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAssignmentAction(
                      context, value, assignment, provider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.blue),
                        SizedBox(width: 8),
                        Text('Edit Assignment'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: assignment.hasAttachment
                          ? 'replace_attachment'
                          : 'add_attachment',
                      child: Row(children: [
                        Icon(Icons.attach_file_rounded,
                            size: 18, color: AppColors.blue),
                        const SizedBox(width: 8),
                        Text(assignment.hasAttachment
                            ? 'Replace Attachment'
                            : 'Add Attachment'),
                      ]),
                    ),
                    if (assignment.hasAttachment)
                      const PopupMenuItem(
                        value: 'remove_attachment',
                        child: Row(children: [
                          Icon(Icons.link_off_rounded,
                              size: 18, color: AppColors.orange),
                          SizedBox(width: 8),
                          Text('Remove Attachment'),
                        ]),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            if (assignment.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 10),
              Text(assignment.description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
            if (assignment.hasAttachment) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded,
                        size: 16, color: AppColors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assignment.attachmentName ?? 'Attachment',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (assignment.attachmentSize != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${assignment.attachmentSizeMb.toStringAsFixed(1)} MB',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if ((assignment.submissionCount ?? 0) > 0) ...[
              const Divider(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _viewSubmissions(context, assignment, provider),
                  icon: const Icon(Icons.grading_rounded, size: 18),
                  label: const Text('View & Grade Submissions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: const BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleAssignmentAction(
    BuildContext context,
    String action,
    AssignmentModel assignment,
    TutorProvider provider,
  ) async {
    switch (action) {
      case 'edit':
        _showEditAssignmentDialog(context, assignment, provider);
        break;
      case 'add_attachment':
      case 'replace_attachment':
        _pickAndUploadAttachment(context, assignment, provider);
        break;
      case 'remove_attachment':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Remove Attachment'),
            content: Text(
              'Remove "${assignment.attachmentName ?? "attachment"}" '
              'from this assignment?',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.orange),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final ok = await provider.deleteAssignmentAttachment(assignment.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Attachment removed'
                    : provider.errorMessage ?? 'Failed to remove'),
                backgroundColor: ok ? AppColors.success : AppColors.error,
              ),
            );
          }
        }
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Assignment'),
            content: Text(
              'Delete "${assignment.title}" and all its submissions? '
              'This cannot be undone.',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final ok = await provider.deleteAssignment(assignment.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Assignment deleted'
                    : provider.errorMessage ?? 'Delete failed'),
                backgroundColor: ok ? AppColors.success : AppColors.error,
              ),
            );
          }
        }
        break;
    }
  }

  Future<void> _pickAndUploadAttachment(
    BuildContext context,
    AssignmentModel assignment,
    TutorProvider provider,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        ...AppConstants.allowedVideoExtensions,
        ...AppConstants.allowedImageExtensions,
        ...AppConstants.allowedDocumentExtensions,
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read file bytes.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ext = file.name.split('.').last.toLowerCase();
    int limitMb;
    if (AppConstants.allowedVideoExtensions.contains(ext)) {
      limitMb = AppConstants.maxVideoSizeMB;
    } else if (AppConstants.allowedImageExtensions.contains(ext)) {
      limitMb = AppConstants.maxImageSizeMB;
    } else if (ext == 'pdf') {
      limitMb = AppConstants.maxPdfSizeMB;
    } else {
      limitMb = AppConstants.maxDocumentSizeMB;
    }
    if (file.size > limitMb * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File too large. Max ${limitMb}MB for .$ext'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ok = await provider.uploadAssignmentAttachment(
      assignmentId: assignment.id,
      fileBytes: file.bytes!,
      fileName: file.name,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Attachment uploaded'
              : provider.errorMessage ?? 'Upload failed'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _viewSubmissions(
    BuildContext context,
    AssignmentModel assignment,
    TutorProvider provider,
  ) async {
    await provider.loadSubmissions(assignment.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _SubmissionsBottomSheet(
          assignment: assignment,
          provider: provider,
          scrollController: scrollController,
        ),
      ),
    );
  }

  // ==================== CREATE / EDIT DIALOGS ====================

  Future<void> _showCreateAssignmentDialog(
    BuildContext context,
    TutorProvider provider,
  ) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final scoreController = TextEditingController(text: '100');
    final formKey = GlobalKey<FormState>();
    int? selectedCourseId;
    String selectedType = 'practical';
    PlatformFile? pickedFile;
    bool isLoading = false;

    const assignmentTypes = [
      {'value': 'practical', 'label': 'Practical'},
      {'value': 'theory', 'label': 'Theory'},
      {'value': 'project', 'label': 'Project'},
      {'value': 'quiz', 'label': 'Quiz'},
    ];

    Future<void> pickFile(void Function(void Function()) setDialogState) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          ...AppConstants.allowedVideoExtensions,
          ...AppConstants.allowedImageExtensions,
          ...AppConstants.allowedDocumentExtensions,
        ],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setDialogState(() => pickedFile = result.files.first);
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create Assignment'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedCourseId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Course'),
                      items: provider.courses
                          .map((c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.title,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedCourseId = v),
                      validator: (v) =>
                          v == null ? 'Please select a course' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Assignment Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Assignment Type'),
                      items: assignmentTypes
                          .map((t) => DropdownMenuItem<String>(
                                value: t['value'],
                                child: Text(t['label']!),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedType = v ?? 'practical'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: scoreController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Maximum Score'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final s = double.tryParse(v);
                        if (s == null || s <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Attachment picker
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_file_rounded,
                                  size: 16, color: AppColors.blue),
                              const SizedBox(width: 6),
                              const Text('Attachment (optional)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (pickedFile == null)
                            OutlinedButton.icon(
                              onPressed: () => pickFile(setDialogState),
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Choose file'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.blue,
                                side: const BorderSide(color: AppColors.blue),
                                minimumSize: const Size(double.infinity, 40),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(pickedFile!.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        '${(pickedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 18, color: AppColors.error),
                                  onPressed: () =>
                                      setDialogState(() => pickedFile = null),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (provider.isUploading) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: provider.uploadProgress,
                        backgroundColor: AppColors.blue.withOpacity(0.15),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.blue),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      final bool ok;
                      if (pickedFile != null && pickedFile!.bytes != null) {
                        ok = await provider.createAssignmentWithAttachment(
                          courseId: selectedCourseId!,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          maxScore: double.parse(scoreController.text),
                          assignmentType: selectedType,
                          fileBytes: pickedFile!.bytes!,
                          fileName: pickedFile!.name,
                        );
                      } else {
                        ok = await provider.createAssignment(
                          courseId: selectedCourseId!,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          maxScore: double.parse(scoreController.text),
                          assignmentType: selectedType,
                        );
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Assignment created'
                                : provider.errorMessage ?? 'Failed to create'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
      scoreController.dispose();
    });
  }

  Future<void> _showEditAssignmentDialog(
    BuildContext context,
    AssignmentModel assignment,
    TutorProvider provider,
  ) async {
    final titleController = TextEditingController(text: assignment.title);
    final descController =
        TextEditingController(text: assignment.description ?? '');
    final scoreController =
        TextEditingController(text: assignment.maxScore.toInt().toString());
    final formKey = GlobalKey<FormState>();
    String selectedType = assignment.assignmentType ?? 'practical';
    bool isLoading = false;

    const assignmentTypes = [
      {'value': 'practical', 'label': 'Practical'},
      {'value': 'theory', 'label': 'Theory'},
      {'value': 'project', 'label': 'Project'},
      {'value': 'quiz', 'label': 'Quiz'},
    ];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Assignment'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Assignment Type'),
                    items: assignmentTypes
                        .map((t) => DropdownMenuItem<String>(
                              value: t['value'],
                              child: Text(t['label']!),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedType = v ?? 'practical'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Maximum Score'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final s = double.tryParse(v);
                      if (s == null || s <= 0) return 'Invalid';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      final ok = await provider.updateAssignment(
                        assignmentId: assignment.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        maxScore: double.parse(scoreController.text),
                        assignmentType: selectedType,
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Assignment updated'
                                : provider.errorMessage ?? 'Update failed'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
      scoreController.dispose();
    });
 }
}

// ── Submissions Bottom Sheet (unchanged from original) ──────

class _SubmissionsBottomSheet extends StatelessWidget {
  final AssignmentModel assignment;
  final TutorProvider provider;
  final ScrollController scrollController;

  const _SubmissionsBottomSheet({
    required this.assignment,
    required this.provider,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorProvider>(
      builder: (context, prov, _) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: Text(
                    'Submissions · ${assignment.title}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${prov.currentSubmissions.length}',
                      style: const TextStyle(
                          color: AppColors.blue, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: prov.currentSubmissions.isEmpty
                  ? const Center(child: Text('No submissions yet.'))
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: prov.currentSubmissions.length,
                      itemBuilder: (context, index) => _buildSubmissionCard(
                          context, prov.currentSubmissions[index], prov),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    SubmissionModel submission,
    TutorProvider provider,
  ) {
    final isGraded = submission.isGraded;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGraded
              ? AppColors.success.withOpacity(0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2)),
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
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'S${submission.studentId}',
                    style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student #${submission.studentId}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(_formatDate(submission.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGraded
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGraded ? 'Graded: ${submission.score?.toInt()}' : 'Pending',
                  style: TextStyle(
                    color: isGraded ? AppColors.success : AppColors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (submission.submissionText?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                submission.submissionText!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (submission.fileName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(submission.fileName!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          if (isGraded && submission.feedback != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.blue.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.feedback_outlined,
                      size: 14, color: AppColors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(submission.feedback!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            )),
                  ),
                ],
              ),
            ),
          ],
          if (!isGraded) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showGradeDialog(context, submission, provider),
                icon: const Icon(Icons.grading_rounded, size: 18),
                label: const Text('Grade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showGradeDialog(
    BuildContext context,
    SubmissionModel submission,
    TutorProvider provider,
  ) async {
    final scoreController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Grade Submission'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Score (Max: ${assignment.maxScore.toInt()})',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final s = double.tryParse(v);
                    if (s == null) return 'Invalid number';
                    if (s < 0 || s > assignment.maxScore) {
                      return 'Score must be 0 - ${assignment.maxScore.toInt()}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      final success = await provider.gradeSubmission(
                        submissionId: submission.id,
                        score: double.parse(scoreController.text),
                        feedback: feedbackController.text.trim(),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Submission graded successfully'
                                : provider.errorMessage ?? 'Grading failed'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Grade'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
    scoreController.dispose();
    feedbackController.dispose();
  });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ============================================================
// TAB 4: PROFILE  (unchanged from your original)
// ============================================================

class _TutorProfileTab extends StatelessWidget {
  const _TutorProfileTab();

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
                  : 'T',
              size: 100,
              backgroundColor: AppColors.blue,
              editable: true,
              isTutor: true,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Tutor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Tutor',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.blue, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text('Tap the camera icon to update your photo',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 24),
          _buildInfoCard(context, [
            _buildInfoRow(context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: user?.email ?? 'N/A'),
            _buildInfoRow(context,
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user?.phoneNumber ?? 'N/A'),
            _buildInfoRow(context,
                icon: Icons.star_outline,
                label: 'Specialization',
                value: user?.specialization ?? 'N/A'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(context, [
            _buildInfoRow(context,
                icon: Icons.calendar_today_outlined,
                label: 'Member Since',
                value: _formatDate(user?.createdAt)),
            _buildInfoRow(context,
                icon: Icons.verified_outlined,
                label: 'Account Status',
                value: (user?.isActive ?? false) ? 'Active' : 'Inactive',
                valueColor: (user?.isActive ?? false)
                    ? AppColors.success
                    : AppColors.error),
            _buildInfoRow(context,
                icon: Icons.approval_outlined,
                label: 'Approval Status',
                value: (user?.isApproved ?? false) ? 'Approved' : 'Pending',
                valueColor: (user?.isApproved ?? false)
                    ? AppColors.success
                    : AppColors.orange),
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
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((entry) => Column(children: [
                  entry.value,
                  if (entry.key < rows.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ]))
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
          Icon(icon, size: 20, color: AppColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
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
