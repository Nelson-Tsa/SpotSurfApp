import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class HttpClient {
  static final Dio _dio = Dio();
  static bool _initialized = false;

  static Dio get instance {
    if (!_initialized) {
      _dio.interceptors.add(CookieManager(CookieJar()));
      _initialized = true;
    }
    return _dio;
  }
}
