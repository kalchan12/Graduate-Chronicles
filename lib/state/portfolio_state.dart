import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';
import 'auth_provider.dart';

/*
  Portfolio State Management.
  
  Manages the fetching, adding, and removing of portfolio items.
  Follows the strict schema: Achievements, Resumes, Certificates, Links.
*/

class PortfolioState {
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> resumes;
  final List<Map<String, dynamic>> certificates;
  final List<Map<String, dynamic>> links;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final bool isLoading;

  final String? id; // Portfolio ID
  final int likes;
  final int views;
  final bool isLiked;

  // Owner Details (fetched separately to support viewing others)
  final String? ownerName;
  final String? ownerDegree;
  final String? ownerRole;

  const PortfolioState({
    this.achievements = const [],
    this.resumes = const [],
    this.certificates = const [],
    this.links = const [],
    this.profileImageUrl,
    this.coverImageUrl,
    this.isLoading = false,
    this.id,
    this.likes = 0,
    this.views = 0,
    this.isLiked = false,
    this.ownerName,
    this.ownerDegree,
    this.ownerRole,
  });

  PortfolioState copyWith({
    List<Map<String, dynamic>>? achievements,
    List<Map<String, dynamic>>? resumes,
    List<Map<String, dynamic>>? certificates,
    List<Map<String, dynamic>>? links,
    String? profileImageUrl,
    String? coverImageUrl,
    bool? isLoading,
    String? id,
    int? likes,
    int? views,
    bool? isLiked,
    String? ownerName,
    String? ownerDegree,
    String? ownerRole,
  }) {
    return PortfolioState(
      achievements: achievements ?? this.achievements,
      resumes: resumes ?? this.resumes,
      certificates: certificates ?? this.certificates,
      links: links ?? this.links,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isLoading: isLoading ?? this.isLoading,
      id: id ?? this.id,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      ownerName: ownerName ?? this.ownerName,
      ownerDegree: ownerDegree ?? this.ownerDegree,
      ownerRole: ownerRole ?? this.ownerRole,
    );
  }
}

class PortfolioNotifier extends Notifier<PortfolioState> {
  @override
  PortfolioState build() {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      return const PortfolioState();
    }
    return const PortfolioState(isLoading: false);
  }

  /*
    Load Portfolio for a specific User (Public ID).
    Resolves Auth ID first.
  */
  Future<void> loadPortfolio(String publicUserId) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(supabaseServiceProvider);

      // 1. Resolve Public ID -> Auth ID
      final authId = await service.getAuthIdFromPublicId(publicUserId);

      if (authId == null) {
        // User might not exist or data fetch failed
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. Fetch Data using Auth ID
      final data = await service.fetchPortfolio(authId);
      final portfolioId = data['portfolio_id'];

      Map<String, String?> images = {'profile': null, 'cover': null};
      Map<String, dynamic> stats = {'likes': 0, 'views': 0, 'isLiked': false};

      if (portfolioId != null) {
        images = await service.fetchPortfolioPictures(portfolioId);
        stats = await service.getPortfolioStats(portfolioId);

        // Increment View (Once per session/load ideally, we do it here for simplicity)
        // But only if it's NOT ME.
        final currentUser = service.currentUser;
        if (currentUser?.id != authId) {
          await service.incrementPortfolioView(portfolioId);
        }
      }

      // 3. Fetch Owner Profile Info
      final profile = await service.fetchUserProfile(authId);

      state = state.copyWith(
        achievements: data['achievement'] ?? [],
        resumes: data['resume'] ?? [],
        certificates: data['certificate'] ?? [],
        links: data['link'] ?? [],
        profileImageUrl: images['profile'],
        coverImageUrl: images['cover'],
        id: portfolioId,
        likes: stats['likes'],
        views: stats['views'],
        isLiked: stats['isLiked'],
        isLoading: false,
        ownerName: profile?['full_name'],
        ownerDegree: profile?['major'],
        ownerRole: profile?['role'],
      );
    } catch (e) {
      print('Portfolio Load Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadCurrentPortfolio() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(supabaseServiceProvider);
      final user = service.currentUser;

      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = await service.fetchPortfolio(user.id);
      final portfolioId = data['portfolio_id'];

      Map<String, String?> images = {'profile': null, 'cover': null};
      Map<String, dynamic> stats = {'likes': 0, 'views': 0, 'isLiked': false};

      if (portfolioId != null) {
        images = await service.fetchPortfolioPictures(portfolioId);
        stats = await service.getPortfolioStats(portfolioId);
      }

      // 3. Fetch Owner Profile Info
      final profile = await service.fetchUserProfile(user.id);

      state = state.copyWith(
        achievements: data['achievement'] ?? [],
        resumes: data['resume'] ?? [],
        certificates: data['certificate'] ?? [],
        links: data['link'] ?? [],
        profileImageUrl: images['profile'],
        coverImageUrl: images['cover'],
        id: portfolioId,
        likes: stats['likes'],
        views: stats['views'],
        isLiked: stats['isLiked'],
        isLoading: false,
        ownerName: profile?['full_name'],
        ownerDegree: profile?['major'],
        ownerRole: profile?['role'],
      );
    } catch (e) {
      print('Current Portfolio Load Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleLike() async {
    final portfolioId = state.id;
    if (portfolioId == null) return;

    // Optimistic Update
    final wasLiked = state.isLiked;
    final oldLikes = state.likes;

    state = state.copyWith(
      isLiked: !wasLiked,
      likes: wasLiked ? (oldLikes > 0 ? oldLikes - 1 : 0) : oldLikes + 1,
    );

    try {
      final service = ref.read(supabaseServiceProvider);
      await service.togglePortfolioLike(portfolioId);
    } catch (e) {
      // Revert on error
      state = state.copyWith(isLiked: wasLiked, likes: oldLikes);
      print("Like Error: $e");
    }
  }

  Future<void> addItem(String type, Map<String, dynamic> data) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.addPortfolioItem(type: type, data: data);

      // Force refresh current user portfolio
      final currentPublicId = await service.getCurrentUserId();
      if (currentPublicId != null) {
        await loadPortfolio(currentPublicId);
      }
    } catch (e) {
      print('Add Item Error: $e');
      // rethrow to let UI handle toast
      rethrow;
    }
  }

  Future<void> deleteItem(String portfolioId, String type) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.deletePortfolioItem(portfolioId, type);

      final currentPublicId = await service.getCurrentUserId();
      if (currentPublicId != null) {
        await loadPortfolio(currentPublicId);
      }
    } catch (e) {
      print('Delete Item Error: $e');
      rethrow;
    }
  }
}

final portfolioProvider = NotifierProvider<PortfolioNotifier, PortfolioState>(
  PortfolioNotifier.new,
);

// Provider to fetch likes list
final portfolioLikesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      portfolioId,
    ) async {
      final service = ref.read(supabaseServiceProvider);
      return await service.fetchPortfolioLikes(portfolioId);
    });

// Provider to fetch views list
final portfolioViewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      portfolioId,
    ) async {
      final service = ref.read(supabaseServiceProvider);
      return await service.fetchPortfolioViews(portfolioId);
    });
