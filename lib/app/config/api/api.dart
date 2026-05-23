import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';

/// Cliente HTTP único de la app (un solo `Dio`).
///
/// Se registra como lazy singleton en `di.dart` y se inyecta en los
/// datasources, de modo que toda la app comparte la misma configuración de
/// red (baseUrl, timeouts, logging).
class Api {
  Api() : _dio = _build();

  final Dio _dio;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.urlBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return dio;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {required Object data}) {
    return _dio.post(path, data: data);
  }
}
