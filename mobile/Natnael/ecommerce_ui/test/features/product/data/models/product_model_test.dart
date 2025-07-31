import 'dart:convert';

import 'package:ecommerce_ui/features/product/data/models/product_model.dart';
import 'package:ecommerce_ui/features/product/domain/entity/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tProductModel = const ProductModel(
    id: '667275f2b905525c145fe097',
    name: 'Test Product',
    description: 'A single product for testing.',
    imageUrl: 'https://example.com/product.png',
    price: 123.45,
  );

  test(
    'should be a subclass of Product entity',
    () async {
      expect(tProductModel, isA<Product>());
    },
  );

  group('fromJson', () {
    test('should return a valid model', () async {
      //arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('product.json'));

      //act
      final result = ProductModel.fromJson(jsonMap['data']);
      //assert
      expect(result, tProductModel);
    });
  });

  group('toJson', () {
    test('should return a json map containing the proper data', () async {
      //act
      final result = tProductModel.toJson();
      //assert
      final expectedMap = json.decode(fixture('product.json'))['data'];
      expect(result, expectedMap);
    });
  });
}
        