
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String productId;
  final String slug;
  final String name;
  final String category;
  final String description;
  final int price;
  final String currency;
  final String imageUrl;
  final int stock;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.slug,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.stock,
    required this.quantity,
  });

  // ==========================================================
  // TOTAL PRICE
  // ==========================================================

  int get totalPrice {
    return price * quantity;
  }

  // ==========================================================
  // FROM JSON
  // ==========================================================

  factory CartItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final productRaw = json['product'];

    final Map<String, dynamic> product =
        productRaw is Map
            ? Map<String, dynamic>.from(productRaw)
            : <String, dynamic>{};

    return CartItem(
      id: json['id']?.toString() ?? '',
      productId:
          json['product_id']?.toString() ??
          product['id']?.toString() ??
          '',
      slug:
          product['slug']?.toString() ??
          json['slug']?.toString() ??
          '',
      name:
          product['name']?.toString() ??
          json['name']?.toString() ??
          'Fragrance',
      category:
          product['category']?.toString() ??
          json['category']?.toString() ??
          '',
      description:
          product['description']?.toString() ??
          json['description']?.toString() ??
          '',
      price: _toInt(
        product['price'] ?? json['price'],
      ),
      currency:
          product['currency']?.toString() ??
          json['currency']?.toString() ??
          'PKR',
      imageUrl:
          product['image_url']?.toString() ??
          json['image_url']?.toString() ??
          '',
      stock: _toInt(
        product['stock'] ?? json['stock'],
      ),
      quantity: _toInt(
        json['quantity'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        double.tryParse(
              value.toString(),
            )?.round() ??
        0;
  }
}

// ============================================================
// CART SERVICE
// ============================================================

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  // ==========================================================
  // API
  // ==========================================================

  static const String _apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  static const String _cartIdKey =
      'shano_shan_cart_id';

  // ==========================================================
  // STATE
  // ==========================================================

  final List<CartItem> _items = [];

  String? _cartId;

  bool _loading = false;

  String? _error;

  bool _initialized = false;

  // ==========================================================
  // GETTERS
  // ==========================================================

  List<CartItem> get items =>
      List.unmodifiable(_items);

  String? get cartId => _cartId;

  bool get loading => _loading;

  String? get error => _error;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get itemCount {
    return _items.fold<int>(
      0,
      (total, item) =>
          total + item.quantity,
    );
  }

  int get subtotal {
    return _items.fold<int>(
      0,
      (total, item) =>
          total + item.totalPrice,
    );
  }

  String get currency {
    if (_items.isNotEmpty) {
      return _items.first.currency;
    }

    return 'PKR';
  }

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      final prefs =
          await SharedPreferences.getInstance();

      _cartId =
          prefs.getString(_cartIdKey);

      await loadCart();
    } catch (e) {
      debugPrint(
        'Cart initialization error: $e',
      );

      _error =
          'Could not initialize shopping bag.';
    }
  }

  // ==========================================================
  // HEADERS
  // ==========================================================

  Map<String, String> _headers() {
    final headers =
        <String, String>{
      'Content-Type':
          'application/json',
      'Accept':
          'application/json',
    };

    if (_cartId != null &&
        _cartId!.trim().isNotEmpty) {
      headers['X-Cart-ID'] =
          _cartId!.trim();
    }

    return headers;
  }

  // ==========================================================
  // SAVE CART ID
  // ==========================================================

  Future<void> _saveCartId(
    String? id,
  ) async {
    if (id == null ||
        id.trim().isEmpty) {
      return;
    }

    _cartId = id.trim();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _cartIdKey,
      _cartId!,
    );
  }

  // ==========================================================
  // LOAD CART
  // ==========================================================

  Future<bool> loadCart() async {
    _setLoading(true);
    _error = null;

    try {
      final response =
          await http.get(
        Uri.parse(
          '$_apiBaseUrl/api/cart',
        ),
        headers: _headers(),
      );

      debugPrint(
        'CART GET: ${response.statusCode}',
      );

      debugPrint(
        'CART BODY: ${response.body}',
      );

      Map<String, dynamic>? data;

      try {
        final decoded =
            jsonDecode(response.body);

        if (decoded is Map) {
          data =
              Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {}

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data?['error']
                  ?.toString() ??
              data?['message']
                  ?.toString() ??
              'Unable to load your shopping bag.',
        );
      }

      final returnedCartId =
          data?['cart_id']?.toString();

      if (returnedCartId != null &&
          returnedCartId.isNotEmpty) {
        await _saveCartId(
          returnedCartId,
        );
      }

      final rawItems =
          data?['items'];

      _items.clear();

      if (rawItems is List) {
        for (final rawItem
            in rawItems) {
          if (rawItem is Map) {
            _items.add(
              CartItem.fromJson(
                Map<String, dynamic>.from(
                  rawItem,
                ),
              ),
            );
          }
        }
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'LOAD CART ERROR: $e',
      );

      _error =
          _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // ADD ITEM
  // ==========================================================

  Future<bool> addItem({
    required String id,
    required String slug,
    required String name,
    required String category,
    required String description,
    required int price,
    required String currency,
    required String imageUrl,
    required int stock,
    required int quantity,
  }) async {
    if (id.trim().isEmpty) {
      _error =
          'Product ID is missing.';

      notifyListeners();

      return false;
    }

    if (quantity <= 0) {
      _error =
          'Invalid quantity.';

      notifyListeners();

      return false;
    }

    if (stock <= 0) {
      _error =
          'This fragrance is out of stock.';

      notifyListeners();

      return false;
    }

    if (quantity > stock) {
      _error =
          'Not enough stock available.';

      notifyListeners();

      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final response =
          await http.post(
        Uri.parse(
          '$_apiBaseUrl/api/cart/items',
        ),
        headers: _headers(),
        body: jsonEncode({
          'product_id': id,
          'quantity': quantity,
        }),
      );

      debugPrint(
        'CART ADD: ${response.statusCode}',
      );

      debugPrint(
        'CART ADD BODY: ${response.body}',
      );

      return await _processCartResponse(
        response,
      );
    } catch (e) {
      debugPrint(
        'ADD CART ERROR: $e',
      );

      _error =
          _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // UPDATE QUANTITY
  // ==========================================================

  Future<bool> updateQuantity(
    String itemId,
    int quantity,
  ) async {
    final item =
        getItemByCartItemId(
      itemId,
    );

    if (item == null) {
      _error =
          'Cart item not found.';

      notifyListeners();

      return false;
    }

    if (quantity <= 0) {
      return removeItem(
        itemId,
      );
    }

    if (quantity > item.stock) {
      _error =
          'Not enough stock available.';

      notifyListeners();

      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final response =
          await http.put(
        Uri.parse(
          '$_apiBaseUrl/api/cart/items/${Uri.encodeComponent(itemId)}',
        ),
        headers: _headers(),
        body: jsonEncode({
          'quantity': quantity,
        }),
      );

      debugPrint(
        'CART UPDATE: ${response.statusCode}',
      );

      debugPrint(
        'CART UPDATE BODY: ${response.body}',
      );

      return await _processCartResponse(
        response,
      );
    } catch (e) {
      debugPrint(
        'UPDATE CART ERROR: $e',
      );

      _error =
          _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // INCREASE
  // ==========================================================

  Future<bool> increaseQuantity(
    String itemId,
  ) async {
    final item =
        getItemByCartItemId(
      itemId,
    );

    if (item == null) {
      return false;
    }

    if (item.quantity >=
        item.stock) {
      _error =
          'Maximum available stock reached.';

      notifyListeners();

      return false;
    }

    return updateQuantity(
      itemId,
      item.quantity + 1,
    );
  }

  // ==========================================================
  // DECREASE
  // ==========================================================

  Future<bool> decreaseQuantity(
    String itemId,
  ) async {
    final item =
        getItemByCartItemId(
      itemId,
    );

    if (item == null) {
      return false;
    }

    if (item.quantity <= 1) {
      return removeItem(
        itemId,
      );
    }

    return updateQuantity(
      itemId,
      item.quantity - 1,
    );
  }

  // ==========================================================
  // REMOVE ITEM
  // ==========================================================

  Future<bool> removeItem(
    String itemId,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final response =
          await http.delete(
        Uri.parse(
          '$_apiBaseUrl/api/cart/items/${Uri.encodeComponent(itemId)}',
        ),
        headers: _headers(),
      );

      debugPrint(
        'CART REMOVE: ${response.statusCode}',
      );

      debugPrint(
        'CART REMOVE BODY: ${response.body}',
      );

      return await _processCartResponse(
        response,
      );
    } catch (e) {
      debugPrint(
        'REMOVE CART ERROR: $e',
      );

      _error =
          _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // CLEAR CART
  // ==========================================================

  Future<bool> clear() async {
    _setLoading(true);
    _error = null;

    try {
      final response =
          await http.delete(
        Uri.parse(
          '$_apiBaseUrl/api/cart',
        ),
        headers: _headers(),
      );

      debugPrint(
        'CART CLEAR: ${response.statusCode}',
      );

      debugPrint(
        'CART CLEAR BODY: ${response.body}',
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Unable to clear your shopping bag.',
        );
      }

      _items.clear();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'CLEAR CART ERROR: $e',
      );

      _error =
          _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // FIND BY PRODUCT ID
  // ==========================================================

  CartItem? getItem(
    String productId,
  ) {
    try {
      return _items.firstWhere(
        (item) =>
            item.productId ==
            productId,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // FIND BY CART ITEM ID
  // ==========================================================

  CartItem? getItemByCartItemId(
    String itemId,
  ) {
    try {
      return _items.firstWhere(
        (item) =>
            item.id == itemId,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // PROCESS CART RESPONSE
  // ==========================================================

  Future<bool> _processCartResponse(
    http.Response response,
  ) async {
    Map<String, dynamic>? data;

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map) {
        data =
            Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {}

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _error =
          data?['error']
                  ?.toString() ??
              data?['message']
                  ?.toString() ??
              'Cart operation failed.';

      notifyListeners();

      return false;
    }

    final returnedCartId =
        data?['cart_id']?.toString();

    if (returnedCartId != null &&
        returnedCartId.isNotEmpty) {
      await _saveCartId(
        returnedCartId,
      );
    }

    final rawItems =
        data?['items'];

    if (rawItems is List) {
      _items.clear();

      for (final rawItem
          in rawItems) {
        if (rawItem is Map) {
          _items.add(
            CartItem.fromJson(
              Map<String, dynamic>.from(
                rawItem,
              ),
            ),
          );
        }
      }
    }

    notifyListeners();

    return data?['success'] == true ||
        data != null;
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  void _setLoading(
    bool value,
  ) {
    _loading = value;

    notifyListeners();
  }

  // ==========================================================
  // ERROR CLEANING
  // ==========================================================

  String _cleanError(
    Object error,
  ) {
    final message =
        error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}
