import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/services/api_service.dart';
import 'package:quiz_app/models/chapter/chapter.dart';

class ChapterService {
  final ApiService _apiService;

  ChapterService(this._apiService);

  Future<List<ChapterModel>> getChapters({String? language}) async {
    try {
      final response = await _apiService.get(
        '/chapters',
        queryParameters: language != null ? {'lang': language} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChapterModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error loading chapters: $e');
    }
  }

  Future<ChapterModel> getChapter(int chapterId, {String? language}) async {
    try {
      final response = await _apiService.get(
        '/chapters/$chapterId',
        queryParameters: language != null ? {'lang': language} : null,
      );

      if (response.statusCode == 200) {
        return ChapterModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load chapter: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error loading chapter: $e');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
