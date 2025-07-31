import 'dart:convert';
import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

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
  static const BASE_URL = 'https://g5-flutter-learning-path-be.onrender.com/api/v1';

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await client.post(
      Uri.parse('$BASE_URL/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create product');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final response = await client.delete(
      Uri.parse('$BASE_URL/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(
      Uri.parse('$BASE_URL/products'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)['data'];
      return jsonList
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await client.put(
      Uri.parse('$BASE_URL/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update product');
    }
  }
}