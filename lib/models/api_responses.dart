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
  late final List<UserInfo> users;
  late final List<UserInfo> historyUsers;
  late final int ownerId;

  late int unreadMessages;

  late final List<UserInfo> allUsers;

  ChatInfo.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    users = _getUsers(json["chatUsers"]);

    print('$name, userCount: ${users.length}');

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
