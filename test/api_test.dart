
import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/api_responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('api_test', ()
  {
    group("test_chat_api", () {
      final baseUrl = "localhost:44323";

      test("auth", () async {
        final login = "admin@this.com";
        final password = "12345admin";

        final response = await http.post(
            Uri.https(baseUrl, "api/auth"),
            headers: {
              "Content-Type": "application/json"
            },
            body: JsonEncoder().convert({
              "login": "admin@this.com",
              "password": "12345admin"
            })
        );

        Map<String, dynamic> json = jsonDecode(
          response.body
        );

        var authResult = AuthResult.fromJson(
            json
        );

        print("Token: " + authResult.token);

        var usersRequest = Uri.https(
          baseUrl, "api/users");
        var headers = new Map<String, dynamic>();

        var usersResponse = await http.get(usersRequest, headers: {
          "Authorization": "Bearer " + authResult.token
        });

        print(usersResponse.body);
      });
    });
  });
}