import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  // ============================================================
  // LIVE SHANO SHAN API
  // ============================================================

  static const String apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  // ============================================================
  // LOCAL STORAGE KEYS
  // ============================================================

  static const String _checkoutDetailsKey =
      'shano_shan_checkout_details';

  static const String _savedOrdersKey =
      'shano_shan_saved_orders';

  // IMPORTANT:
  // Keep this key synchronized with the key used by your
  // authentication service.
  static const String _authTokenKey =
      'shano_shan_token';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  // ============================================================
  // AUTH TOKEN
  // ============================================================

  Future<String?> getAuthToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_authTokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await getAuthToken();

    if (token == null) {
      throw Exception(
        'Please sign in to view your orders.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // CHECKOUT DETAILS
  // ============================================================

  Future<void> saveCheckoutDetails({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String province,
    required String postalCode,
  }) async {
    final prefs = await _prefs;

    await prefs.setString(
      _checkoutDetailsKey,
      jsonEncode({
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'province': province.trim(),
        'postal_code': postalCode.trim(),
      }),
    );
  }

  Future<Map<String, dynamic>?> loadCheckoutDetails() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_checkoutDetailsKey);

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

  Future<void> clearCheckoutDetails() async {
    final prefs = await _prefs;
    await prefs.remove(_checkoutDetailsKey);
  }

  // ============================================================
  // SAVED GUEST ORDER REFERENCES
  // ============================================================

  Future<void> saveOrderReference({
    required String orderNumber,
    required String phone,
  }) async {
    final prefs = await _prefs;

    final orders = await loadSavedOrderReferences();

    orders.removeWhere(
      (item) => item['order_number'] == orderNumber,
    );

    orders.insert(0, {
      'order_number': orderNumber.trim(),
      'phone': phone.trim(),
      'saved_at': DateTime.now().toIso8601String(),
    });

    final limited = orders.take(20).toList();

    await prefs.setString(
      _savedOrdersKey,
      jsonEncode(limited),
    );
  }

  Future<List<Map<String, dynamic>>> loadSavedOrderReferences() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_savedOrdersKey);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<void> removeSavedOrderReference(
    String orderNumber,
  ) async {
    final prefs = await _prefs;

    final orders = await loadSavedOrderReferences();

    orders.removeWhere(
      (item) => item['order_number'] == orderNumber,
    );

    await prefs.setString(
      _savedOrdersKey,
      jsonEncode(orders),
    );
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required String province,
    required String postalCode,
    String email = '',
    required String paymentMethod,
    String transactionReference = '',
  }) async {
    final headers = await _authHeaders();

    final body = {
      'customer_name': customerName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'province': province.trim(),
      'postal_code': postalCode.trim(),
      'payment_method': paymentMethod.trim().toLowerCase(),
      'transaction_reference':
          transactionReference.trim(),
    };

    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/orders'),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _decodeResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not place your order.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not place your order.',
      );
    }

    final order = data['order'];

    if (order is! Map) {
      throw Exception(
        'Invalid order response.',
      );
    }

    return Map<String, dynamic>.from(order);
  }

  // ============================================================
  // GET MY ORDERS
  // ============================================================

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/orders'),
      headers: headers,
    );

    final data = _decodeResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not load your orders.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not load your orders.',
      );
    }

    final orders = data['orders'];

    if (orders is! List) {
      return [];
    }

    return orders
        .whereType<Map>()
        .map(
          (order) => Map<String, dynamic>.from(order),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE CUSTOMER ORDER
  // ============================================================

  Future<Map<String, dynamic>> getOrder(
    String orderNumber,
  ) async {
    final headers = await _authHeaders();

    final encodedOrderNumber =
        Uri.encodeComponent(orderNumber.trim());

    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/orders/$encodedOrderNumber',
      ),
      headers: headers,
    );

    final data = _decodeResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not retrieve the order.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not retrieve the order.',
      );
    }

    final order = data['order'];

    if (order is! Map) {
      throw Exception(
        'Invalid order response.',
      );
    }

    return Map<String, dynamic>.from(order);
  }

  // ============================================================
  // GUEST ORDER TRACKING
  // ============================================================

  Future<Map<String, dynamic>> trackOrder({
    required String orderNumber,
    required String phone,
  }) async {
    final uri = Uri.parse(
      '$apiBaseUrl/api/orders/track',
    ).replace(
      queryParameters: {
        'order_number': orderNumber.trim(),
        'phone': phone.trim(),
      },
    );

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not retrieve the order.',
      );
    }

    if (data == null || data['success'] != true) {
      throw Exception(
        data?['error']?.toString() ??
            'Could not retrieve the order.',
      );
    }

    final order = data['order'];

    if (order is! Map) {
      throw Exception(
        'Invalid order response.',
      );
    }

    return Map<String, dynamic>.from(order);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, dynamic>? _decodeResponse(
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