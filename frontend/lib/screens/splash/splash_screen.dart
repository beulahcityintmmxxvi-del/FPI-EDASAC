import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../student/student_dashboard.dart';
import '../tutor/tutor_dashboard.dart';
import '../admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    final userBox = Hive.box(AppConstants.userBox);
    final token = userBox.get(AppConstants.tokenKey);

    if (token != null) {
      final authService = AuthService();
      final storedUser = authService.getStoredUser();

      if (storedUser != null) {
        _navigateByRole(storedUser.role);
      } else {
        final response = await authService.getCurrentUser();
        if (!mounted) return;

        if (response.success && response.data != null) {
          _navigateByRole(response.data!.role);
        } else {
          await userBox.clear();
          _navigateToLogin();
        }
      }
    } else {
      _navigateToLogin();
    }
  }

  void _navigateByRole(String role) {
    Widget destination;

    switch (role.toLowerCase()) {
      case AppConstants.roleStudent:
        destination = const StudentDashboard();
        break;
      case AppConstants.roleTutor:
        destination = const TutorDashboard();
        break;
      case AppConstants.roleAdmin:
        destination = const AdminDashboard();
        break;
      default:
        destination = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreenDark,
              AppColors.primaryGreen,
              AppColors.primaryGreenLight,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  // ── Top decorative area ──
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTopDecoration(),
                    ),
                  ),

                  // ── Center Logo Area ──
                  Expanded(
                    flex: 4,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildLogoSection(context),
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom Info Area ──
                  Expanded(
                    flex: 3,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: _buildBottomSection(context),
                      ),
                    ),
                  ),

                  // ── Loading Bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                    child: _buildLoadingBar(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Main Logo Container ──
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(38),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: AppColors.white.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                // ✅ Uses your school logo
                'assets/images/fpi_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo not found
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 85,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── App Name ──
        Text(
          'EDASAC',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                fontSize: 38,
              ),
        ),

        const SizedBox(height: 8),

        // ── Divider with gold accent ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Subtitle ──
        Text(
          'Vocational Skills Platform',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white.withOpacity(0.95),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Institution badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_city_rounded,
                color: AppColors.gold,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Feature pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeaturePill(context, Icons.school_outlined, 'Learn'),
            const SizedBox(width: 10),
            _buildFeaturePill(context, Icons.work_outline, 'Skill Up'),
            const SizedBox(width: 10),
            _buildFeaturePill(context, Icons.emoji_events_outlined, 'Achieve'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturePill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.goldLight, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBar() {
    return Column(
      children: [
        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppColors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.gold,
                ),
                minHeight: 4,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading...',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
