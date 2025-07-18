// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

List<Auth> authFromJson(String str) => List<Auth>.from(json.decode(str).map((x) => Auth.fromJson(x)));

String authToJson(List<Auth> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Auth {
   final int id;
   final String name;
   final String email;
   final bool isAdmin;
   final String? profileImageUrl;

    Auth({
        required this.id,
        required this.name,
        required this.email,
        required this.isAdmin,
        this.profileImageUrl

    });

    factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        isAdmin: json["is_admin"],
        profileImageUrl: json['profile_image_url']

    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "is_admin": isAdmin,
        "profile_image_url": profileImageUrl
    };
}

class AuthResponse {
  final String message;
  final Auth user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  // Factory constructor to create an AuthResponse object from a JSON map
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? 'Success',
      user: Auth.fromJson(json['user']),
      token: json['token'],
    );
  }
}