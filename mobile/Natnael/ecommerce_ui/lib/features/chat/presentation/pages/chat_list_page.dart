import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/current_user.dart';

import '../../../../injection_container.dart';
import '../../../authentication/domain/entity/authentication.dart';
import '../../../product/presentation/pages/all_products_page.dart';
import '../../domain/entity/chat.dart';
import '../bloc/chat_bloc.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  final String token; // bearer token used to init socket
  const ChatListPage({super.key, required this.token});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _showUsers = false;
  ChatsLoaded? _lastLoaded; // cache to display while transient states occur
    bool _initialDispatched = false;
  @override
  void initState() {
    super.initState();
    // Dispatch initial events after first frame (ensure bloc exists)
    WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<ChatBloc>();
        if (!_initialDispatched) {
          _initialDispatched = true;
          bloc.add(InitializeSocketEvent(widget.token));
          bloc.add(GetChatsEvent());
          bloc.add(LoadUsersEvent(widget.token));
        }
    });
  }

  Future<void> _refresh() async {
    context.read<ChatBloc>().add(RefreshChatsEvent());
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatDetailPage(chat: chat),
        ),
      ),
    ).then((_) {
      // When returning from detail page, refresh list automatically.
      if (mounted) {
        context.read<ChatBloc>().add(RefreshChatsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        bottom: false,
        child: BlocListener<ChatBloc, ChatState>(
          listenWhen: (prev, curr) => curr is ChatInitiated || curr is ChatOperationFailure,
          listener: (context, state) {
            if (state is ChatInitiated) {
              // Navigate to detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ChatBloc>(),
                    child: ChatDetailPage(chat: state.chat),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatsLoaded) {
                _lastLoaded = state; // update cache
              }
              final showing = state is ChatsLoaded || state is ChatInitiating || state is ChatInitiated;
              if (state is ChatOperationFailure && _lastLoaded == null) {
                return _ErrorView(message: state.message, onRetry: () => context.read<ChatBloc>().add(GetChatsEvent()));
              }
              if (!showing && _lastLoaded == null) {
                // initial load
                if (state is ChatsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
              }
              final base = _lastLoaded;
              if (base == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Stack(
                children: [
                  _ChatListScaffold(
                    chats: base.chats,
                    users: base.users,
                    showUsers: _showUsers,
                    toggleUsers: () => setState(() => _showUsers = !_showUsers),
                    token: widget.token,
                    onRefresh: _refresh,
                    onOpenChat: _openChat,
                  ),
                  if (state is ChatInitiating)
                    Container(
                      color: Colors.black.withOpacity(0.25),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}

// ---- UI SUB-COMPONENTS --------------------------------------------------

class _ChatListScaffold extends StatelessWidget {
  final List<Chat> chats;
  final List<Authentication> users;
  final bool showUsers;
  final VoidCallback toggleUsers;
  final String token;
  final Future<void> Function() onRefresh;
  final void Function(Chat) onOpenChat;
  const _ChatListScaffold({required this.chats, required this.users, required this.showUsers, required this.toggleUsers, required this.token, required this.onRefresh, required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 12),
            const _Header(),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width:16),
              const Text('Chats', style: TextStyle(fontSize:16,fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: toggleUsers,
                icon: Icon(showUsers ? Icons.close : Icons.person_add_alt_1, size:18),
                label: Text(showUsers ? 'Close' : 'New Chat'),
              ),
            ],
          ),
          if (showUsers)
            _UsersInlineGrid(users: users, token: token),
          const SizedBox(height: 4),
          const SizedBox(height: 12),
          _ChatContainer(
            child: chats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(child: Text('No chats yet')),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _ChatRow(
                        chat: chat,
                        index: index,
                        onTap: () => onOpenChat(chat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF5),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Search', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1C59D2),
            child: Text('ME', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (context) {
              // Access parent ChatListPage to fetch token via context.findAncestorStateOfType not needed; pass via InheritedWidget simpler: using ModalRoute arguments is overkill.
              // Quick approach: rely on closure capturing by using context to read ChatListPage from widget tree.
              final stateWidget = context.findAncestorStateOfType<_ChatListPageState>();
              final token = stateWidget?.widget.token;
              return IconButton(
                tooltip: 'Products',
                onPressed: token == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AllProductsPage(token: token),
                          ),
                        );
                      },
                icon: const Icon(Icons.storefront_outlined, color: Color(0xFF1C59D2)),
              );
            },
          )
        ],
      ),
    );
  }
}


class _ChatContainer extends StatelessWidget {
  final Widget child;
  const _ChatContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: child,
    );
  }
}

class _ChatRow extends StatelessWidget {
  final Chat chat;
  final int index;
  final VoidCallback onTap;
  const _ChatRow({required this.chat, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
  final meId = CurrentUser.id;
  final isUser1Me = meId != null && chat.user1.id == meId;
  final other = isUser1Me ? chat.user2 : chat.user1;
  final otherName = other.name ?? other.email;
  final subText = chat.lastMessageContent ?? _placeholderSubtitle(index);
  final time = chat.lastMessageAt != null
    ? _formatTime(chat.lastMessageAt!)
    : _placeholderTime(index);
  final unread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(name: otherName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          subText,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C59D2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _placeholderSubtitle(int i) {
    const samples = [
      'How are you today?',
      "Don't miss to attend the meeting.",
      'Can you join the meeting?',
      'Hey! How are you today?',
      'Have a good day 🌸',
      'Are you coming?',
      'Let\'s catch up soon.',
    ];
    return samples[i % samples.length];
  }

  String _placeholderTime(int i) => '2 min ago';
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }
    return '${dt.month}/${dt.day}/${dt.year % 100}';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _bg(name),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _bg(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (p, c) => p + c);
    final palette = [
      const Color(0xFF00B3A6),
      const Color(0xFF1C59D2),
      const Color(0xFFEA5455),
      const Color(0xFFFFA000),
      const Color(0xFF2D9CDB),
      const Color(0xFF6C63FF),
    ];
    return palette[hash % palette.length];
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _UsersInlineGrid extends StatelessWidget {
  final List<Authentication> users; // Authentication
  final String token;
  const _UsersInlineGrid({required this.users, required this.token});
  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal:16.0, vertical:8),
        child: Text('No other users available.'),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(width:12),
        itemBuilder: (context, index) {
          final u = users[index];
          final name = (u.name == null || u.name!.isEmpty) ? u.email : u.name!;
          return GestureDetector(
            onTap: () => context.read<ChatBloc>().add(InitiateChatEvent(u.id ?? '')),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatListPageWrapper extends StatelessWidget {
  final String token;
  const ChatListPageWrapper({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // Use existing singleton without disposing it when page is popped.
    return BlocProvider.value(
      value: sl<ChatBloc>(),
      child: ChatListPage(token: token),
    );
  }
}
