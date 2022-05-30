import 'package:chat_app/managers/user_manager.dart';
import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  final UserManager userManager;

  TokenInterceptor(this.userManager);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await userManager.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
