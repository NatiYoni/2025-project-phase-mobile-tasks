import 'dart:io';
// import 'package:ecommerce_ui/features/product/presentation/pages/edit_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entity/product.dart';
import '../bloc/product_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(GetSingleProductEvent(productId)),
      child: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ErrorState) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is LoadedAllProductState) {
            // This state is emitted after a successful deletion
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Product Deleted!')));
            Navigator.of(context).pop(true); // Pop and signal a refresh
          }
        },
        builder: (context, state) {
          if (state is LoadedSingleProductState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(state.product.name),
                actions: [
                  // IconButton(
                  //   icon: const Icon(Icons.edit),
                  //   onPressed: () async {
                  //     final result = await Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (_) => const EditProductPage(product: state.product),
                  //       ),
                  //     );
                  //     if (result == true) {
                  //       // Refresh details if the product was updated
                  //       context
                  //           .read<ProductBloc>()
                  //           .add(GetSingleProductEvent(productId));
                  //     }
                  //   },
                  // ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, state.product.id),
                  ),
                ],
              ),
              body: _buildProductDetails(context, state.product),
            );
          }
          // For Initial and Loading states
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrl.isNotEmpty)
            Center(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    // Handle both network and local file images
                    image: product.imageUrl.startsWith('http')
                        ? NetworkImage(product.imageUrl)
                        : FileImage(File(product.imageUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            product.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext blocContext, String productId) {
    showDialog(
      context: blocContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                blocContext.read<ProductBloc>().add(DeleteProductEvent(productId));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
