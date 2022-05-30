import 'dart:convert';

import 'package:chat_app/api/common_response.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:dio/dio.dart';

typedef AuthCallback = void Function(AuthResult result);
typedef ValidationCallback = void Function(Map<String, dynamic>);

class AuthInteractor {
  final Dio dio;
  final UserManager userManager;

  AuthInteractor(this.dio, this.userManager);

  Future<CommonResponse<AuthResult>> login(
      String login, String password) async {
    try {
      final resp = await dio.post('api/auth',
          data: jsonEncode({"login": login, "password": password}));

      final json = resp.data;
      final data = json["data"];
      final error = json["error"];

      if (data != null) {
        final result = AuthResult.fromJson(data);

        await userManager.setAccessToken(result.token);
        await userManager.setUserId(result.userId);

        return CommonResponse(data: result);
      }

      if (error != null) {
        return CommonResponse(errorMessage: error);
      }
    } catch (ex, st) {
      print(ex.toString() + '\n$st');

      return CommonResponse(errorMessage: ex.toString());
    }

    return CommonResponse.unknown();
  }

  Future<CommonResponse<AuthResult>> register(
      String name, String email, String phone, String password) async {
    try {
      final resp = await dio.post("api/register",
          data: jsonEncode({
            "name": name,
            "email": email,
            "telephone": phone,
            "password": password
          }));

      final json = resp.data;

      print(json);

      final data = json["data"];
      final error = json["error"];
      final validations = json["validations"];

      if (error != null && validations == null) {
        return CommonResponse(errorMessage: error);
      } else if (validations != null) {
        final resultValidation = Map<String, String?>();

        resultValidation['pswOne'] = validations["password"];
        resultValidation['pswTwo'] = validations["password"];
        resultValidation['phone'] = validations['phone'];
        resultValidation['name'] = validations['name'];
        resultValidation['email'] = validations['email'];

        return CommonResponse(validations: resultValidation);
      } else {
        final result = AuthResult.fromJson(data);

        await userManager.setAccessToken(result.token);
        await userManager.setUserId(result.userId);

        return CommonResponse(data: result);
      }
    } catch (ex, st) {
      print(ex.toString() + '\n$st');

      return CommonResponse(errorMessage: ex.toString());
    }
  }
}
