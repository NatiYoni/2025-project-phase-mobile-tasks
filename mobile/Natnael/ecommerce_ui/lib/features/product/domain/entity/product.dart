import 'package:equatable/equatable.dart';
import '../../../authentication/domain/entity/authentication.dart';

class Product extends Equatable{
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final Authentication? seller; // nullable to maintain backward compatibility

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.seller,
    });
    
      @override
  List<Object?> get props => [id, name, description, imageUrl, price, seller];
}