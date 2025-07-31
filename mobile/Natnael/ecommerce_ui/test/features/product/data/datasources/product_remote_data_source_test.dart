import 'dart:convert';
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

  group('createProduct', () {
    final tProductJson =
        json.decode(fixture('products.json'))['data'][0] as Map<String, dynamic>;
    final tProductModel = ProductModel.fromJson(tProductJson);
    test('should perform a POST with correct URL, headers & body', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode({'data': tProductJson}), 201));

      await dataSource.createProduct(tProductModel);

      verify(mockHttpClient.post(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tProductModel.toJson()),
      ));
    });

    test('should return ProductModel on HTTP 201', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode({'data': tProductJson}), 201));

      final result = await dataSource.createProduct(tProductModel);

      expect(result, ProductModel.fromJson(tProductJson));
    });

    test('should throw Exception on non-201 response', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      final call = dataSource.createProduct(tProductModel);

      expect(call, throwsA(isA<Exception>()));
    });
  });

  group('deleteProduct', () {
    final tId = '1';
    test(
        'should perform a DELETE on correct URL and return void when status is 204',
        () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await dataSource.deleteProduct(tId);

      verify(mockHttpClient.delete(
          Uri.parse(
              'https://g5-flutter-learning-path-be.onrender.com/api/v1/products/$tId'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should throw Exception when response status is not 204', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 400));

      final call = dataSource.deleteProduct(tId);

      expect(call, throwsA(isA<Exception>()));
    });
  });

  group('getProductById', () {
    final tId = '667275f2b905525c145fe097';
    final tProductModel = ProductModel.fromJson(
        json.decode(fixture('product.json'))['data']);

    test('should return ProductModel when response is 200', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(fixture('product.json'), 200));

      final result = await dataSource.getProductById(tId);

      expect(result, equals(tProductModel));
      verify(mockHttpClient.get(
        Uri.parse('https://g5-flutter-learning-path-be.onrender.com/api/v1/products/$tId'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should throw Exception when response code is not 200', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 404));

      final call = dataSource.getProductById(tId);

      expect(call, throwsA(isA<Exception>()));
    });
  });

  group('getProducts', () {
    final jsonList =
        json.decode(fixture('products.json'))['data'] as List;
    final tProductModelList =
        jsonList.map((json) => ProductModel.fromJson(json)).toList();
    test('should return List<ProductModel> when response is 200', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(fixture('products.json'), 200));

      final result = await dataSource.getProducts();

      expect(result, equals(tProductModelList));
      verify(mockHttpClient.get(
        Uri.parse('https://g5-flutter-learning-path-be.onrender.com/api/v1/products'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should throw Exception when response code is not 200', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final call = dataSource.getProducts();

      expect(call, throwsA(isA<Exception>()));
    });
  });

  group('updateProduct', () {
    final tProductJson =
        json.decode(fixture('products.json'))['data'][0] as Map<String, dynamic>;
    final tProductModel = ProductModel.fromJson(tProductJson);

    test(
        'should perform a PUT with correct URL, headers & body and return ProductModel when status is 200',
        () async {
      when(mockHttpClient.put(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode({'data': tProductJson}), 200));

      final result = await dataSource.updateProduct(tProductModel);

      verify(mockHttpClient.put(
        Uri.parse(
            'https://g5-flutter-learning-path-be.onrender.com/api/v1/products/${tProductModel.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tProductModel.toJson()),
      ));
      expect(result, ProductModel.fromJson(tProductJson));
    });

    test('should throw Exception when response status is not 200', () async {
      when(mockHttpClient.put(any,
              headers: anyNamed('headers'),
              body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      final call = dataSource.updateProduct(tProductModel);

      expect(call, throwsA(isA<Exception>()));
    });
  });
}

