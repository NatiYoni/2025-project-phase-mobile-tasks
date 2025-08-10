import 'package:flutter/material.dart';

import '../pages/product_detail_page.dart';

class BuildCards extends StatelessWidget {
  final dynamic product;
  final String? token;

  const BuildCards(BuildContext context, {super.key, required this.product, this.token});

  @override
  Widget build(BuildContext context) {

    return Card(
      clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(productId: product.id, authToken: token),
              ),
            );
          },

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.network(
                product.imageUrl,
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
                          style:  const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text('\$${product.price}'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       product.category,
                    //       style: const TextStyle(color: Colors.grey, fontSize: 12),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
            ),
        ),
      );
  }
}