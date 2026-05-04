import 'dart:convert';
import 'package:flutter/services.dart';

final class ContentLoader {
  const ContentLoader._();

  static Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      return json.decode(raw) as Map<String, dynamic>;
    } on FlutterError catch (e) {
      throw ContentLoadException(
        'Failed to load asset: $assetPath\n${e.message}',
      );
    } on FormatException catch (e) {
      throw ContentLoadException(
        'Invalid JSON in asset: $assetPath\n${e.message}',
      );
    }
  }

  static Future<List<dynamic>> loadJsonList(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      return json.decode(raw) as List<dynamic>;
    } on FlutterError catch (e) {
      throw ContentLoadException(
        'Failed to load asset: $assetPath\n${e.message}',
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
