import 'package:dartz/dartz.dart';
import 'package:ecommerce_ui/core/util/input_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp((){
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt',
  (){
    test('should return an integer when the string represents an unsigned integer', (){
      //arrange
      final str = '1.05';

      //act
      final result = inputConverter.stringToUnsignedDouble(str);

      //
      expect(result,const Right(1.05));
    });

    test('should return a Failure when the string is not a number', (){
      //arrange
      final str = 'abc';

      //act
      final result = inputConverter.stringToUnsignedDouble(str);

      //
      expect(result,Left(InvalidInputFailure()));
    });

    test('should return a Failure when the string is a negative integer', (){
      //arrange
      final str = '-1.05';

      //act
      final result = inputConverter.stringToUnsignedDouble(str);

      //
      expect(result,Left(InvalidInputFailure()));
    });
  });
} 
