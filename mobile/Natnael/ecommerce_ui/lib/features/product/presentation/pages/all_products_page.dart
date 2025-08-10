import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/product_bloc.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../widgets/build_card.dart';
import 'create_product_page.dart';

class AllProductsPage extends StatefulWidget {
  final String token; // auth token for chat navigation
  final String? userName; // optional user name
  const AllProductsPage({super.key, required this.token, this.userName});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  late final String _todayLabel;
  // TODO: Replace with real fetched user name once /users/me integrated
  late String _userName;
  String get _initials => _userName.isNotEmpty ? _userName.trim()[0].toUpperCase() : 'U';

  @override
  void initState() {
    super.initState();
  final now = DateTime.now();
  _todayLabel = _formatDate(now);
  _userName = widget.userName?.trim().isNotEmpty == true ? widget.userName!.trim() : 'User';
  }

  String _formatDate(DateTime d) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${months[d.month-1]} ${d.day}, ${d.year}';
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductBloc>()..add(const LoadAllProductEvent()),
      child: Scaffold(
        appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(51, 158, 158, 158),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Row(
                children: [
                  const Text(
                    'Hello,',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),

        actions: [
          // Chat icon to jump to chat section
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatListPageWrapper(token: widget.token),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF616161)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(51, 158, 158, 158),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF616161)),
            ),
          ),
        ],
      ),

      
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LoadedAllProductState) {
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
      
                  return BuildCards(context,product: product, token: widget.token);
                },
              );
            } else if (state is ErrorState) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No Products Found'));
          },
        ),

        
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateProductPage()),
              );
              if (result == true) {
                context.read<ProductBloc>().add(const LoadAllProductEvent());
              }
            },
            child: const Icon(Icons.add),
          );
        }),
      ),
    );
  }
}