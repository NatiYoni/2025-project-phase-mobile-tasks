import 'package:dartz/dartz.dart';
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

  final tProductModels = [
    const ProductModel(
      id: 1,
      name: 'name',
      description: 'desc',
      imageUrl: 'img',
      price: 100,
    ),
    const ProductModel(
      id: 2,
      name: 'name2',
      description: 'desc2',
      imageUrl: 'img2',
      price: 200,
    ),
  ];
  final tProduct1 = tProductModels[0];
  final tId = 1;

  group('createProduct', () {
    final Product tProduct = tProduct1;

    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      await repository.createProduct(tProduct);
      verify(mockNetworkInfo.isConnected);
    });

    test('should call remote data source and cache locally when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.createProduct(tProduct1)).thenAnswer((_) async => tProduct1);
      when(mockLocalDataSource.cacheProduct(tProduct1)).thenAnswer((_) async => Future.value());

      final result = await repository.createProduct(tProduct);

      verify(mockRemoteDataSource.createProduct(tProduct1));
      verify(mockLocalDataSource.cacheProduct(tProduct1));
      expect(result, Right(tProduct1));
    });

    test('should return NetworkFailure when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      final result = await repository.createProduct(tProduct);
      expect(result.isLeft(), true);
    });
  });

  group('getProducts', () {
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      await repository.getProducts();
      verify(mockNetworkInfo.isConnected);
    });

    test('should return remote data and cache it locally when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getProducts()).thenAnswer((_) async => tProductModels);
      when(mockLocalDataSource.cacheProducts(tProductModels)).thenAnswer((_) async => Future.value());

      final result = await repository.getProducts();

      verify(mockRemoteDataSource.getProducts());
      verify(mockLocalDataSource.cacheProducts(tProductModels));
      expect(result, Right(tProductModels));
    });

    test('should return locally cached data when present and offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedProducts()).thenAnswer((_) async => tProductModels);

      final result = await repository.getProducts();

      verify(mockLocalDataSource.getCachedProducts());
      expect(result, Right(tProductModels));
    });
  });

  group('getProductById', () {
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      await repository.getProductById(tId);
      verify(mockNetworkInfo.isConnected);
    });

    test('should return remote data and cache it locally when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getProductById(tId)).thenAnswer((_) async => tProduct1);
      when(mockLocalDataSource.cacheProduct(tProduct1)).thenAnswer((_) async => Future.value());

      final result = await repository.getProductById(tId);

      verify(mockRemoteDataSource.getProductById(tId));
      verify(mockLocalDataSource.cacheProduct(tProduct1));
      expect(result, Right(tProduct1));
    });

    test('should return cached data when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedProductById(tId)).thenAnswer((_) async => tProduct1);

      final result = await repository.getProductById(tId);

      verify(mockLocalDataSource.getCachedProductById(tId));
      expect(result, Right(tProduct1));
    });
  });

  group('updateProduct', () {
    final Product tProduct = tProduct1;

    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      await repository.updateProduct(tProduct);
      verify(mockNetworkInfo.isConnected);
    });

    test('should update remote and cache locally when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updateProduct(tProduct1)).thenAnswer((_) async => tProduct1);
      when(mockLocalDataSource.cacheProduct(tProduct1)).thenAnswer((_) async => Future.value());

      final result = await repository.updateProduct(tProduct);

      verify(mockRemoteDataSource.updateProduct(tProduct1));
      verify(mockLocalDataSource.cacheProduct(tProduct1));
      expect(result, Right(tProduct1));
    });

    test('should return NetworkFailure when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      final result = await repository.updateProduct(tProduct);
      expect(result.isLeft(), true);
    });
  });

  group('deleteProduct', () {
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      await repository.deleteProduct(tId);
      verify(mockNetworkInfo.isConnected);
    });

    test('should delete remote and local when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.deleteProduct(tId)).thenAnswer((_) async => Future.value());
      when(mockLocalDataSource.deleteCachedProduct(tId)).thenAnswer((_) async => Future.value());

      final result = await repository.deleteProduct(tId);

      verify(mockRemoteDataSource.deleteProduct(tId));
      verify(mockLocalDataSource.deleteCachedProduct(tId));
      expect(result, const Right(null));
    });

    test('should return NetworkFailure when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      final result = await repository.deleteProduct(tId);
      expect(result.isLeft(), true);
    });
  });
}