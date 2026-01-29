import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/messaging_provider.dart';
import '../../theme/design_system.dart';
import '../../ui/widgets/global_background.dart';
import '../../ui/widgets/custom_app_bar.dart';
import 'chat_screen.dart';

/// Screen for discovering and searching users to start conversations.
///
/// Features:
/// - Search bar for filtering users
/// - List of all users (except self)
/// - Tap to start/open conversation
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(messagingServiceProvider);
      final users = await service.fetchDiscoverableUsers();

      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _users);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['full_name'] as String? ?? '').toLowerCase();
        final username = (user['username'] as String? ?? '').toLowerCase();
        return name.contains(lowercaseQuery) ||
            username.contains(lowercaseQuery);
      }).toList();
    });
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    final authId = user['auth_user_id'] as String;
    final name = user['full_name'] as String? ?? 'User';
    final avatar = user['avatar_url'] as String?;

    try {
      final convoId = await ref
          .read(conversationsProvider.notifier)
          .startConversation(authId);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: convoId,
              participantName: name,
              participantAvatar: avatar,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start chat: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: Column(
          children: [
            // App Bar
            CustomAppBar(
              title: 'Discover',
              showLeading: true,
              onLeading: () => Navigator.of(context).pop(),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2B1F2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Search by name or username...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Users List
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DesignSystem.purpleAccent),
      );
    }

    // Error state
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load users',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadUsers,
              child: const Text(
                'Retry',
                style: TextStyle(color: DesignSystem.purpleAccent),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.people_outline,
              color: Colors.white.withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No users found'
                  : 'No users available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Users grid
    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: DesignSystem.purpleAccent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _UserTile(user: user, onTap: () => _startChat(user));
        },
      ),
    );
  }
}

/// Individual user tile widget.
class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] as String? ?? 'User';
    final username = user['username'] as String? ?? '';
    final avatar = user['avatar_url'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B141E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2B1F2E),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                ),
              ),
              child: ClipOval(
                child: avatar != null
                    ? Image.network(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 28,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white54, size: 28),
              ),
            ),
            const SizedBox(width: 14),

            // Name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (username.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@$username',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Chat button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: DesignSystem.purpleAccent,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: DesignSystem.purpleAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
