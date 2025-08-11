import 'dart:io';
// import 'package:ecommerce_ui/features/product/presentation/pages/edit_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entity/product.dart';
import '../bloc/product_bloc.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final String? authToken; // needed to init chat socket

  const ProductDetailPage({super.key, required this.productId, this.authToken});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProductBloc>()..add(GetSingleProductEvent(productId))),
      ],
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
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(context, state.product.id),
                  ),
                ],
              ),
              body: _buildProductDetails(context, state.product),
              bottomNavigationBar: _ContactSellerBar(product: state.product, token: authToken),
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

class _ContactSellerBar extends StatelessWidget {
  final Product product;
  final String? token;
  const _ContactSellerBar({required this.product, this.token});

  bool _isChatActionEnabled(ChatState state) {
    // Allow user to press initiate when socket ready or after failure to retry.
    return state is SocketReady || state is ChatsLoaded || state is ChatOperationFailure || state is ChatInitial;
  }

  @override
  Widget build(BuildContext context) {
    final seller = product.seller;
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) => curr is ChatInitiated || curr is ChatOperationFailure,
      listener: (context, state) {
        if (state is ChatInitiated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ChatBloc>(),
                child: ChatDetailPage(chat: state.chat),
              ),
            ),
          );
        } else if (state is ChatOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
  final enabled = seller != null && _isChatActionEnabled(state);
        final isBusy = state is ChatInitiating || state is SocketInitializing;
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (seller != null)
                  CircleAvatar(
                    child: Text(
                      (seller.name ?? seller.email).isNotEmpty
                          ? (seller.name ?? seller.email)[0].toUpperCase()
                          : '?',
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(seller?.name ?? 'Seller', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(product.name, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: enabled && !isBusy && token != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatListPageWrapper(token: token!),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C59D2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  label: Text(
                    isBusy ? 'Loading…' : 'Chat',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
