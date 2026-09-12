import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  // ============================================================
  // API
  // ============================================================

  static const String apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  // ============================================================
  // STORAGE
  // ============================================================

  static const String tokenKey = 'shano_shan_token';
  static const String userKey = 'shano_shan_user';

  // ============================================================
  // CURRENT USER
  // ============================================================

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;

    final token = prefs.getString(tokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await _prefs;

    final raw = prefs.getString(userKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = _decode(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            data?['message']?.toString() ??
            'Login failed.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            data?['message']?.toString() ??
            'Login failed.',
      );
    }

    // ------------------------------------------------------------
    // Accept common token names.
    // ------------------------------------------------------------

    final token =
        data['token']?.toString() ??
        data['access_token']?.toString() ??
        data['session_token']?.toString();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Login succeeded, but no session token was returned.',
      );
    }

    // ------------------------------------------------------------
    // Find user object.
    // ------------------------------------------------------------

    Map<String, dynamic>? user;

    final rawUser = data['user'];

    if (rawUser is Map) {
      user = Map<String, dynamic>.from(rawUser);
    }

    // Some APIs return the user under "account".
    final rawAccount = data['account'];

    if (user == null && rawAccount is Map) {
      user = Map<String, dynamic>.from(rawAccount);
    }

    final prefs = await _prefs;

    await prefs.setString(
      tokenKey,
      token.trim(),
    );

    if (user != null) {
      await prefs.setString(
        userKey,
        jsonEncode(user),
      );
    }

    return {
      'token': token.trim(),
      'user': user,
      'raw': data,
    };
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/register'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = _decode(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            data?['message']?.toString() ??
            'Registration failed.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            data?['message']?.toString() ??
            'Registration failed.',
      );
    }

    return data;
  }

  // ============================================================
  // CURRENT USER FROM SERVER
  // ============================================================

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/auth/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decode(response);

    if (response.statusCode == 401) {
      await logout();
      return null;
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            data?['message']?.toString() ??
            'Could not verify your account.',
      );
    }

    if (data == null || data['success'] != true) {
      return null;
    }

    Map<String, dynamic>? user;

    final rawUser = data['user'];

    if (rawUser is Map) {
      user = Map<String, dynamic>.from(rawUser);
    }

    if (user != null) {
      final prefs = await _prefs;

      await prefs.setString(
        userKey,
        jsonEncode(user),
      );

      return user;
    }

    return await getSavedUser();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$apiBaseUrl/api/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Local logout still happens if network logout fails.
      }
    }

    final prefs = await _prefs;

    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> authenticatedHeaders() async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Please sign in to continue.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, dynamic>? _decode(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  String cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return text;
  }
}