class Product {
  final String name;
  final double price;
  final double rating;
  final String description;
  final String image;
  final String type;
  final List<dynamic>? sizes;

  Product({required this.name, required this.price, 
          required this.rating,required this.description, 
          required this.image,required this.type, required this.sizes});
  
}