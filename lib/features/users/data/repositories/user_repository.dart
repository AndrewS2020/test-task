import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserRepository {
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users. Status code: ${response.statusCode}');
    }
  }
}
