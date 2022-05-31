import 'package:chat_app/models/api_responses.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

typedef UserInfoCallback = void Function(UserInfo userInfo);

class UserInteractor {
  final Dio dio;

  UserInteractor(this.dio);

  Future<UserInfo?> getUserInfo() async {
    try {
      final resp = await dio.get("api/profile");
      var json = resp.data;
      var data = json["data"];
      var error = json["error"];

      var result = UserInfo.fromJson(data);

      return result;
    } catch (ex, st) {
      print(st);
    }

    return null;
  }

  Future<List<UserInfo>?> getUsers() async {
    try {
      final response = await dio.get("api/users");

      final json = response.data;
      final users = List<UserInfo>.empty(growable: true);

      json.forEach((map) {
        final user = UserInfo.fromJson(map);

        users.add(user);
      });

      return users;
    } catch (ex, st) {
      print(st);
    }

    return null;
  }

  Future<MapEntry<UserInfo?, String?>> getUser(int userId) async {
    try {
      final response = await dio.get("api/user/$userId");
      final json = response.data;
      final userInfo = UserInfo.fromJson(json["data"]);

      return MapEntry(userInfo, null);
    } catch (ex, trace) {
      print(trace);

      return MapEntry(null, ex.toString());
    }
  }

  Future<String?> updateImage(int userId, List<int> bytes) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromBytes(bytes,
            filename: 'image', contentType: MediaType.parse('image/png'))
      });

      final response = await dio.patch('api/avatar',
          data: formData, queryParameters: {'userId': userId});

      print("Status code: " + response.statusCode.toString());

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Вы не можете изменить данный профиль";
      }
    } catch (ex, trace) {
      print(trace);

      return ex.toString();
    }
  }
}
