import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // Use localhost for Web/Windows, 10.0.2.2 for Android Emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }
  
  // In-memory token storage (for simplicity during hackathon MVP)
  static String? _token;
  static Map<String, dynamic>? _currentUser;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;

  static bool get isAuthenticated => _token != null;

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  /// Authenticates user and stores JWT token
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _currentUser = data['user'];
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  /// Registers user and stores JWT token
  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _currentUser = data['user'];
      return data;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  /// Fetches all workers (admin only)
  static Future<List<dynamic>> getWorkers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/workers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['workers'] ?? [];
    } else {
      throw Exception('Failed to fetch workers: ${response.statusCode}');
    }
  }

  /// Fetches tasks for Admin or Worker
  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tasks'] ?? [];
    } else {
      throw Exception('Failed to fetch tasks: ${response.statusCode}');
    }
  }

  /// Creates a task form Admin panel
  static Future<dynamic> createTask({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['task'];
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  /// Fetches alerts for logged in worker
  static Future<List<dynamic>> getWorkerAlerts(int workerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/$workerId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['alerts'] ?? [];
    } else {
      throw Exception('Failed to fetch alerts: ${response.statusCode}');
    }
  }
  /// Marks a task as completed
  static Future<dynamic> completeTask(int taskId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/complete'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['task'];
    } else {
      throw Exception('Failed to complete task: ${response.statusCode}');
    }
  }

  /// Fetches all zones with polygon data
  static Future<List<dynamic>> getZones() async {
    final response = await http.get(
      Uri.parse('$baseUrl/zones'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['zones'] ?? [];
    } else {
      throw Exception('Failed to fetch zones: ${response.statusCode}');
    }
  }

  /// Fetches latest worker locations
  static Future<List<dynamic>> getLocations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['locations'] ?? [];
    } else {
      throw Exception('Failed to fetch locations: ${response.statusCode}');
    }
  }

  /// Assigns a worker to a zone (admin)
  static Future<void> assignWorkerZone(int workerId, int zoneId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/workers/$workerId/assign-zone'),
      headers: headers,
      body: jsonEncode({'zoneId': zoneId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign zone: ${response.body}');
    }
  }

  /// Worker sends their current location
  static Future<Map<String, dynamic>> updateLocation(int workerId, double lat, double lng) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations'),
      headers: headers,
      body: jsonEncode({'workerId': workerId, 'latitude': lat, 'longitude': lng}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update location: ${response.statusCode}');
    }
  }

  /// Fetches all attendance records (admin)
  static Future<List<dynamic>> getAttendance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['attendance'] ?? [];
    } else {
      throw Exception('Failed to fetch attendance: ${response.statusCode}');
    }
  }

  /// Fetches all system alerts (admin)
  static Future<List<dynamic>> getAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['alerts'] ?? [];
    } else {
      throw Exception('Failed to fetch alerts: ${response.statusCode}');
    }
  }

  /// Clears session
  static void logout() {
    _token = null;
    _currentUser = null;
  }
}
