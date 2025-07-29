import '../models/product_model.dart';

abstract class ProductLocalDataSource {

  // Gets the cached [ProductModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<ProductModel> getLastProductModel() ;

  Future<void> cacheProduct(ProductModel productToCache);

}