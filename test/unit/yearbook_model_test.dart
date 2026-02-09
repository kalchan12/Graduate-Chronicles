// =============================================================================
// Unit Tests: Yearbook Model Classes
// =============================================================================
// Purpose: Test pure Dart model serialization logic (no Flutter widgets, no backend)
//
// What this tests:
//   - YearbookBatch: fromMap, toMap factory methods
//   - YearbookEntry: fromMap, toMap, copyWith methods
//
// These tests verify that model classes correctly parse and serialize data
// without requiring any external dependencies or network calls.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:graduate_chronicles/models/yearbook_entry.dart';

void main() {
  // ===========================================================================
  // YearbookBatch Tests
  // ===========================================================================
  group('YearbookBatch', () {
    // -------------------------------------------------------------------------
    // Test: fromMap correctly parses a valid map into a YearbookBatch object
    // -------------------------------------------------------------------------
    test('fromMap creates valid YearbookBatch from map', () {
      // Arrange: Create sample input data
      final map = {
        'id': 'batch-123',
        'batch_year': 2026,
        'batch_subtitle': 'ASTU Graduates',
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      // Act: Create YearbookBatch from map
      final batch = YearbookBatch.fromMap(map);

      // Assert: Verify all fields are correctly parsed
      expect(batch.id, equals('batch-123'));
      expect(batch.batchYear, equals(2026));
      expect(batch.batchSubtitle, equals('ASTU Graduates'));
      expect(batch.createdAt, isA<DateTime>());
    });

    // -------------------------------------------------------------------------
    // Test: toMap correctly serializes a YearbookBatch back to a map
    // -------------------------------------------------------------------------
    test('toMap serializes YearbookBatch correctly', () {
      // Arrange: Create a YearbookBatch instance
      final batch = YearbookBatch(
        id: 'batch-456',
        batchYear: 2025,
        batchSubtitle: 'Test Batch',
        createdAt: DateTime.parse('2025-06-15T10:30:00.000Z'),
      );

      // Act: Convert to map
      final map = batch.toMap();

      // Assert: Verify map contains correct key-value pairs
      expect(map['id'], equals('batch-456'));
      expect(map['batch_year'], equals(2025));
      expect(map['batch_subtitle'], equals('Test Batch'));
      expect(map['created_at'], contains('2025-06-15'));
    });

    // -------------------------------------------------------------------------
    // Test: fromMap handles null optional fields gracefully
    // -------------------------------------------------------------------------
    test('fromMap handles null batchSubtitle', () {
      // Arrange: Map without optional subtitle
      final map = {
        'id': 'batch-789',
        'batch_year': 2024,
        'batch_subtitle': null,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final batch = YearbookBatch.fromMap(map);

      // Assert: subtitle should be null, no exception thrown
      expect(batch.batchSubtitle, isNull);
    });
  });

  // ===========================================================================
  // YearbookEntry Tests
  // ===========================================================================
  group('YearbookEntry', () {
    // -------------------------------------------------------------------------
    // Test: fromMap creates a valid YearbookEntry from a complete map
    // -------------------------------------------------------------------------
    test('fromMap creates valid YearbookEntry from map', () {
      // Arrange: Complete sample data
      final map = {
        'id': 'entry-001',
        'user_id': 'user-abc',
        'batch_id': 'batch-123',
        'yearbook_photo_url': 'https://example.com/photo.jpg',
        'yearbook_bio': 'A dedicated student.',
        'status': 'approved',
        'created_at': '2026-01-15T08:00:00.000Z',
        'updated_at': '2026-01-16T12:00:00.000Z',
        'more_pictures': ['pic1.jpg', 'pic2.jpg'],
        'full_name': 'John Doe',
        'username': 'johndoe',
        'major': 'Computer Science',
        'school': 'ASTU',
      };

      // Act
      final entry = YearbookEntry.fromMap(map);

      // Assert: Verify core fields
      expect(entry.id, equals('entry-001'));
      expect(entry.userId, equals('user-abc'));
      expect(entry.yearbookPhotoUrl, equals('https://example.com/photo.jpg'));
      expect(entry.status, equals('approved'));
      expect(entry.morePictures, hasLength(2));
      expect(entry.fullName, equals('John Doe'));
    });

    // -------------------------------------------------------------------------
    // Test: toMap serializes YearbookEntry correctly (excludes joined fields)
    // -------------------------------------------------------------------------
    test('toMap serializes YearbookEntry correctly', () {
      // Arrange
      final entry = YearbookEntry(
        id: 'entry-002',
        userId: 'user-xyz',
        batchId: 'batch-456',
        yearbookPhotoUrl: 'https://example.com/entry2.jpg',
        yearbookBio: 'Passionate learner.',
        status: 'pending',
        createdAt: DateTime.parse('2026-02-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-02-02T00:00:00.000Z'),
        morePictures: ['extra1.jpg'],
      );

      // Act
      final map = entry.toMap();

      // Assert: Verify serialization (joined fields are NOT included in toMap)
      expect(map['id'], equals('entry-002'));
      expect(map['user_id'], equals('user-xyz'));
      expect(map['yearbook_bio'], equals('Passionate learner.'));
      expect(map['status'], equals('pending'));
      expect(map['more_pictures'], contains('extra1.jpg'));
    });

    // -------------------------------------------------------------------------
    // Test: copyWith creates a modified copy while preserving other fields
    // -------------------------------------------------------------------------
    test('copyWith creates modified copy correctly', () {
      // Arrange: Original entry
      final original = YearbookEntry(
        id: 'entry-003',
        userId: 'user-123',
        batchId: 'batch-789',
        yearbookPhotoUrl: 'https://example.com/original.jpg',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fullName: 'Jane Smith',
      );

      // Act: Create copy with modified status
      final updated = original.copyWith(status: 'approved');

      // Assert: Status changed, other fields unchanged
      expect(updated.status, equals('approved'));
      expect(updated.id, equals(original.id)); // Preserved
      expect(updated.fullName, equals('Jane Smith')); // Preserved
      expect(
        updated.yearbookPhotoUrl,
        equals(original.yearbookPhotoUrl),
      ); // Preserved
    });

    // -------------------------------------------------------------------------
    // Test: fromMap handles empty morePictures list
    // -------------------------------------------------------------------------
    test('fromMap handles null morePictures as empty list', () {
      // Arrange
      final map = {
        'id': 'entry-004',
        'user_id': 'user-test',
        'batch_id': 'batch-test',
        'yearbook_photo_url': 'https://example.com/test.jpg',
        'status': 'pending',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
        'more_pictures': null, // Null input
      };

      // Act
      final entry = YearbookEntry.fromMap(map);

      // Assert: Should default to empty list, not throw
      expect(entry.morePictures, isEmpty);
    });
  });
}
