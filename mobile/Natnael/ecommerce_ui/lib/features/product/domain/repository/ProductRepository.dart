import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entity/product.dart';


abstract class ProductRepository{

  Future<Either<Failure,List<Product> >> getProduct();
  Future<Either<Failure,Product>> getProductById(int id);
  Future<Either<Failure,Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(int id);
  Future<Either<Failure, Product>> deleteProduct(int id);
}