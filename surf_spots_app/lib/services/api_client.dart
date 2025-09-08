import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  static final CookieJar cookieJar = CookieJar();
  static final Dio dio = Dio()..interceptors.add(CookieManager(cookieJar));
}
