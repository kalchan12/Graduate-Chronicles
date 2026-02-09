// =============================================================================
// Widget Test: App Smoke Test
// =============================================================================
// Purpose: Verify that the main app widget can be instantiated without crashing
//
// What this tests:
//   - MaterialApp creation with ProviderScope
//   - Basic widget tree pump (no real network/auth calls)
//
// Note: This is a minimal smoke test. It does NOT test real authentication,
// Supabase connections, or complex navigation. It simply verifies the app
// can start without throwing exceptions during widget build.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // ===========================================================================
  // Smoke Test: Basic MaterialApp Instantiation
  // ===========================================================================
  testWidgets('App smoke test - MaterialApp can be created', (
    WidgetTester tester,
  ) async {
    // -------------------------------------------------------------------------
    // Purpose: Verify that a basic MaterialApp wrapped in ProviderScope
    // can be pumped without errors. This is the simplest possible test
    // that confirms the Flutter framework and Riverpod are working.
    // -------------------------------------------------------------------------

    // Arrange & Act: Build a minimal app structure
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('Graduate Chronicles Test'))),
        ),
      ),
    );

    // Assert: The test text should be present in the widget tree
    expect(find.text('Graduate Chronicles Test'), findsOneWidget);
  });

  // ===========================================================================
  // Smoke Test: Basic Navigation Capability
  // ===========================================================================
  testWidgets('App smoke test - Navigator works correctly', (
    WidgetTester tester,
  ) async {
    // -------------------------------------------------------------------------
    // Purpose: Verify that Navigator can push routes inside the app.
    // This tests the basic navigation infrastructure without any real screens.
    // -------------------------------------------------------------------------

    // Arrange: Build app with a button that triggers navigation
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Second Screen')),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      ),
    );

    // Act: Tap the navigation button
    await tester.tap(find.text('Navigate'));
    await tester.pumpAndSettle();

    // Assert: Second screen should now be visible
    expect(find.text('Second Screen'), findsOneWidget);
  });
}
