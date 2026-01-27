import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase/supabase_service.dart';
import '../models/yearbook_entry.dart';
import 'auth_provider.dart';

/*
  Yearbook State Management.
  
  Manages yearbook batches and entries with reactive state.
  Ensures data is fetched only for authenticated users and properly cleared on logout.
*/

class YearbookState {
  final List<YearbookBatch> batches;
  final List<YearbookEntry> entries;
  final List<String> majors;
  final YearbookEntry? myEntry;
  final bool isLoading;
  final String? errorMessage;

  const YearbookState({
    this.batches = const [],
    this.entries = const [],
    this.majors = const [],
    this.myEntry,
    this.isLoading = false,
    this.errorMessage,
  });

  YearbookState copyWith({
    List<YearbookBatch>? batches,
    List<YearbookEntry>? entries,
    List<String>? majors,
    YearbookEntry? myEntry,
    bool? isLoading,
    String? errorMessage,
    bool clearMyEntry = false,
  }) {
    return YearbookState(
      batches: batches ?? this.batches,
      entries: entries ?? this.entries,
      majors: majors ?? this.majors,
      myEntry: clearMyEntry ? null : (myEntry ?? this.myEntry),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class YearbookNotifier extends Notifier<YearbookState> {
  @override
  YearbookState build() {
    // Listen to auth for data isolation
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      return const YearbookState();
    }

    // Initial fetch of batches & majors
    // We use microtask to avoid "setState during build" errors if state is updated synchronously
    Future.microtask(() {
      loadBatches();
      loadMajors();
    });
    return const YearbookState(isLoading: true);
  }

  Future<void> loadMajors() async {
    // Do not set global loading for this as it's background
    try {
      final service = ref.read(supabaseServiceProvider);
      final majors = await service.fetchDistinctMajors();
      state = state.copyWith(majors: majors);
    } catch (e) {
      print('Load Majors Error: $e');
    }
  }

  Future<void> loadBatches() async {
    // We can set loading false here if we want, but better to handle strictly
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.fetchYearbookBatches();

      final batches = data.map((json) => YearbookBatch.fromMap(json)).toList();
      state = state.copyWith(batches: batches, isLoading: false);
    } catch (e) {
      print('Load Yearbook Batches Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createBatch(int year, String? subtitle) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.createYearbookBatch(
        batchYear: year,
        batchLabel: 'Class of $year',
        slogan: subtitle,
      );

      // Refresh list
      await loadBatches();
    } catch (e) {
      print('Create Batch Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> loadEntriesForBatch(
    String batchId, {
    String? majorFilter,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.fetchApprovedYearbookEntries(
        batchId: batchId,
        majorFilter: majorFilter,
      );

      final entries = data.map((json) => YearbookEntry.fromMap(json)).toList();
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      print('Load Yearbook Entries Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMyEntry(String batchId) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.fetchMyYearbookEntry(batchId);

      if (data != null) {
        final myEntry = YearbookEntry.fromMap(data);
        state = state.copyWith(myEntry: myEntry);
      } else {
        state = state.copyWith(clearMyEntry: true);
      }
    } catch (e) {
      print('Load My Entry Error: $e');
    }
  }

  Future<void> createEntry({
    required String batchId,
    required String yearbookPhotoUrl,
    String? yearbookBio,
    List<String>? morePictures,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.createYearbookEntry(
        batchId: batchId,
        yearbookPhotoUrl: yearbookPhotoUrl,
        yearbookBio: yearbookBio,
        morePictures: morePictures,
      );

      // Refresh my entry
      await loadMyEntry(batchId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('Create Entry Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateEntry({
    required String entryId,
    String? yearbookPhotoUrl,
    String? yearbookBio,
    required String batchId,
    List<String>? morePictures,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.updateYearbookEntry(
        entryId: entryId,
        yearbookPhotoUrl: yearbookPhotoUrl,
        yearbookBio: yearbookBio,
        morePictures: morePictures,
      );

      // Refresh my entry
      await loadMyEntry(batchId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('Update Entry Error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final yearbookProvider = NotifierProvider<YearbookNotifier, YearbookState>(
  YearbookNotifier.new,
);
