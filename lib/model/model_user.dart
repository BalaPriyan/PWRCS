class UserModel {
  final String fullname;
  final String email;
  final int credits;
  final List<String> history;

  UserModel({
    required this.fullname,
    required this.email,
    required this.credits,
    required this.history,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullname: json['fullname'],
      email: json['email'],
      credits: json['credits'],
      history: List<String>.from(json['history']),
    );
  }
}
