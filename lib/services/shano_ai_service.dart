
import 'dart:convert';

import 'package:http/http.dart' as http;

class ShanoAiService {
  ShanoAiService._();

  static final ShanoAiService instance =
      ShanoAiService._();

  static const String apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  Future<ShanoAiResponse> chat({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '$apiBaseUrl/api/ai/fragrance-chat',
          ),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'message': message,
            'history': history,
          }),
        )
        .timeout(
          const Duration(seconds: 45),
        );

    Map<String, dynamic> data;

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        throw Exception(
          'Invalid server response.',
        );
      }
    } catch (_) {
      throw Exception(
        'Unable to read SHANO AI response.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw Exception(
        _cleanError(
          data['error']?.toString(),
        ),
      );
    }

    final reply =
        data['reply']?.toString().trim() ?? '';

    if (reply.isEmpty) {
      throw Exception(
        'SHANO AI returned an empty response.',
      );
    }

    final recommendations =
        <ShanoAiProduct>[];

    final rawRecommendations =
        data['recommendations'];

    if (rawRecommendations is List) {
      for (final item in rawRecommendations) {
        if (item is Map) {
          recommendations.add(
            ShanoAiProduct.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return ShanoAiResponse(
      reply: reply,
      recommendations: recommendations,
    );
  }

  String _cleanError(String? error) {
    if (error == null ||
        error.trim().isEmpty) {
      return 'SHANO AI is temporarily unavailable. Please try again.';
    }

    return error.trim();
  }
}

class ShanoAiResponse {
  final String reply;
  final List<ShanoAiProduct> recommendations;

  const ShanoAiResponse({
    required this.reply,
    required this.recommendations,
  });
}

class ShanoAiProduct {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final int stock;

  const ShanoAiProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.stock,
  });

  factory ShanoAiProduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return ShanoAiProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category:
          json['category']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      price: _toDouble(json['price']),
      currency:
          json['currency']?.toString() ?? 'PKR',
      imageUrl:
          json['image_url']?.toString() ?? '',
      stock: _toInt(json['stock']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
