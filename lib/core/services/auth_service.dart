import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bintar-mocha.vercel.app', // Sesuaikan dengan host backend Anda
    headers: {'Content-Type': 'application/json'},
  ));

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('auth_box');
  }

  String? get token => _box.get(_tokenKey);
  Map<String, dynamic>? get user => _box.get(_userKey) != null 
      ? Map<String, dynamic>.from(json.decode(_box.get(_userKey))) 
      : null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final formData = FormData.fromMap({
        'username': email,
        'password': password,
      });

      final response = await _dio.post('/auth/login', data: formData);
      
      final token = response.data['access_token'];
      final userData = response.data['user'];

      await _box.put(_tokenKey, token);
      await _box.put(_userKey, json.encode(userData));

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _box.delete(_tokenKey);
    await _box.delete(_userKey);
  }

  bool get isAuthenticated => token != null;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = true,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    await _authService.init();
    if (_authService.isAuthenticated) {
      state = state.copyWith(isAuthenticated: true, user: _authService.user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.login(email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true, user: _authService.user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.register(fullName, email, password);
      state = state.copyWith(isLoading: false);
      // Optional: Auto login after register or just return true
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(isLoading: false);
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(token, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
