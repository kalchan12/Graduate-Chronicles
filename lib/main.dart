import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduate_chronicles/core/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  /*
    Ensures that widget bindings are initialized before calling runApp.
    This is required for platform channels and other native interactions.
  */
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // DEBUG: Print to verify correct credentials (REMOVE after debugging)
  print('🔍 DEBUG - Supabase URL: ${dotenv.env['SUPABASE_URL']}');
  print(
    '🔍 DEBUG - Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 20)}...',
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  // Wrap the app with ProviderScope to enable Riverpod globally.
  // This is the root of the state management tree.
  runApp(const ProviderScope(child: App()));
}
