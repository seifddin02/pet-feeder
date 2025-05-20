import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _apiUrl = 'http://your-esp-home-api-address';

  static Future<bool> scheduleFeeding(String day, String time) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/schedule_feeding'),
      body: json.encode({
        'day': day,
        'time': time,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception('Failed to schedule feeding');
    }
  }
}
