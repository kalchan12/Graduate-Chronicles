import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduate_chronicles/services/supabase/supabase_service.dart';
import 'package:graduate_chronicles/ui/widgets/toast_helper.dart';

/*
  Admin: Yearbook Monitoring Screen.
  
  Dashboard for managing yearbook batches and approving entries.
  Features:
  - Create yearbook batches
  - Approve/reject yearbook entries
*/
class YearbookMonitoringScreen extends ConsumerStatefulWidget {
  const YearbookMonitoringScreen({super.key});

  @override
  ConsumerState<YearbookMonitoringScreen> createState() =>
      _YearbookMonitoringScreenState();
}

class _YearbookMonitoringScreenState
    extends ConsumerState<YearbookMonitoringScreen> {
  List<Map<String, dynamic>> _pendingYearbookEntries = [];
  List<Map<String, dynamic>> _yearbookBatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingEntries();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final service = ref.read(supabaseServiceProvider);
      final batches = await service.fetchYearbookBatches();
      if (mounted) {
        setState(
          () => _yearbookBatches = List<Map<String, dynamic>>.from(batches),
        );
      }
    } catch (e) {
      debugPrint('Error loading batches: $e');
    }
  }

  void _showCreateBatchDialog() {
    final labelController = TextEditingController();
    final yearController = TextEditingController();
    final sloganController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E0F3B),
        title: const Text(
          'Create Yearbook Batch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: labelController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Batch Label *',
                  hintText: 'e.g., Class of 2025',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B2CFF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Year (Optional)',
                  hintText: 'e.g., 2025',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B2CFF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: sloganController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Slogan / Motto (Optional)',
                  hintText: 'e.g., Built by resilience, defined by unity',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B2CFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final label = labelController.text.trim();
              if (label.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Batch label is required')),
                );
                return;
              }

              final year = yearController.text.isEmpty
                  ? null
                  : int.tryParse(yearController.text);
              final slogan = sloganController.text.trim();

              try {
                await ref
                    .read(supabaseServiceProvider)
                    .createYearbookBatch(
                      batchLabel: label,
                      batchYear: year,
                      slogan: slogan.isEmpty ? null : slogan,
                    );
                await _loadBatches();
                if (mounted) {
                  Navigator.pop(context);
                  ToastHelper.show(
                    context,
                    'Batch "$label" created successfully',
                    type: ToastType.success,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ToastHelper.show(context, 'Error: $e', type: ToastType.error);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B2CFF),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPendingEntries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      final entries = await service.fetchPendingYearbookEntries();
      setState(() {
        _pendingYearbookEntries = List<Map<String, dynamic>>.from(entries);
      });
    } catch (e) {
      debugPrint('Error loading pending entries: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(String entryId, bool isApproved) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      if (isApproved) {
        await service.approveYearbookEntry(entryId);
      } else {
        await service.rejectYearbookEntry(entryId);
      }

      await _loadPendingEntries();

      if (mounted) {
        ToastHelper.show(
          context,
          isApproved ? 'Entry Approved' : 'Entry Rejected',
          type: isApproved ? ToastType.success : ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error updating entry: $e');
      if (mounted) {
        ToastHelper.show(context, 'Error: $e', type: ToastType.error);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBatchDialog,
        backgroundColor: const Color(0xFF9B2CFF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Batch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
                        'Yearbook Monitoring',
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
                  onRefresh: () async {
                    await _loadBatches();
                    await _loadPendingEntries();
                  },
                  color: const Color(0xFF9B2CFF),
                  backgroundColor: const Color(0xFF2E0F3B),
                  child: _buildYearbookContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearbookContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Entries Section
          if (_pendingYearbookEntries.isNotEmpty) ...[
            _SectionHeader('Pending Approvals'),
            const SizedBox(height: 12),
            ...List.generate(_pendingYearbookEntries.length, (index) {
              final entry = _pendingYearbookEntries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _YearbookEntryCard(
                  entry: entry,
                  onApprove: () => _handleApproval(entry['id'], true),
                  onReject: () => _handleApproval(entry['id'], false),
                ),
              );
            }),
            const SizedBox(height: 30),
          ],

          // Batches Section
          _SectionHeader('Yearbook Batches'),
          const SizedBox(height: 8),
          const Text(
            'Manage graduation years for the yearbook',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),

          if (_yearbookBatches.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white24,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No batches created yet',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the button below to create your first batch',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_yearbookBatches.length, (index) {
              final batch = _yearbookBatches[index];
              return _BatchCard(batch: batch);
            }),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}

class _YearbookEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _YearbookEntryCard({
    required this.entry,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1F2A2438),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: entry['yearbook_photo_url'] != null
                    ? NetworkImage(entry['yearbook_photo_url'])
                    : null,
                child: entry['yearbook_photo_url'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['full_name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    entry['major'] ?? 'Unknown Major',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entry['yearbook_bio'] != null &&
              entry['yearbook_bio'].toString().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry['yearbook_bio'],
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

          const SizedBox(height: 12),

          if (entry['yearbook_photo_url'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                entry['yearbook_photo_url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 200,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('REJECT'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'APPROVE',
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

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final year = batch['batch_year'] as int?;
    final isActive = batch['is_active'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1F2A2438),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF9B2CFF).withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF2D1B36),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(
              Icons.calendar_today,
              color: isActive ? const Color(0xFF9B2CFF) : Colors.white38,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created ${_formatDate(batch['created_at'])}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF9B2CFF).withValues(alpha: 0.2)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF9B2CFF).withValues(alpha: 0.3)
                    : Colors.white24,
              ),
            ),
            child: Text(
              isActive ? 'ACTIVE' : 'INACTIVE',
              style: TextStyle(
                color: isActive ? const Color(0xFF9B2CFF) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final DateTime parsedDate = DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      }
      if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      }
      return '${(difference.inDays / 365).floor()} years ago';
    } catch (e) {
      return 'Unknown';
    }
  }
}
