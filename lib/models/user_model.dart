class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }
}