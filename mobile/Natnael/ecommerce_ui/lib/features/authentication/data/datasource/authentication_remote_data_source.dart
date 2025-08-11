import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../model/authentication_model.dart';

abstract class AuthenticationRemoteDataSource {

  /// Calls an authentication and sent it ot the API
  Future<AuthenticationModel> signUp(AuthenticationModel authentication);

   /// Calls the API endpoint to login.
   ///
  /// Throws a [ServerException] for all error codes.
  Future<String> login(AuthenticationModel authentication);

  /// Fetch all users (requires bearer token header)
  Future<List<AuthenticationModel>> getAllUsers(String token);

  /// Fetch current user profile
  Future<AuthenticationModel> getCurrentUser(String token);


}



class AuthenticationRemoteDataSourceImpl implements AuthenticationRemoteDataSource{
  final http.Client client;
  static const BASE_URL = 'https://g5-flutter-learning-path-be-tvum.onrender.com';

  AuthenticationRemoteDataSourceImpl({required this.client});


  Future<T> _performRequest<T>(
    Future<http.Response> Function() request, {
    required int successStatusCode,
    required T Function(dynamic data) fromJson,
  }) async {
      final response = await request();
      if (response.statusCode == successStatusCode) {
        if (response.body.isEmpty) {
          return fromJson(null);
        }
        final jsonResponse = jsonDecode(response.body);
        return fromJson(jsonResponse['data']);
      } else {
        throw ServerException();
      
    } 
  }


  
  @override
  Future<String> login(AuthenticationModel authentication) async {
    final response = await client.post(
      Uri.parse('$BASE_URL/api/v2/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(authentication.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['data']?['access_token'] ?? body['data']['access_token'];
    }
    throw ServerException();
  }

  @override
  Future<AuthenticationModel> signUp(AuthenticationModel authentication) {
    return _performRequest(
      () => client.post(
        Uri.parse('$BASE_URL/api/v2/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(authentication.toJson()),
      ),
      successStatusCode: 201,
      fromJson: (data) => AuthenticationModel.fromJson(data),
    );
  }

  @override
  Future<List<AuthenticationModel>> getAllUsers(String token) {
    return _performRequest(
      () => client.get(
        // Correct users endpoint
        Uri.parse('$BASE_URL/api/v3/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
      successStatusCode: 200,
      fromJson: (data) {
        // Debug assistance
        try {
          // ignore: avoid_print
          print('[getAllUsers] raw data type=${data.runtimeType}');
        } catch (_) {}
        if (data == null) return <AuthenticationModel>[];
        if (data is List) {
          return data
              .whereType<dynamic>()
              .map((u) => AuthenticationModel.fromJson((u as Map).cast<String, dynamic>()))
              .toList();
        }
        // Some APIs wrap list inside an object like { users: [...] }
        if (data is Map) {
          final possible = data['users'] ?? data['data'] ?? data['results'];
          if (possible is List) {
            return possible
                .whereType<dynamic>()
                .map((u) => AuthenticationModel.fromJson((u as Map).cast<String, dynamic>()))
                .toList();
          }
        }
        return <AuthenticationModel>[];
      },
    );
  }

  @override
  Future<AuthenticationModel> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/api/v3/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      return AuthenticationModel.fromJson(data);
    }
    throw ServerException();
  }
}