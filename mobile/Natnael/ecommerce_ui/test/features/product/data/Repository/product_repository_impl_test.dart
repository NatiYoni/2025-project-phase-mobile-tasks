import 'package:dartz/dartz.dart';
import 'package:ecommerce_ui/core/error/failure.dart';
import 'package:ecommerce_ui/core/network/network_info.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:ecommerce_ui/features/product/data/repository/product_repository_impl.dart';
import 'package:ecommerce_ui/features/product/domain/entity/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_repository_impl_test.mocks.dart'; // Add this import

// Add this annotation to generate mocks for the following classes
@GenerateMocks([ProductRemoteDataSource, ProductLocalDataSource, NetworkInfo])
void main() {
  late ProductRepositoryImpl repository;
  // Use the generated mock classes
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    // Initialize the generated mock classes
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTests(String description, Function body, {required bool isOnline}) {
    group(description, () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => isOnline);
      });
      body();
    });
  }

  final tProductModels = [
    const ProductModel(
      id: '1',
      name: 'name',
      description: 'desc',
      imageUrl: 'img',
      price: 100,
    ),
    const ProductModel(
      id: '2',
      name: 'name2',
      description: 'desc2',
      imageUrl: 'img2',
      price: 200,
    ),
  ];
  final tProduct1 = tProductModels[0];
  final tId = '1';

  group('createProduct', () {
    final Product tProduct = tProduct1;

    runTests('when device is online', isOnline: true, () {
      test(
          'should call remote data source and cache locally when creating a product',
          () async {
        // arrange
        when(mockRemoteDataSource.createProduct(any))
            .thenAnswer((_) async => tProduct1);
        when(mockLocalDataSource.cacheProduct(any))
            .thenAnswer((_) async => Future.value());

        final result = await repository.createProduct(tProduct);
        // assert
        verify(mockRemoteDataSource.createProduct(tProduct1));
        verify(mockLocalDataSource.cacheProduct(tProduct1));
        expect(result, Right(tProduct1));
      });
    });

    runTests('when device is offline', isOnline: false, () {
      test('should return NetworkFailure', () async {
        // act
        final result = await repository.createProduct(tProduct);
        // assert
        expect(result, Left(NetworkFailure()));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });

  group('getProducts', () {
    runTests('when device is online', isOnline: true, () {
      test('should return remote data and cache it locally', () async {
        // arrange
        when(mockRemoteDataSource.getProducts())
            .thenAnswer((_) async => tProductModels);
        when(mockLocalDataSource.cacheProducts(any))
            .thenAnswer((_) async => Future.value());

        final result = await repository.getProducts();
        // assert
        verify(mockRemoteDataSource.getProducts());
        verify(mockLocalDataSource.cacheProducts(tProductModels));
        expect(result, Right(tProductModels));
      });
    });

    runTests('when device is offline', isOnline: false, () {
      test('should return locally cached data when present', () async {
        // arrange
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => tProductModels);
        // act
        final result = await repository.getProducts();
        // assert
        verify(mockLocalDataSource.getCachedProducts());
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Right(tProductModels));
      });
    });
  });

  group('getProductById', () {
    runTests('when device is online', isOnline: true, () {
      test('should return remote data and cache it locally', () async {
        // arrange
        when(mockRemoteDataSource.getProductById(any))
            .thenAnswer((_) async => tProduct1);
        when(mockLocalDataSource.cacheProduct(any))
            .thenAnswer((_) async => Future.value());

        final result = await repository.getProductById(tId);
        // assert
        verify(mockRemoteDataSource.getProductById(tId));
        verify(mockLocalDataSource.cacheProduct(tProduct1));
        expect(result, Right(tProduct1));
      });
    });

    runTests('when device is offline', isOnline: false, () {
      test('should return cached data', () async {
        // arrange
        when(mockLocalDataSource.getCachedProductById(any))
            .thenAnswer((_) async => tProduct1);
        // act
        final result = await repository.getProductById(tId);
        // assert
        verify(mockLocalDataSource.getCachedProductById(tId));
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Right(tProduct1));
      });
    });
  });

  group('updateProduct', () {
    final Product tProduct = tProduct1;

    runTests('when device is online', isOnline: true, () {
      test('should update remote and cache locally', () async {
        // arrange
        when(mockRemoteDataSource.updateProduct(any))
            .thenAnswer((_) async => tProduct1);
        when(mockLocalDataSource.cacheProduct(any))
            .thenAnswer((_) async => Future.value());

        final result = await repository.updateProduct(tProduct);
        // assert
        verify(mockRemoteDataSource.updateProduct(tProduct1));
        verify(mockLocalDataSource.cacheProduct(tProduct1));
        expect(result, Right(tProduct1));
      });
    });

    runTests('when device is offline', isOnline: false, () {
      test('should return NetworkFailure', () async {
        // act
        final result = await repository.updateProduct(tProduct);
        // assert
        expect(result, Left(NetworkFailure()));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });

  group('deleteProduct', () {
    runTests('when device is online', isOnline: true, () {
      test('should delete remote and local data', () async {
        // arrange
        when(mockRemoteDataSource.deleteProduct(any))
            .thenAnswer((_) async => Future.value());
        when(mockLocalDataSource.deleteCachedProduct(any))
            .thenAnswer((_) async => Future.value());

        final result = await repository.deleteProduct(tId);
        // assert
        verify(mockRemoteDataSource.deleteProduct(tId));
        verify(mockLocalDataSource.deleteCachedProduct(tId));
        expect(result, const Right(null));
      });
    });

    runTests('when device is offline', isOnline: false, () {
      test('should return NetworkFailure', () async {
        // act
        final result = await repository.deleteProduct(tId);
        // assert
        expect(result, Left(NetworkFailure()));
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });
}