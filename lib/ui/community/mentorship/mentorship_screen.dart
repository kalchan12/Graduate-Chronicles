import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../messaging/ui/chat_screen.dart';
import '../../../messaging/providers/messaging_provider.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../../theme/design_system.dart';
import '../../widgets/global_background.dart';
import '../../widgets/toast_helper.dart';

class MentorshipScreen extends ConsumerStatefulWidget {
  const MentorshipScreen({super.key});

  @override
  ConsumerState<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends ConsumerState<MentorshipScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filters = [
    'All',
    'Career',
    'Engineering',
    'Design',
    'Finance',
    'Research',
    'Marketing',
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _myMentorships = [];

  // Cache for other users' profiles (simple Map for now)
  final Map<String, Map<String, dynamic>> _userProfiles = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(supabaseServiceProvider);

      // Fetch data in parallel
      final results = await Future.wait([
        service.fetchMentorshipCandidates(),
        service.fetchMyMentorships(),
      ]);

      if (mounted) {
        setState(() {
          _mentors = results[0];
          _myMentorships = results[1];
        });

        await _enrichMentorships();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Error loading mentorships: $e');
      }
    }
  }

  Future<void> _enrichMentorships() async {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    if (myId == null) return;

    final service = ref.read(supabaseServiceProvider);

    // Collect IDs we need to fetch
    final Set<String> idsToFetch = {};
    for (var m in _myMentorships) {
      final otherId = m['mentee_id'] == myId ? m['mentor_id'] : m['mentee_id'];
      if (!_userProfiles.containsKey(otherId) && otherId != null) {
        idsToFetch.add(otherId);
      }
    }

    // Fetch profiles one by one (optimization: batch fetch if possible / future improvement)
    for (var id in idsToFetch) {
      try {
        final profile = await service.fetchUserProfile(id);
        if (profile != null) {
          String? avatarUrl;
          if (profile['profile_picture'] != null) {
            avatarUrl = Supabase.instance.client.storage
                .from('avatar')
                .getPublicUrl(profile['profile_picture']);
          }

          _userProfiles[id] = {
            'full_name': profile['full_name'] ?? 'User',
            'avatar_url': avatarUrl,
          };
        }
      } catch (e) {
        print('Error fetching profile for $id: $e');
      }
    }
  }

  void _showToast(String message) {
    ToastHelper.show(context, message);
  }

  Future<void> _handleRequest(String mentorId, String mentorName) async {
    try {
      await ref.read(supabaseServiceProvider).requestMentorship(mentorId);
      _showToast('Request sent to $mentorName');
      _loadData(); // Refresh to update UI state
    } catch (e) {
      if (e.toString().contains('duplicate')) {
        _showToast('You already have a mentorship with $mentorName');
      } else {
        _showToast('Failed to send request: $e');
      }
    }
  }

  Future<void> _openChat(
    String otherUserId,
    String otherUserName,
    String? avatarUrl,
  ) async {
    try {
      final messagingService = ref.read(messagingServiceProvider);
      final conversationId = await messagingService.getOrCreateConversation(
        otherUserId,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId,
              participantName: otherUserName,
              participantAvatar: avatarUrl,
              otherUserId: otherUserId,
            ),
          ),
        );
      }
    } catch (e) {
      _showToast('Failed to start chat: $e');
    }
  }

  Future<void> _handleAcceptMentorship(
    String mentorshipId,
    String userName,
  ) async {
    try {
      await ref
          .read(supabaseServiceProvider)
          .updateMentorshipStatus(mentorshipId, 'accepted');
      _showToast('Accepted mentorship with $userName');
      _loadData(); // Refresh to update UI
    } catch (e) {
      _showToast('Failed to accept: $e');
    }
  }

  Future<void> _handleRejectMentorship(
    String mentorshipId,
    String userName,
  ) async {
    try {
      await ref
          .read(supabaseServiceProvider)
          .updateMentorshipStatus(mentorshipId, 'rejected');
      _showToast('Rejected mentorship request');
      _loadData(); // Refresh to update UI
    } catch (e) {
      _showToast('Failed to reject: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current user Auth ID
    final myId = Supabase.instance.client.auth.currentUser?.id;

    // Filter Logic
    final filteredMentors = _mentors.where((mentor) {
      // Basic Search
      final name = mentor['full_name']?.toString().toLowerCase() ?? '';
      final role = mentor['role']?.toString().toLowerCase() ?? '';
      final job = mentor['job_title']?.toString().toLowerCase() ?? '';
      final company = mentor['company']?.toString().toLowerCase() ?? '';

      final matchesSearch =
          name.contains(_searchQuery.toLowerCase()) ||
          role.contains(_searchQuery.toLowerCase()) ||
          job.contains(_searchQuery.toLowerCase()) ||
          company.contains(_searchQuery.toLowerCase());

      // Filter by "Skills" or Job Title if we had category data.
      // For now, simple text filter or generic logic
      bool matchesFilter = true;
      if (_selectedFilter != 'All') {
        // Rudimentary category matching based on job/department text
        matchesFilter =
            job.contains(_selectedFilter) ||
            company.contains(_selectedFilter) ||
            role.contains(_selectedFilter);
      }

      // Hide those I already have a mentorship with (Active or Pending)
      final hasConnection = _myMentorships.any(
        (m) =>
            (m['mentor_id'] == mentor['auth_user_id'] ||
                m['mentee_id'] == mentor['auth_user_id']) &&
            m['status'] != 'rejected',
      );

      return matchesSearch && matchesFilter && !hasConnection;
    }).toList();

    // Separate Active/Pending Requests
    final activeRequests = _myMentorships
        .where((m) => m['status'] == 'pending' || m['status'] == 'accepted')
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mentorship',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: DesignSystem.purpleAccent,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1727),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Search by name, role, or company...',
                              hintStyle: TextStyle(color: Colors.white30),
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Colors.white30),
                              suffixIcon: Icon(
                                Icons.tune,
                                color: Colors.white30,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: filter,
                                  isSelected: _selectedFilter == filter,
                                  onTap: () =>
                                      setState(() => _selectedFilter = filter),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Active Requests Section
                        if (activeRequests.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Mentorships',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (activeRequests.length > 3)
                                const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: DesignSystem.purpleAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...activeRequests.map((request) {
                            // Determine if I am mentor or mentee
                            final isMeMentee = request['mentee_id'] == myId;
                            final otherId = isMeMentee
                                ? request['mentor_id']
                                : request['mentee_id'];
                            final mentorshipId = request['id'] as String;
                            final initiatorId =
                                request['initiator_id'] as String?;

                            // Determine if I should see the Accept/Reject buttons
                            // If initiator_id exists, I see buttons only if I am the Recipient (not initiator)
                            // Fallback: Assume Student -> Mentor request (so Mentor sees buttons)
                            final bool amITheRecipient = initiatorId != null
                                ? myId != initiatorId
                                : !isMeMentee;

                            final profile = _userProfiles[otherId] ?? {};

                            return _ActiveMentorshipCard(
                              status: request['status'],
                              date: request['created_at'],
                              isMeMentee: isMeMentee,
                              otherUserId: otherId,
                              otherName: profile['full_name'],
                              otherAvatar: profile['avatar_url'],
                              mentorshipId: mentorshipId,
                              amITheRecipient: amITheRecipient,
                              onMessage: () => _openChat(
                                otherId,
                                profile['full_name'] ?? 'User',
                                profile['avatar_url'],
                              ),
                              onAccept: () => _handleAcceptMentorship(
                                mentorshipId,
                                profile['full_name'] ?? 'User',
                              ),
                              onReject: () => _handleRejectMentorship(
                                mentorshipId,
                                profile['full_name'] ?? 'User',
                              ),
                            );
                          }),
                          const SizedBox(height: 32),
                        ],

                        // Suggested Candidates (Mentors or Mentees)
                        // We can check the first item's role or just use a generic title,
                        // but let's try to be specific if possible.
                        // Ideally we'd know OUR role here to set the title.
                        // For now, let's use "Suggested Connections" or similar.
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Suggested Connections',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.filter_list, color: Colors.white54),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (filteredMentors.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(
                                "No suggested connections found.",
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          )
                        else
                          ...filteredMentors.map(
                            (mentor) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _MentorCard(
                                name: mentor['full_name'] ?? 'User',
                                role: mentor['role'] ?? 'Graduate',
                                tags: [
                                  mentor['role'] ?? 'Alumni',
                                  // mentor['company'] ?? 'Industry', // Company not available in users table
                                ], // Placeholder tags
                                avatarUrl: mentor['avatar_url'],
                                onRequest: () => _handleRequest(
                                  mentor['auth_user_id'], // Use Auth ID for insert
                                  mentor['full_name'] ?? 'User',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : const Color(0xFF2B1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ActiveMentorshipCard extends ConsumerWidget {
  final String status;
  final String date;
  final bool isMeMentee;
  final String otherUserId;
  final String? otherName;
  final String? otherAvatar;
  final String mentorshipId;
  final bool amITheRecipient;
  final VoidCallback onMessage;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ActiveMentorshipCard({
    required this.status,
    required this.date,
    required this.isMeMentee,
    required this.otherUserId,
    this.otherName,
    this.otherAvatar,
    required this.mentorshipId,
    required this.amITheRecipient,
    required this.onMessage,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = status == 'accepted'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.amber);

    // Show accept/reject buttons if it is a pending request sent TO me
    final showActionButtons = status == 'pending' && amITheRecipient;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF241228),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            backgroundImage: otherAvatar != null
                ? NetworkImage(otherAvatar!)
                : null,
            child: otherAvatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName ??
                      (isMeMentee ? 'Mentorship Request' : 'Incoming Request'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMeMentee && status == 'pending')
                      const Text(
                        ' (Sent)',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (showActionButtons) ...[
            // Accept button
            IconButton(
              onPressed: onAccept,
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Accept',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(width: 4),
            // Reject button
            IconButton(
              onPressed: onReject,
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              tooltip: 'Reject',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ] else if (status == 'accepted')
            ElevatedButton(
              onPressed: onMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.purpleAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Message', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final String name;
  final String role;
  final List<String> tags;
  final String? avatarUrl;
  final VoidCallback onRequest;

  const _MentorCard({
    required this.name,
    required this.role,
    required this.tags,
    this.avatarUrl,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF241228),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DesignSystem.purpleAccent.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF2D1F35),
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 32,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.purpleAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: DesignSystem.purpleAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .where((t) => t.isNotEmpty)
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.purpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
