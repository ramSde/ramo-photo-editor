import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum DioMethod { post, get, put, delete }

class APIService {
  APIService._singleton();
  static final APIService instance = APIService._singleton();

  String get baseUrl => kDebugMode ? 'https://api.remove.bg/v1.0' : 'https://api.production.com';

  Future<Response> request(
      String endpoint,
      DioMethod method, {
        Map<String, dynamic>? param,
        String? contentType,
        dynamic formData,
        Map<String, dynamic>? headers,
      }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          contentType: contentType ?? Headers.jsonContentType,
          headers: headers ?? {
            HttpHeaders.authorizationHeader: '',
          },
        ),
      );

      switch (method) {
        case DioMethod.post:
          return dio.post(endpoint, data: formData ?? param);
        case DioMethod.get:
          return dio.get(endpoint, queryParameters: param);
        case DioMethod.put:
          return dio.put(endpoint, data: formData ?? param);
        case DioMethod.delete:
          return dio.delete(endpoint, data: formData ?? param);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Response> removeBackground(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(imageFile.path),
        'size' : "auto"
      });

      return await request(
        '/removebg',
        DioMethod.post,
        contentType: 'multipart/form-data',
        formData: formData,
        headers: {
          'X-Api-Key' :'Xfo6ctpf2tTvf8Jf5hBnEtcW'
        }

      );
    } catch (e) {
      throw Exception('Background removal failed: $e');
    }
  }
}
