import 'dart:io';

import 'package:dio/dio.dart';

import '../../config/constant/api.config.dart';
import 'dio_logger.dart';

class Client {
  static String? lang;
  static String? token;

  final String tag;
  final String? baseUrl;

  late final Dio _dio;
  Dio get client => _dio;
  final BaseOptions _baseOptions = BaseOptions(
      responseType: ResponseType.json,
      headers: const <String, dynamic>{
        HttpHeaders.contentTypeHeader: 'application/json',
      });
  Client({required this.tag, this.baseUrl}) {
    _dio = Dio(_baseOptions);
    _dio.options.baseUrl = baseUrl ?? ApiConfig.baseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, handler) {
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          if (lang != null) options.headers['Language'] = lang;
          DioLogger.onSend(tag, options);
          return handler.next(options);
        },
        onResponse: (Response<dynamic> response, handler) {
          DioLogger.onSuccess(tag, response);
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          DioLogger.onError(tag, error);
          return handler.next(error);
        },
      ),
    );
  }
}
