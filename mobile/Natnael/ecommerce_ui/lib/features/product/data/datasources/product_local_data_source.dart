import '../models/product_model.dart';

abstract class ProductLocalDataSource {

  // Gets the cached [ProductModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<ProductModel> getLastProduct() ;

  Future<void> cacheProduct(ProductModel productToCache);
  Future<List<ProductModel>> getCachedProducts();
  Future<ProductModel> getCachedProductById(int id);
  Future<void> deleteCachedProduct(int id);
  Future<void> cacheProducts(List<ProductModel> products);
}