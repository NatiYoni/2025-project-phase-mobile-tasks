import 'package:dartz/dartz.dart';

import '../error/failure.dart';

class InputConverter{
  Either<Failure, double> stringToUnsignedDouble(String str){
    try{
      final integer = double.parse(str);
      if(integer < 0){
        throw const FormatException();
      }
      
      return Right(integer);
    }on FormatException{
      return Left(InvalidInputFailure());
    }
    
  }
}

class InvalidInputFailure extends Failure{}