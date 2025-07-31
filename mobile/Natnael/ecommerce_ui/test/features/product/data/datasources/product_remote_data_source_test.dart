import 'dart:convert';
import 'package:ecommerce_ui/core/error/exceptions.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
@GenerateMocks(
  [],                                       // positional list of classes to mock
  customMocks: [MockSpec<http.Client>(as: #MockHttpClient)],
)
import 'product_remote_data_source_test.mocks.dart';

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ProductRemoteDataSourceImpl(client: mockHttpClient);
  });

  // For success
  void setUpMockHttpClientSuccess(
      Future<http.Response> Function() mock, String body, int statusCode) {
    when(mock()).thenAnswer((_) async => http.Response(body, statusCode));
  }

  //for failure
  void setUpMockHttpClientFailure(
      Future<http.Response> Function() mock, int statusCode) {
    when(mock()).thenAnswer((_) async => http.Response('Error', statusCode));
  }

  group('createProduct', () {
    final tProductJson =
        json.decode(fixture('products.json'))['data'][0] as Map<String, dynamic>;
    final tProductModel = ProductModel.fromJson(tProductJson);
    final tProductCreateJson = {'data': tProductJson};

    test(
        'should perform a POST request and return ProductModel on success (201)',
        () async {
      setUpMockHttpClientSuccess(
          () => mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')),
          jsonEncode(tProductCreateJson),
          201);

      final result = await dataSource.createProduct(tProductModel);

      expect(result, tProductModel);
      verify(mockHttpClient.post(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tProductModel.toJson()),
      ));
    });

    test('should throw ServerException on non-201 response', () async {
      setUpMockHttpClientFailure(
          () => mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')),
          400);

      final call = dataSource.createProduct(tProductModel);

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('deleteProduct', () {
    const tId = '1';
    test(
        'should perform a DELETE on correct URL and return void when status is 204',
        () async {
      setUpMockHttpClientSuccess(
          () => mockHttpClient.delete(any, headers: anyNamed('headers')),
          '',
          204);

      await dataSource.deleteProduct(tId);

      verify(mockHttpClient.delete(
          Uri.parse(
              'https://g5-flutter-learning-path-be.onrender.com/api/v1/products/$tId'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should throw ServerException when response status is not 204',
        () async {
      setUpMockHttpClientFailure(
          () => mockHttpClient.delete(any, headers: anyNamed('headers')), 400);

      final call = dataSource.deleteProduct(tId);

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('getProductById', () {
    const tId = '667275f2b905525c145fe097';
    final tProductModel =
        ProductModel.fromJson(json.decode(fixture('product.json'))['data']);

    test('should return ProductModel when response is 200', () async {
      setUpMockHttpClientSuccess(
          () => mockHttpClient.get(any, headers: anyNamed('headers')),
          fixture('product.json'),
          200);

      final result = await dataSource.getProductById(tId);

      expect(result, equals(tProductModel));
      verify(mockHttpClient.get(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products/$tId'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should throw ServerException when response code is not 200',
        () async {
      setUpMockHttpClientFailure(
          () => mockHttpClient.get(any, headers: anyNamed('headers')), 404);

      final call = dataSource.getProductById(tId);

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('getProducts', () {
    final jsonList = json.decode(fixture('products.json'))['data'] as List;
    final tProductModelList =
        jsonList.map((json) => ProductModel.fromJson(json)).toList();
    test('should return List<ProductModel> when response is 200', () async {
      setUpMockHttpClientSuccess(
          () => mockHttpClient.get(any, headers: anyNamed('headers')),
          fixture('products.json'),
          200);

      final result = await dataSource.getProducts();

      expect(result, equals(tProductModelList));
      verify(mockHttpClient.get(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should throw ServerException when response code is not 200',
        () async {
      setUpMockHttpClientFailure(
          () => mockHttpClient.get(any, headers: anyNamed('headers')), 500);

      final call = dataSource.getProducts();

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('updateProduct', () {
    final tProductJson =
        json.decode(fixture('products.json'))['data'][0] as Map<String, dynamic>;
    final tProductModel = ProductModel.fromJson(tProductJson);
    final tProductUpdateJson = {'data': tProductJson};

    test(
        'should perform a PUT request and return ProductModel on success (200)',
        () async {
      setUpMockHttpClientSuccess(
          () => mockHttpClient.put(any,
              headers: anyNamed('headers'), body: anyNamed('body')),
          jsonEncode(tProductUpdateJson),
          200);

      final result = await dataSource.updateProduct(tProductModel);

      expect(result, tProductModel);
      verify(mockHttpClient.put(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products/${tProductModel.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tProductModel.toJson()),
      ));
    });

    test('should throw ServerException when response status is not 200',
        () async {
      setUpMockHttpClientFailure(
          () => mockHttpClient.put(any,
              headers: anyNamed('headers'), body: anyNamed('body')),
          400);

      final call = dataSource.updateProduct(tProductModel);

      expect(call, throwsA(isA<ServerException>()));
    });
  });
}

