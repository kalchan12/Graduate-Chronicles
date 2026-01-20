import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';

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
  final bool isLoading;

  const PortfolioState({
    this.achievements = const [],
    this.resumes = const [],
    this.certificates = const [],
    this.links = const [],
    this.isLoading = false,
  });

  PortfolioState copyWith({
    List<Map<String, dynamic>>? achievements,
    List<Map<String, dynamic>>? resumes,
    List<Map<String, dynamic>>? certificates,
    List<Map<String, dynamic>>? links,
    bool? isLoading,
  }) {
    return PortfolioState(
      achievements: achievements ?? this.achievements,
      resumes: resumes ?? this.resumes,
      certificates: certificates ?? this.certificates,
      links: links ?? this.links,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PortfolioNotifier extends Notifier<PortfolioState> {
  @override
  PortfolioState build() {
    return const PortfolioState(isLoading: true);
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

      state = state.copyWith(
        achievements: data['achievement'] ?? [],
        resumes: data['resume'] ?? [],
        certificates: data['certificate'] ?? [],
        links: data['link'] ?? [],
        isLoading: false,
      );
    } catch (e) {
      print('Portfolio Load Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addItem(String type, Map<String, dynamic> data) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.addPortfolioItem(type: type, data: data);

      // Force refresh current user portfolio
      // We assume we are viewing our own portfolio if we are adding stuff
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
