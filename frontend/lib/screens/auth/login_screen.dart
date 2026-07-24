import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'student_registration_screen.dart';
import 'tutor_registration_screen.dart';
import 'change_password_screen.dart';
import '../student/student_dashboard.dart';
import '../tutor/tutor_dashboard.dart';
import '../admin/admin_dashboard.dart';

// ✅ Added Admin role
enum UserRole { student, tutor, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Role config map - single source of truth
  Map<UserRole, _RoleConfig> get _roleConfigs => {
        UserRole.student: _RoleConfig(
          label: 'Student',
          icon: Icons.school_outlined,
          activeIcon: Icons.school_rounded,
          color: AppColors.primaryGreen,
          gradient: AppColors.primaryGradient,
          usernamLabel: 'Matric Number',
          usernameHint: 'e.g., 2460141000',
          passwordHint: 'Default: 12345678',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        UserRole.tutor: _RoleConfig(
          label: 'Tutor',
          icon: Icons.person_outline,
          activeIcon: Icons.person_rounded,
          color: AppColors.blue,
          gradient: AppColors.blueGradient,
          usernamLabel: 'Email Address',
          usernameHint: 'Enter your email',
          passwordHint: 'Enter your password',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        UserRole.admin: _RoleConfig(
          label: 'Admin',
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings_rounded,
          color: AppColors.red,
          gradient: AppColors.redGradient,
          usernamLabel: 'Admin Email',
          usernameHint: 'Enter admin email',
          passwordHint: 'Enter admin password',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      };

  _RoleConfig get _currentConfig => _roleConfigs[_selectedRole]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largePadding,
                vertical: AppConstants.extraLargePadding,
              ),
              child: Column(
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 32),
                  _buildLoginPanel(),
                  const SizedBox(height: 20),
                  // Only show registration links for student/tutor
                  if (_selectedRole != UserRole.admin)
                    _buildCreateAccountLink(),
                  if (_selectedRole == UserRole.admin) _buildAdminNote(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppConstants.mediumAnimation,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _currentConfig.color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/fpi_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _currentConfig.gradient,
                    ),
                    child: Icon(
                      _currentConfig.activeIcon,
                      size: 55,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'EDASAC',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _currentConfig.color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'The Federal Polytechnic, Ilaro',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel() {
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: [
          BoxShadow(
            color: _currentConfig.color.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: _currentConfig.color.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: AppConstants.mediumAnimation,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _currentConfig.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _currentConfig.activeIcon,
                      color: _currentConfig.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_currentConfig.label} Portal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _currentConfig.color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ✅ Role Selector - Now has 3 roles
              _buildRoleSelector(),

              const SizedBox(height: 24),

              // Username field
              _buildUsernameField(),

              const SizedBox(height: 16),

              // Password field
              _buildPasswordField(),

              const SizedBox(height: 24),

              // Login button
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: UserRole.values.map((role) {
          final config = _roleConfigs[role]!;
          final isSelected = _selectedRole == role;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRole = role;
                  _usernameController.clear();
                  _passwordController.clear();
                  _formKey.currentState?.reset();
                });
              },
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? config.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: config.color.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? config.activeIcon : config.icon,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      config.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUsernameField() {
    final config = _currentConfig;

    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: config.usernamLabel,
        hintText: config.usernameHint,
        prefixIcon: Icon(config.prefixIcon, color: config.color),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.color, width: 2),
        ),
        labelStyle: TextStyle(color: config.color),
      ),
      keyboardType: config.keyboardType,
      inputFormatters: _selectedRole == UserRole.student
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your ${config.usernamLabel.toLowerCase()}';
        }
        if (_selectedRole == UserRole.student && value.length != 10) {
          return 'Matric number must be exactly 10 digits';
        }
        if (_selectedRole == UserRole.tutor ||
            _selectedRole == UserRole.admin) {
          if (!value.contains('@') || !value.contains('.')) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final config = _currentConfig;

    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: config.passwordHint,
        prefixIcon: Icon(Icons.lock_outline, color: config.color),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.color, width: 2),
        ),
        labelStyle: TextStyle(color: config.color),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textTertiary,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    final config = _currentConfig;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: config.color,
              disabledBackgroundColor: config.color.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        config.activeIcon,
                        size: 20,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Sign In as ${config.label}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCreateAccountLink() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New student? ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudentRegistrationScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Register here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Want to teach? ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutorRegistrationScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Apply as Tutor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Admin note shown instead of registration links
  Widget _buildAdminNote() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.security_rounded,
            color: AppColors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Access',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin accounts are created by the system administrator. '
                  'Contact your system administrator if you need access.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LOGIN HANDLER ====================

  Future<void> _handleLogin() async {
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    // ✅ Pass role to backend for role-specific login endpoint
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;

      if (user == null) {
        _showErrorSnackBar('Login failed. Please try again.');
        return;
      }

      // ✅ Validate role matches selected tab
      if (!_isRoleMatch(user.role)) {
        // Role mismatch - logout and show error
        await authProvider.logout();
        if (!mounted) return;
        _showErrorSnackBar(
          'Account not found for ${_currentConfig.label} role. '
          'Please select the correct role.',
        );
        return;
      }

      // Check if first login (password change required)
      if (user.mustChangePassword) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(role: user.role),
          ),
        );
        return;
      }

      // Navigate to dashboard
      _navigateToRoleDashboard(user.role);
    } else {
      _showErrorSnackBar(
        authProvider.errorMessage ??
            'Login failed. Please check your credentials.',
      );
    }
  }

  // ✅ Verify that logged-in user matches selected role tab
  bool _isRoleMatch(String userRole) {
    switch (_selectedRole) {
      case UserRole.student:
        return userRole == AppConstants.roleStudent;
      case UserRole.tutor:
        return userRole == AppConstants.roleTutor;
      case UserRole.admin:
        return userRole == AppConstants.roleAdmin;
    }
  }

  void _navigateToRoleDashboard(String role) {
    Widget dashboard;

    switch (role.toLowerCase()) {
      case AppConstants.roleStudent:
        dashboard = const StudentDashboard();
        break;
      case AppConstants.roleTutor:
        dashboard = const TutorDashboard();
        break;
      case AppConstants.roleAdmin:
        dashboard = const AdminDashboard();
        break;
      default:
        _showErrorSnackBar('Unknown user role: $role');
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboard),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// ==================== ROLE CONFIG MODEL ====================

class _RoleConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final LinearGradient gradient;
  final String usernamLabel;
  final String usernameHint;
  final String passwordHint;
  final IconData prefixIcon;
  final TextInputType keyboardType;

  const _RoleConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.gradient,
    required this.usernamLabel,
    required this.usernameHint,
    required this.passwordHint,
    required this.prefixIcon,
    required this.keyboardType,
  });
}
