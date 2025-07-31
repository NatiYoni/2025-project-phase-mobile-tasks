import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entity/product.dart';


abstract class ProductRepository{

  Future<Either<Failure,List<Product> >> getProducts();
  Future<Either<Failure,Product>> getProductById(String id);
  Future<Either<Failure,Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
}