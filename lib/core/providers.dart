// Riverpod providers and simple mock models for UI-first development.
// Import both flutter_riverpod and riverpod to ensure provider types are available.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple feed item model used by the home feed provider.
class FeedItem {
  final String id;
  final String title;
  final String subtitle;
  FeedItem({required this.id, required this.title, required this.subtitle});
}

// Simple profile model used by the profile provider.
class Profile {
  final String id;
  final String name;
  final String degree;
  final String year;
  Profile({required this.id, required this.name, required this.degree, required this.year});
}

// Simple message preview model used by the messages provider.
class MessagePreview {
  final String id;
  final String sender;
  final String lastMessage;
  final DateTime time;
  MessagePreview({required this.id, required this.sender, required this.lastMessage, required this.time});
}

// Simple batch summary model used by the batch provider.
class BatchSummary {
  final String id;
  final String title;
  final String subtitle;
  BatchSummary({required this.id, required this.title, required this.subtitle});
}

// Holds the selected bottom navigation index implemented with StateNotifier
// to avoid relying on `StateProvider` in environments where it's unavailable.
// Note: bottom navigation index is handled locally in the navigation widget.
// (Providers for feeds, profiles, messages, and batches remain below.)

// Mock feed provider returning a list of feed items.
final feedProvider = Provider<List<FeedItem>>((ref) {
  return [
    FeedItem(id: '1', title: 'Graduation Day', subtitle: 'The moment we\'ve all been waiting for.'),
    FeedItem(id: '2', title: 'Dean\'s List announced', subtitle: 'Congratulations to the top performers.'),
  ];
});

// Mock profile provider returning a sample profile.
final profileProvider = Provider<Profile>((ref) {
  return Profile(id: 'u1', name: 'Alex Doe', degree: 'B.Sc. in Computer Science', year: '2024');
});

// Mock messages provider returning a list of message previews.
final messagesProvider = Provider<List<MessagePreview>>((ref) {
  return [
    MessagePreview(id: 'm1', sender: 'Jessica Walsh', lastMessage: 'Totally! I\'ll send you an invite.', time: DateTime.now().subtract(const Duration(minutes: 20))),
    MessagePreview(id: 'm2', sender: 'Emily Carter', lastMessage: 'Great meeting earlier.', time: DateTime.now().subtract(const Duration(hours: 3))),
  ];
});

// Mock batch summaries provider.
final batchProvider = Provider<List<BatchSummary>>((ref) {
  return [
    BatchSummary(id: 'b1', title: 'Batch of \u201824', subtitle: 'Highlights and memories.'),
    BatchSummary(id: 'b2', title: 'Alumni Spotlight', subtitle: 'Where are they now?'),
  ];
});

// Profile achievements for the profile screen (mocked UI data).
final profileAchievementsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {
      'title': "Dean's List 2023",
      'subtitle': 'Awarded for outstanding academic performance throughout the fall and spring semesters.'
    },
    {
      'title': 'InnovateU Hackathon Winner',
      'subtitle': 'First place for developing a mobile app that connects student volunteers with local non-profits.'
    },
    {
      'title': 'President of Coding Club',
      'subtitle': 'Led a team of 50+ members, organizing weekly workshops and a university-wide coding competition.'
    },
  ];
});

// Directory/provider list used by the batch/directory screen (mock profiles).
final directoryProvider = Provider<List<Profile>>((ref) {
  return [
    Profile(id: 'p1', name: 'Jordan Lee', degree: 'Computer Science', year: '2024'),
    Profile(id: 'p2', name: 'Priya Sharma', degree: 'Business Administration', year: 'Alumni'),
    Profile(id: 'p3', name: 'Alex Chen', degree: 'Graphic Design', year: '2025'),
    Profile(id: 'p4', name: 'Maria Rodriguez', degree: 'Engineering', year: '2024'),
    Profile(id: 'p5', name: 'Kenji Tanaka', degree: 'Marketing', year: 'Alumni'),
    Profile(id: 'p6', name: 'Fatima Al-Sayed', degree: 'Biology', year: '2026'),
  ];
});
