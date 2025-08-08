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


}



class AuthenticationRemoteDataSourceImpl implements AuthenticationRemoteDataSource{
  final http.Client client;
  static const BASE_URL = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2/auth';

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
  Future<String> login(AuthenticationModel authentication) {
    return _performRequest(
      () => client.post(
        Uri.parse('$BASE_URL/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(authentication.toJson()),
      ),
      successStatusCode: 201,
      fromJson: (data) => data['access_token'] as String,
    );
  }

  @override
  Future<AuthenticationModel> signUp(AuthenticationModel authentication) {
    return _performRequest(
      () => client.post(
        Uri.parse('$BASE_URL/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(authentication.toJson()),
      ),
      successStatusCode: 201,
      fromJson: (data) => AuthenticationModel.fromJson(data),
    );
  }  
}