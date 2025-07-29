
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {

  /// Calls a prodcut and sent it to the API .
  Future<ProductModel> createProduct(ProductModel product) ;


  ///deletes product from the api
  Future<ProductModel> deleteProduct(int id);


  /// Calls the API endpoint to get products.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<ProductModel>> getProduct() ;

  /// Calls the API endpoint to get products by id.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<ProductModel> getProductById(int id);

  ///updates product from the api
  Future<ProductModel> updateProduct(int id);
}