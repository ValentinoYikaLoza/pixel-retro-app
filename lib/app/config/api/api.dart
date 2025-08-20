import 'package:dio/dio.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';

class Api {
  final Dio _dioBase = Dio(BaseOptions(baseUrl: Environment.urlBase));

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dioBase.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {required Object data}) async {
    return _dioBase.post(path, data: data);
  }
}
