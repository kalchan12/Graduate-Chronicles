import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduate_chronicles/services/supabase/supabase_service.dart';
import 'package:graduate_chronicles/ui/widgets/toast_helper.dart';

/*
  Admin: Reports Monitoring Screen.
  
  Dashboard for reviewing reported posts.
  Features:
  - View reported content
  - Ban posts or dismiss reports
*/
class ReportsMonitoringScreen extends ConsumerStatefulWidget {
  const ReportsMonitoringScreen({super.key});

  @override
  ConsumerState<ReportsMonitoringScreen> createState() =>
      _ReportsMonitoringScreenState();
}

class _ReportsMonitoringScreenState
    extends ConsumerState<ReportsMonitoringScreen> {
  List<Map<String, dynamic>> _reportedPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReportedPosts();
  }

  Future<void> _loadReportedPosts() async {
    debugPrint('DEBUG: _loadReportedPosts() called');
    setState(() => _isLoading = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      debugPrint('DEBUG: Calling fetchReportedPosts...');
      final reports = await service.fetchReportedPosts();
      debugPrint(
        'DEBUG: fetchReportedPosts returned ${reports.length} reports',
      );
      if (mounted) {
        setState(() {
          _reportedPosts = List<Map<String, dynamic>>.from(reports);
          _isLoading = false;
          debugPrint(
            'DEBUG: _reportedPosts updated, count: ${_reportedPosts.length}',
          );
        });
      }
    } catch (e, stack) {
      debugPrint('ERROR loading reported posts: $e');
      debugPrint('Stack: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBanPost(String postId) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.banPost(postId);
      await _loadReportedPosts();
      if (mounted) {
        ToastHelper.show(
          context,
          'Post banned and removed.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context,
          'Error banning post: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleDismissReport(String reportId) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.dismissReport(reportId);
      await _loadReportedPosts();
      if (mounted) {
        ToastHelper.show(context, 'Report dismissed.', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context,
          'Error dismissing report: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130F25), Color(0xFF1E1030)],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Reports Monitoring',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadReportedPosts,
                  color: const Color(0xFF9B2CFF),
                  backgroundColor: const Color(0xFF2E0F3B),
                  child: _buildReportedContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportedContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reportedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text(
              'No reported content',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'All clear! No posts have been reported.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Pending Reports (${_reportedPosts.length})'),
          const SizedBox(height: 16),
          ...List.generate(_reportedPosts.length, (index) {
            final report = _reportedPosts[index];
            final post = report['posts'];

            if (post == null) {
              return _buildMissingContentCard(report);
            }

            return _buildReportCard(report, post);
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report,
    Map<String, dynamic> post,
  ) {
    final reporter = report['reporter'];
    final owner = post['owner'];

    final reason = report['reason'] ?? 'No reason provided';
    final createdAt =
        DateTime.tryParse(report['created_at'] ?? '') ?? DateTime.now();
    final timeAgo = DateTime.now().difference(createdAt).inHours;
    final timeLabel = timeAgo > 24
        ? '${(timeAgo / 24).floor()}d ago'
        : '${timeAgo}h ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1F2A2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'FLAGGED: ${reason.toString().toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (report['status'] ?? 'pending').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: Colors.redAccent.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reporter Info
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reported by: @${reporter?['username'] ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),

                  // Post Owner Info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.person, color: Colors.white38),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${owner?['username'] ?? 'unknown'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: #${owner?['institutional_id'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Post Description
                  Text(
                    post['description'] ?? 'No description',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),

                  // Post Image (if any)
                  if (post['image_url'] != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post['image_url'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 100,
                          color: Colors.grey.withValues(alpha: 0.2),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDismissReport(report['id']),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('DISMISS'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleBanPost(post['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'BAN POST',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
  }

  Widget _buildMissingContentCard(Map<String, dynamic> report) {
    final reason = report['reason'] ?? 'No reason provided';
    final createdAt =
        DateTime.tryParse(report['created_at'] ?? '') ?? DateTime.now();
    final timeAgo = DateTime.now().difference(createdAt).inHours;
    final timeLabel = timeAgo > 24
        ? '${(timeAgo / 24).floor()}d ago'
        : '${timeAgo}h ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1F2A2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CONTENT UNAVAILABLE (${reason.toString().toUpperCase()})',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This post was not found. It may have been deleted or there is a database inconsistency.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleDismissReport(report['id']),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('DISMISS REPORT'),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: const Color(0xFF9B2CFF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
