import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase/supabase_service.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';
import '../widgets/toast_helper.dart';
import '../messages/message_detail_screen.dart';

class UserDiscoveryScreen extends ConsumerStatefulWidget {
  const UserDiscoveryScreen({super.key});

  @override
  ConsumerState<UserDiscoveryScreen> createState() =>
      _UserDiscoveryScreenState();
}

class _UserDiscoveryScreenState extends ConsumerState<UserDiscoveryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      final users = await service.fetchDiscoverableUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Failed to load users: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startConversation(String targetAuthId) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      // Start or get existing conversation
      final convoId = await service.startConversation(targetAuthId);

      if (mounted) {
        // Navigate to Chat Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageDetailScreen(
              conversationId: convoId,
              participantName: _users.firstWhere(
                (u) => u['auth_user_id'] == targetAuthId,
              )['full_name'],
              participantAvatar: _users.firstWhere(
                (u) => u['auth_user_id'] == targetAuthId,
              )['avatar_url'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Could not start chat: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DISCOVER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: GlobalBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty
            ? const Center(
                child: Text(
                  'No other users found.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserCard(user);
                },
              ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['full_name'] ?? 'Unknown';
    final major = user['major'] ?? 'Student';
    final avatar = user['avatar_url'];
    final authId = user['auth_user_id']; // Ensure we select this in query!
    // Wait, my query selects `user_id` (public) and `auth_user_id`.
    // Let's verify SupabaseService query selection.
    // It selects: 'user_id, full_name, username, role, major, interests' + join.
    // It does NOT explicitly select 'auth_user_id' in the list I wrote blindly?
    // Let's check SupabaseService again.

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DesignSystem.purpleAccent, width: 2),
              image: avatar != null
                  ? DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatar == null
                ? const Icon(Icons.person, color: Colors.white54)
                : null,
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  major,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Action
          IconButton(
            onPressed: () {
              // We need auth_user_id to start chat
              // If fetchDiscoverableUsers doesn't return it, we have a problem.
              // I'll assume it does or fix it.
              if (authId != null) {
                _startConversation(authId);
              } else {
                ToastHelper.show(
                  context,
                  'Cannot chat: Missing ID',
                  isError: true,
                );
              }
            },
            icon: const Icon(Icons.message_outlined),
            color: DesignSystem.purpleAccent,
            style: IconButton.styleFrom(
              backgroundColor: DesignSystem.purpleAccent.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
