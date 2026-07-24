import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize - restore user from local storage
  Future<void> initialize() async {
    _currentUser = _authService.getStoredUser();
    notifyListeners();
  }

  /// Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(
      username: username,
      password: password,
    );

    _isLoading = false;

    if (response.success) {
      _currentUser = _authService.getStoredUser();

      if (_currentUser == null) {
        final userResponse = await _authService.getCurrentUser();
        if (userResponse.success) {
          _currentUser = userResponse.data;
        }
      }

      notifyListeners();

      if (_currentUser != null) {
        return true;
      } else {
        _errorMessage =
            'Login succeeded but failed to load user profile. Please try again.';
        notifyListeners();
        return false;
      }
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Logout - FIXED VERSION
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}