import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {

  /// Calls a prodcut and sent it to the API .
  Future<ProductModel> createProduct(ProductModel product) ;


  ///deletes product from the api
  Future<void> deleteProduct(String id);


  /// Calls the API endpoint to get products.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<ProductModel>> getProducts() ;

  /// Calls the API endpoint to get products by id.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<ProductModel> getProductById(String id);

  ///updates product from the api
  Future<ProductModel> updateProduct(ProductModel product);
}


class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  static const BASE_URL = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2';

  ProductRemoteDataSourceImpl({required this.client});

  Future<T> _performRequest<T>(
    Future<http.Response> Function() request, {
    required int successStatusCode,
    required T Function(dynamic data) fromJson,
    required String error,
  }) async {
    try {
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
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    return _performRequest(
      () => client.post(
        Uri.parse('$BASE_URL/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
      successStatusCode: 201,
      fromJson: (data) => ProductModel.fromJson(data),
      error: 'Failed to create product',
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    return _performRequest(
      () => client.delete(
        Uri.parse('$BASE_URL/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ),
      successStatusCode: 204,
      fromJson: (_) {},
      error: 'Failed to delete product',
    );
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    return _performRequest(
      () => client.get(
        Uri.parse('$BASE_URL/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ),
      successStatusCode: 200,
      fromJson: (data) => ProductModel.fromJson(data),
      error: 'Failed to load product',
    );
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    return _performRequest(
      () => client.get(
        Uri.parse('$BASE_URL/products'),
        headers: {'Content-Type': 'application/json'},
      ),
      successStatusCode: 200,
      fromJson: (data) =>
          (data as List).map((json) => ProductModel.fromJson(json)).toList(),
      error: 'Failed to load products',
    );
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    return _performRequest(
      () => client.put(
        Uri.parse('$BASE_URL/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
      successStatusCode: 200,
      fromJson: (data) => ProductModel.fromJson(data),
      error: 'Failed to update product',
    );
  }
}