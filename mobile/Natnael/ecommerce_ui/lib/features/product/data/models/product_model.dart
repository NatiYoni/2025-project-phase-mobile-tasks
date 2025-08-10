
import '../../domain/entity/product.dart';
import '../../../authentication/domain/entity/authentication.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.price,
    super.seller,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    Authentication? seller;
    final sellerJson = json['seller'];
    if (sellerJson is Map<String, dynamic>) {
      seller = Authentication(
        id: sellerJson['_id']?.toString(),
        name: sellerJson['name']?.toString(),
        email: sellerJson['email']?.toString() ?? '',
        password: null,
      );
    }
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      seller: seller,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      if (seller != null)
        'seller': {
          '_id': seller!.id,
          'name': seller!.name,
          'email': seller!.email,
        }
    };
  }

}
