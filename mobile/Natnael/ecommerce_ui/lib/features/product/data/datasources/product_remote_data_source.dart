import 'dart:convert';
import 'dart:io';

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
  static const BASE_URL = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v1';

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
    // Backend expects multipart/form-data with fields: name, description, price, image (file)
    final uri = Uri.parse('$BASE_URL/products');
    final request = http.MultipartRequest('POST', uri);
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    if (product.imageUrl.isNotEmpty) {
      final file = File(product.imageUrl);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
      }
    }
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ProductModel.fromJson(jsonResponse['data']);
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
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
    // For now send JSON (without id/image unless changed) as backend sample shows simple body
    final body = jsonEncode({
      'name': product.name,
      'description': product.description,
      'price': product.price,
    });
    return _performRequest(
      () => client.put(
        Uri.parse('$BASE_URL/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ),
      successStatusCode: 200,
      fromJson: (data) => ProductModel.fromJson(data),
      error: 'Failed to update product',
    );
  }
}