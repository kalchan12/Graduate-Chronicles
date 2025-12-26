import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Wrap the app with ProviderScope to enable Riverpod globally.
  runApp(const ProviderScope(child: App()));
}
