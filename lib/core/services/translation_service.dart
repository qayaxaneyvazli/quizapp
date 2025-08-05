import 'package:quiz_app/core/services/api_service.dart';

class TranslationService {
  final ApiService _apiService;

  TranslationService(this._apiService);

  Future<Map<String, String>> getTranslations(String languageCode) async {
    try {
      final response = await _apiService.get(
        '/translations',
        queryParameters: {'lang': languageCode},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['translations'] != null) {
          final Map<String, dynamic> translations = data['translations'];
          return translations.map((key, value) => MapEntry(key, value.toString()));
        } else {
          throw Exception('Invalid translation data format');
        }
      } else {
        throw Exception('Failed to load translations: ${response.statusCode}');
      }
    } catch (e) {
      print('Translation Service Error: $e');
      rethrow;
    }
  }
} 