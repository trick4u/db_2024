class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? photoUrl;
  final String? name;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'name': name,
    
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      name: map['name'],
    
    );
  }
}