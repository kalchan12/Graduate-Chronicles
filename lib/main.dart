import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';

void main() {
  /*
    Ensures that widget bindings are initialized before calling runApp.
    This is required for platform channels and other native interactions.
  */
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap the app with ProviderScope to enable Riverpod globally.
  // This is the root of the state management tree.
  runApp(const ProviderScope(child: App()));
}
