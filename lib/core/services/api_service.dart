import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/language/language_provider.dart';

class ApiService {
  late Dio _dio;
  final Ref ref;
  
  static const String baseUrl = 'http://116.203.188.209/api';

  ApiService(this.ref) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Interceptor əlavə et ki, avtomatik olaraq lang parametrini əlavə etsin
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // HER REQUEST-də hazırkı dili yenidən oxu
          final currentLang = ref.read(languageProvider);
          
          // Əgər URL-də artıq lang parametri yoxdursa, əlavə et
          if (!options.queryParameters.containsKey('lang')) {
            options.queryParameters['lang'] = currentLang;
          }
          
          print('API Request: ${options.path} with lang: $currentLang'); // Debug için
          handler.next(options);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response<dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response<dynamic>> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response<dynamic>> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response<dynamic>> delete(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}