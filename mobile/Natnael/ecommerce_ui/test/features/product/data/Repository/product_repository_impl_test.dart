import 'package:ecommerce_ui/core/platform/network_info.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_ui/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_ui/features/product/data/repository/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements ProductRemoteDataSource{

}

class MockLocaDataSource extends Mock implements ProductLocalDataSource{

}

class MockNetworkInfo extends Mock implements NetworkInfo{

}

void main(){
  ProductRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocaDataSource mockLocaDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp((){
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocaDataSource = MockLocaDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocaDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

}