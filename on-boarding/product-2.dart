//This project is a console based eCommerce that help the uset to add, 
//view single and all products registered so far, edit and delete as well

//ProductManager class
  //The addProduct method -  adds product to the a list and map (the map is later use for searching purpose in o(1))
  // The viewProduct method - prints all the registered products
  // The viewSingleProduct method - prints single product and it use o(1) to search that product
  // The editProduct method - enables user to edit any property of the product without affecting other properties
  // The DeletProduct method - enables user to delete any product he wants without affercting other products

import "dart:io";

void main(){
  var num;
  ProductManager manager = ProductManager();


  do{
    print("\nDear User, Chose a number that indicates what you wants to do from the menu");
    print('''
    ==========  Menu =========
    0. Exit
    1. Add Product
    2. View All Products
    3. View Single Product
    4. Edit Product
    5. Delete Product
    ===========================
    ''');
  
  stdout.write("Enter Your choice: ");
  num = stdin.readLineSync();
  
  switch (num){
    case "0":{ 
      print("Thank you for using our eCommerce");
      break;
    }
    case "1":{
      manager.addProduct();
      break;
    }
    case "2":{
      manager.viewProduct();
      break;
    }
    case "3":{
      manager.viewSingleProduct();
      break;
    }
    case "4":{
      manager.editProduct();
      break;
    }
    case "5":{
      manager.deletProduct();
      break;
    }
    default:{
      print("Please Enter a number from the menu");
      break;
    }
  }
  
  }while(num != "0");


}

class Product{
  String? name;
  String? description;
  double? price;

  Product(name,descr,price){
    this.name = name;
    this.description = descr;
    this.price = price;
  }
}

class ProductManager{

  var hash = {}; // map to make the search faster
  // var products = [];
  final List<Product> products = []; 

  void addProduct(){
    stdout.write("Dear user enter the product name: ");
    String? name = stdin.readLineSync();

    stdout.write("Dear user enter the product description: ");
    String? description = stdin.readLineSync();

    stdout.write("Dear user enter the price of the product: ");
    String? tempPrice = stdin.readLineSync();

    double? price = double.tryParse(tempPrice ?? ""); // tempPrice = input price

    if (name != null && description != null && price != null) {
      if (hash[name] == null){
        Product p = Product(name, description, price);
        products.add(p);
        hash[name] = products.length - 1;
        print('\nProduct added successfully\n');

      } else{
        print("The product is already registered, but if you want to update the price choose Edit from the menu.");
      }
      
    } else {
      print('Invalid input. Product not added.\n');
    }

  }

  void viewProduct(){
    print("\n Registered Products");
    if (products.length > 0){
      for (var i = 0; i < products.length; i++){
      print("${i + 1}.  ${products[i].name} : (${products[i].description}) ----- ${products[i].price}");

      }
    }else{
      print("You don't have registered product");
    }

  }
  void viewSingleProduct(){
    stdout.write("Enter the name of the product you wants to see: ");
    String? name = stdin.readLineSync();

    if (hash[name] != null){
      var val = hash[name];
      print("${val + 1}.  ${products[val].name} : (${products[val].description}) ----- \$${products[val].price}");
    } else{
      print("The product that you wants to see is not registered.");
    }
  }
  void editProduct(){
    stdout.write("Enter the name of the product: ");
    String? name = stdin.readLineSync();
    var val = hash[name] ;

    if (val != null){
      stdout.write('Enter the new name (leave blank to keep current): ');
      String? newName = stdin.readLineSync();
      stdout.write('Enter the new description (leave blank to keep current): ');
      String? newDesc = stdin.readLineSync();
      stdout.write('Enter teh new price (leave blank to keep current): ');
      String? newPrice = stdin.readLineSync();

      if (newName != null && newName != "") {
        products[val].name = newName;
      }
      if (newDesc != null && newDesc != "") {
        products[val].description = newDesc;
      }
      if (newPrice != null && newPrice != "") {
        double? parsed = double.tryParse(newPrice);
        if (parsed != null) {
          products[val].price = parsed;
        }
      }

      print('The Product has updated.\n');

    }else{
      print("The product doesn't exist. Please add it if you want");
    }
      
  }
  void deletProduct(){
    stdout.write("Enter the name of the product you wants to delet: ");
    String? name = stdin.readLineSync();

    var val = hash[name] ;

    if (val != null){
      products.removeAt(val);
      print("Product deleted SuccessFully");

      hash.clear();
      for (int i = 0; i < products.length; i++) {
        hash[products[i].name!] = i;
      }
    }else{
      print("Such Product doesn't exist");
    }

  }

}