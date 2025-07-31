import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entity/product.dart';
import '../../domain/repository/ProductRepository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  ProductModel _productToModel(Product product) => ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );

  Future<Either<Failure, T>> _getResponse<T>(
      Future<T> Function() remoteCall,
      [Future<T> Function()? localCall]) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await remoteCall());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      if (localCall != null) {
        try {
          return Right(await localCall());
        } catch (e) {
          return Left(CacheFailure());
        }
      } else {
        return Left(NetworkFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    final model = _productToModel(product);
    return await _getResponse<Product>(() async {
      final remoteProduct = await remoteDataSource.createProduct(model);
      await localDataSource.cacheProduct(remoteProduct);
      return remoteProduct;
    });
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    return await _getResponse<void>(() async {
      await remoteDataSource.deleteProduct(id);
      await localDataSource.deleteCachedProduct(id);
    });
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    return await _getResponse<List<Product>>(() async {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
      return remoteProducts;
    }, () async {
      return await localDataSource.getCachedProducts();
    });
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    return await _getResponse<Product>(() async {
      final remoteProduct = await remoteDataSource.getProductById(id);
      await localDataSource.cacheProduct(remoteProduct);
      return remoteProduct;
    }, () async {
      return await localDataSource.getCachedProductById(id);
    });
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    final model = _productToModel(product);
    return await _getResponse<Product>(() async {
      final updatedProduct = await remoteDataSource.updateProduct(model);
      await localDataSource.cacheProduct(updatedProduct);
      return updatedProduct;
    });
  }
}  