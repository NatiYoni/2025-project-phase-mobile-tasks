// import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {

  // Gets the cached [ProductModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<ProductModel> getLastProduct() ;

  Future<void> cacheProduct(ProductModel productToCache);
  Future<List<ProductModel>> getCachedProducts();
  Future<ProductModel> getCachedProductById(String id);
  Future<void> deleteCachedProduct(String id);
  Future<void> cacheProducts(List<ProductModel> products);
}

const CACHED_SINGLE_PRODUCT = 'CACHED_SINGLE_PRODUCT';
const CACHED_PRODUCTS_LIST = 'CACHED_PRODUCTS_LIST';
class ProductLocalDataSourceImpl implements ProductLocalDataSource{
  final SharedPreferences sharedPreferences;
  
  ProductLocalDataSourceImpl(this.sharedPreferences);

  List<Map<String, dynamic>> _getCachedProductList() {
    final jsonString = sharedPreferences.getString(CACHED_PRODUCTS_LIST);
    if (jsonString != null) {
      return (json.decode(jsonString) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      throw CacheException();
    }
  }
  
  @override
  Future<void> cacheProduct(ProductModel productToCache) {
    return sharedPreferences.setString(
      CACHED_SINGLE_PRODUCT,
      json.encode(productToCache.toJson()),
    );
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) {
    final productListJson =
        products.map((product) => product.toJson()).toList();
    return sharedPreferences.setString(
      CACHED_PRODUCTS_LIST,
      json.encode(productListJson),
    );
  }

  @override
  Future<void> deleteCachedProduct(String id) async {
    final jsonList = _getCachedProductList();
    jsonList.removeWhere((item) => item['id'] == id);
    await sharedPreferences.setString(
        CACHED_PRODUCTS_LIST, json.encode(jsonList));
  }

  @override
  Future<ProductModel> getCachedProductById(String id) {
    final jsonList = _getCachedProductList();
    final productJson =
        jsonList.firstWhere((item) => item['id'] == id, orElse: () => throw CacheException());
    return Future.value(ProductModel.fromJson(productJson));
  }

  @override
  Future<List<ProductModel>> getCachedProducts() {
    final jsonList = _getCachedProductList();
    final products =
        jsonList.map((item) => ProductModel.fromJson(item)).toList();
    return Future.value(products);
  }

  @override
  Future<ProductModel> getLastProduct() {
    final jsonString = sharedPreferences.getString(CACHED_SINGLE_PRODUCT);
    if(jsonString != null){
      return Future.value(ProductModel.fromJson(json.decode(jsonString)));
    }else{
      throw CacheException();
    }
    
  }}