import 'dart:convert';

import 'package:ecommerce_ui/core/error/exceptions.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'product_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])

void main() {
  late ProductLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProductLocalDataSourceImpl(mockSharedPreferences);
  });

  group('getLastProduct', () {
    final tProductModel =
        ProductModel.fromJson(json.decode(fixture('product_cached.json')));

    test(
        'should return product from sharedPreferences when there is one in the cache',
        () async {
      when(mockSharedPreferences.getString(CACHED_SINGLE_PRODUCT))
          .thenReturn(fixture('product_cached.json'));

      final result = await dataSource.getLastProduct();

      verify(mockSharedPreferences.getString(CACHED_SINGLE_PRODUCT));
      expect(result, equals(tProductModel));
    });

    test('should throw a CacheExeption when there is no cahe value',
        () async {
      when(mockSharedPreferences.getString(CACHED_SINGLE_PRODUCT))
          .thenReturn(null);
      expect(() => dataSource.getLastProduct(),
          throwsA(const TypeMatcher<CacheException>()));
    });
  });


  group('cacheProducts', () {
    final tProductModel = const [
      ProductModel(
        id: '1',
        name: 'Test Product',
        description: 'A test product description',
        imageUrl: 'just image',
        price: 9.99,
      ),
      ProductModel(
        id: '2',
        name: 'Product 2',
        description: 'product  2 description',
        imageUrl: 'this is an image',
        price: 98.99,
      ),
    ];
    test('should call SharedPreferences to cache the data',
        () async {
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      dataSource.cacheProducts(tProductModel);
      final expectedJsonString = json.encode(
          tProductModel.map((product) => product.toJson()).toList());
      verify(mockSharedPreferences.setString(
          CACHED_PRODUCTS_LIST, expectedJsonString));
    });
  });

  group('cacheProduct', () {
    final tProductModel =
        ProductModel.fromJson(json.decode(fixture('product_cached.json')));
    test(
      'should call SharedPreferences to cache the data',
      () async {
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);
        // act
        dataSource.cacheProduct(tProductModel);
        // assert
        final expectedJsonString = json.encode(tProductModel.toJson());
        verify(mockSharedPreferences.setString(
          CACHED_SINGLE_PRODUCT,
          expectedJsonString,
        ));
      },
    );
  });

  group('getCachedProducts', () {
    final List<dynamic> jsonList =
        json.decode(fixture('products_cached.json'));
    final tProductModelList =
        jsonList.map((json) => ProductModel.fromJson(json)).toList();
    test(
        'should return cached products from shared preferences when there are products in the cache',
        () async {
      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(fixture('products_cached.json'));

      final result = await dataSource.getCachedProducts();

      verify(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST));
      expect(result, equals(tProductModelList));
    });

    test('should throw a CacheException when there is no cahe value',
        () async {
      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(null);
      final call = dataSource.getCachedProducts;
      expect(call, throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('getCachedProductById', () {
    final tProductModel =
        ProductModel.fromJson(json.decode(fixture('product_cached.json')));
    test(
        'should return cached product from shared preferences when there is one in the cache with the given id',
        () async {
      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(fixture('products_cached.json'));

      final result = await dataSource.getCachedProductById(tProductModel.id);

      verify(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST));
      expect(result, equals(tProductModel));
    });

    test('should throw a CacheException when there is no cached value',
        () async {
      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(null);

      final call = dataSource.getCachedProductById;

      expect(() => call(tProductModel.id),
          throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('deleteCachedProduct', () {
    final tProductModelList = [
      ProductModel.fromJson(json.decode(fixture('product_cached.json'))),
    ];
    final tId = '15';

    test('should call SharedPreferences to delete the data', () async {
      final updatedList = json.decode(fixture('products_cached.json')) as List;
      updatedList.removeWhere((item) => ProductModel.fromJson(item).id == tId);
      final expectedJsonString = json.encode(updatedList);

      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(fixture('products_cached.json'));
      when(mockSharedPreferences.setString(
              CACHED_PRODUCTS_LIST, expectedJsonString))
          .thenAnswer((_) async => true);
      // act
      await dataSource.deleteCachedProduct(tId);
      // assert

      verify(mockSharedPreferences.setString(
        CACHED_PRODUCTS_LIST,
        expectedJsonString,
      ));
    });

    test('should throw a CacheException when there is no cached value',
        () async {
      when(mockSharedPreferences.getString(CACHED_PRODUCTS_LIST))
          .thenReturn(null);

      final call = dataSource.deleteCachedProduct;

      expect(() => call(tId), throwsA(const TypeMatcher<CacheException>()));
    });
  });
}

