class UserModel {
  String accessToken;
  String refreshToken;
  UserResponse user;

  UserModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: UserResponse.fromJson(json['user']),
    );
  }

  // Method to convert a UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

class UserResponse {
  dynamic phoneNumber;
  dynamic countryCode;
  dynamic useremail;
  dynamic name;
  dynamic gender;
  dynamic dob;
  String loginBy;
  String loginThrough;

  UserResponse(
      {this.phoneNumber,
      this.countryCode,
      this.useremail,
      this.name,
      this.gender,
      this.dob,
      required this.loginBy,
      required this.loginThrough});

  // Factory constructor to create a User from JSON
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
        phoneNumber: json['phoneNumber'],
        countryCode: json['countryCode'],
        useremail: json['useremail'],
        name: json['name'],
        gender: json['gender'],
        dob: json['dob'],
        loginThrough: json['loginThrough'],
        loginBy: json['loginBy']);
  }

  // Method to convert a User to JSON
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'useremail': useremail,
      'name': name,
      'gender': gender,
      'dob': dob,
      'loginThrough': loginThrough,
      'loginBy': loginBy
    };
  }
}
