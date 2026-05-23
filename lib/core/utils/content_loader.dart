import 'dart:convert';
import 'package:flutter/services.dart';

final class ContentLoader {
  const ContentLoader._();

  static Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      return json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      throw ContentLoadException(
        'Failed to load asset: $assetPath\n$e',
      );
    }
  }

  static Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      return json.decode(raw) as List<dynamic>;
    } catch (e) {
      throw ContentLoadException(
        'Failed to load asset: $assetPath\n$e',
      );
    }
  }
}

final class ContentLoadException implements Exception {
  const ContentLoadException(this.message);
  final String message;
  @override
  String toString() => 'ContentLoadException: $message';
}
