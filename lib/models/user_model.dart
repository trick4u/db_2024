class UserModel {
  String? id;
  String? name;
  String? email;
  String? userName;

  UserModel({this.id, this.name, this.email, this.userName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      userName: json['userName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userName': userName,
    };
  }
}
