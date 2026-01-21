import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';
import 'auth_provider.dart';

/*
  Reunion State Management.
  
  Fetches and manages reunion events from Supabase.
*/

class ReunionState {
  final List<Map<String, dynamic>> reunions;
  final bool isLoading;
  final String? errorMessage;

  const ReunionState({
    this.reunions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReunionState copyWith({
    List<Map<String, dynamic>>? reunions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReunionState(
      reunions: reunions ?? this.reunions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ReunionNotifier extends Notifier<ReunionState> {
  @override
  ReunionState build() {
    // Listen to Auth for data isolation
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      return const ReunionState();
    }

    // Initial fetch
    Future.microtask(() => loadReunions());
    return const ReunionState(isLoading: true);
  }

  Future<void> loadReunions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.fetchReunions();
      state = state.copyWith(reunions: data, isLoading: false);
    } catch (e) {
      print('Load Reunions Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createReunion({
    required String title,
    required String description,
    required String date,
    required String time,
    required String locationType,
    required String locationValue,
    required String visibility,
    int? batchYear,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.createReunion(
        title: title,
        description: description,
        date: date,
        time: time,
        locationType: locationType,
        locationValue: locationValue,
        visibility: visibility,
        batchYear: batchYear,
      );

      // Refresh list after creation
      await loadReunions();
    } catch (e) {
      print('Create Reunion Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final reunionProvider = NotifierProvider<ReunionNotifier, ReunionState>(
  ReunionNotifier.new,
);
