enum AuthType { email, google }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String photoUrl;

  final AuthType authType;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl = '',
    this.authType = AuthType.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] ?? '',
      authType:
          json['authType'] == null
              ? AuthType.email
              : AuthType.values.firstWhere(
                (auth) =>
                    auth.toString().split('.').last ==
                    json['authType'],
                orElse: () => AuthType.email,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'authType': authType.toString().split('.').last,
    };
  }
}
