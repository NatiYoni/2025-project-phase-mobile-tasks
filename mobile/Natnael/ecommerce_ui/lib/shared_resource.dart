import 'package:flutter/material.dart';
import 'model/products.dart';
import "model/products_access.dart";

class SharedResource {
  List<Card> buildCards(BuildContext context){
    List<Product> products = ProductsAccess().getProducts();

    if (products.isEmpty) {
      return const <Card>[];
    }

    return products.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/DetailPage', arguments: product);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                product.image,
                fit: BoxFit.fitWidth,
                height: 160,
                width: double.infinity,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('\$${product.price}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.type,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            Text(
                              "(${product.rating})",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
