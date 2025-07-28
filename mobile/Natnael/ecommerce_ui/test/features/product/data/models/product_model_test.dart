import 'dart:convert';

import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:ecommerce_ui/features/product/domain/entity/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tProductModel = const ProductModel(
    id: 15,
    name: 'this is my name',
    description: 'this one is realy cool',
    imageUrl: 'here we go',
    price: 284.0,
  );

  test('should be a subclass of Product entity', 
  () async {
    expect(tProductModel, isA<Product>());
  },
  );

  group('fromJson',(){
    test('should return a valid model',()async{
      //arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('product.json'));

      //act
      final result = ProductModel.fromJson(jsonMap);
      //assert
      expect(result, tProductModel);
    });
  });


  group('toJson',(){
    test('should return a json map containing the proper data',
    ()async{
      //arrange
      
      //act
      final result = tProductModel.toJson();
      //assert
      final expectedMap= {
        'name' : 'this is my name',
        'id' : 15,
        'description' : 'this one is realy cool',
        'imageUrl' : 'here we go',
        'price' : 284.0
      };
      expect(result, expectedMap);
    });
  });
}
