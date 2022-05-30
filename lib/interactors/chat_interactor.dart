import 'dart:convert';

import 'package:chat_app/interactors/user_interactor.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ChatInteractor {
  final UserInteractor _userInteractor;
  final UserManager _userManager;
  final Dio dio;

  ChatInteractor(
      {required UserInteractor userInteractor,
      required UserManager userManager,
      required this.dio})
      : _userInteractor = userInteractor,
        _userManager = userManager;

  Future<MapEntry<List<ChatInfo>?, String?>> getChats() async {
    try {
      final response = await dio.get("api/chats");
      final json = response.data as List<dynamic>;
      final chats = List<ChatInfo>.empty(growable: true);

      json.forEach((chat) {
        chats.add(ChatInfo.fromJson(chat));
      });

      return MapEntry(chats, null);
    } catch (ex, trace) {
      print(trace);

      return MapEntry(null, ex.toString());
    }
  }

  Future<MapEntry<ChatInfo?, String?>> getChat(int chatId) async {
    try {
      final response = await dio.get("api/chat/$chatId");
      final json = response.data;
      final chatInfo = ChatInfo.fromJson(json);

      return MapEntry(chatInfo, null);
    } catch (ex, trace) {
      print(trace);

      return MapEntry(null, ex.toString());
    }
  }

  Future<ChatUiModel?> getUiData(int chatId) async {
    final userId = await _userManager.getUserId();

    if (userId == null) return null;

    final userInfoResp = await _userInteractor.getUser(userId);
    final userInfo = userInfoResp.key;

    if (userInfo == null) return null;

    final chatInfoResponse = await getChat(chatId);
    final chatInfo = chatInfoResponse.key;

    if (chatInfo == null) return null;

    final messages = await getChatMessages(chatId);
    final messageUsers = List<UserInfo>.empty(growable: true);

    return ChatUiModel(userInfo, chatInfo);
  }

  Future<List<ChatMessage>> getChatMessages(int chatId) async {
    try {
      final response = await dio.get("api/chat/$chatId/messages");
      final json = response.data;

      print("resp type: " + json.runtimeType.toString());

      final messages = ChatMessage.parseList(json["data"]);

      return messages;
    } catch (ex, trace) {
      print(trace);

      return List.empty();
    }
  }

  Future<String?> createChat(String chatName) async {
    try {
      final response = await dio.put("api/chat/create",
          data: jsonEncode({"name": chatName}));

      if (response.statusCode == 200) {
        return null;
      }
    } catch (ex, trace) {
      print(trace);

      return ex.toString();
    }
  }

  Future<String?> updateChatName(int chatId, String chatName) async {
    try {
      final result = await dio.patch('api/chat/$chatId/edit',
          data: jsonEncode({"name": chatName}));

      print("Json: ${result.data}");

      if (result.data.isNotEmpty) {
        return result.data["error"];
      } else {
        return "Операция успешна";
      }
    } catch (ex, trace) {
      print(trace);

      return ex.toString();
    }
  }

  Future<List<ChatUserEdit>?> getEditChatUsers(int chatId) async {
    try {
      final result = await dio.get('api/chat/$chatId/edit/users');

      if (result.statusCode == 200) {
        final json = result.data;
        final data = json["data"];

        print(result.data);
        print("Runtime type: ${data.runtimeType}");

        final array = data as List<dynamic>;

        return array.map((e) => ChatUserEdit.fromJson(e)).toList();
      } else {
        return null;
      }
    } catch (ex, trace) {
      print(trace);

      return null;
    }
  }

  Future<MapEntry<bool, String?>> updateChatUser(
      int chatId, int userId, bool isAttach) async {
    try {
      final result = await dio.patch('api/chat/$chatId/edit/user',
          queryParameters: {
            "userId": userId.toString(),
            "isAttach": isAttach.toString()
          });

      print(result.data);

      if (result.data.isNotEmpty) {
        final json = result.data;
        final error = json["error"];

        if (error != null) {
          return MapEntry(false, error);
        } else {
          return MapEntry(true, null);
        }
      } else {
        return MapEntry(true, null);
      }
    } catch (ex, trace) {
      print(trace);

      return MapEntry(false, ex.toString());
    }
  }

  sendImageToChat(int id, String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path,
          filename: 'file', contentType: MediaType.parse('image/png'))
    });

    dio.post('/api/chat/$id/attachments/image', data: formData);
  }
}

class ChatUiModel {
  final UserInfo profileInfo;
  final ChatInfo chatInfo;

  ChatUiModel(
    this.profileInfo,
    this.chatInfo,
  );
}

class ChatMessageUiModel {
  final ChatMessage messageInfo;
  final UserInfo senderInfo;

  final bool isOurMessage;

  String get date {
    final messageDate = messageInfo.date;
    final dayString = "${messageDate.month}.${messageDate.day}";
    final timeString = "${messageDate.hour}:${messageDate.minute}";

    return "$timeString";
  }

  ChatMessageUiModel(this.messageInfo, this.senderInfo, this.isOurMessage);
}
