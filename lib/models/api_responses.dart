class ChatResponse<T> {
  final T? data;
  final String? error;

  ChatResponse({this.data, this.error});
}

class AuthResult {
  final String token;
  final int userId;

  AuthResult({required this.token, required this.userId});

  AuthResult.fromJson(Map<String, dynamic> json)
      : token = json["token"],
        userId = json["userId"];
}

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String telephone;
  final int avatarId;
  String imageUrl;

  UserInfo.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        email = json["email"],
        telephone = json["telephone"],
        avatarId = json["avatarId"],
        imageUrl = json["imageUrl"];
}

class ChatInfo {
  late final int id;
  late final String name;
  late final bool isPrivate;
  late ChatMessage? lastMessage;
  late final List<UserInfo> users;
  late final List<UserInfo> historyUsers;
  late final int ownerId;

  late int unreadMessages;

  late final List<UserInfo> allUsers;

  String? get lastMessageSenderName {
    String? name;

    if (lastMessage != null) {
      final sender =
          allUsers.where((element) => element.id == lastMessage!.senderId);

      if (sender.isNotEmpty) {
        name = sender.first.name;
      }
    }

    return name;
  }

  String? get lastMessageDesc {
    String? desc;

    if (lastMessage != null) {
      if (lastMessage?.message != null) {
        desc = lastMessage!.message;
      }

      if (lastMessage?.image != null) {
        desc = 'Изображение';
      }
    }

    return desc;
  }

  ChatInfo.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"] ?? '';
    users = _getUsers(json["chatUsers"]);
    isPrivate = json['isPrivate'];

    final jsonLastMessage = json['lastMessage'];

    if (jsonLastMessage != null) {
      lastMessage = ChatMessage.fromJson(jsonLastMessage);
    } else {
      lastMessage = null;
    }

    historyUsers = _getUsers(json["historyUsers"]);
    ownerId = json['ownerId'];
    unreadMessages = json['unreadMessages'];
    allUsers = List.from(users, growable: true);
    allUsers.addAll(historyUsers);
  }

  List<UserInfo> _getUsers(List<dynamic> value) {
    return value.map((e) => UserInfo.fromJson(e)).toList();
  }
}

class ChatUserEdit {
  late final int userId;
  late final bool isRemovable;
  late final String imageUrl;
  late final bool isAttached;
  late final String name;

  ChatUserEdit.fromJson(Map<String, dynamic> json) {
    userId = json["userId"];
    isRemovable = json["isRemovable"];
    imageUrl = json["imageUrl"];
    isAttached = json["isAttached"];
    name = json["name"];
  }
}

class ChatMessage {
  late final int id;
  late final int chatId;
  late final int senderId;
  late final DateTime date;
  late final String? message;
  late final String? image;

  ChatMessage.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.chatId = json["chatId"];
    this.senderId = json["senderId"];
    this.date = DateTime.parse(json["date"]);
    this.message = json["message"];
    this.image = json['image'];
  }

  static List<ChatMessage> parseList(List<dynamic> messages) {
    return messages.map((e) => ChatMessage.fromJson(e)).toList();
  }
}
