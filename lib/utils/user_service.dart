
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/model/model_user.dart';

class UserService {
  static Future<UserModel?> fetchUserData(String token) async {
    final url = Uri.parse('http://127.0.0.7:5000/getUserData');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return UserModel.fromJson(data['user']);
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
    }
    return null;
  }
}
