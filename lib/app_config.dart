import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.supabaseRedirectUrl,
  });

  factory AppConfig.fromEnv(DotEnv env) {
    final supabaseUrl = env.maybeGet('SUPABASE_URL');
    final supabaseAnonKey = env.maybeGet('SUPABASE_ANON_KEY');
    final supabaseRedirectUrl = env.maybeGet('SUPABASE_REDIRECT_URL');

    if (supabaseUrl == null ||
        supabaseUrl.isEmpty ||
        supabaseAnonKey == null ||
        supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase credentials. Set SUPABASE_URL and SUPABASE_ANON_KEY in your .env file.',
      );
    }

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      supabaseRedirectUrl:
          supabaseRedirectUrl != null && supabaseRedirectUrl.isNotEmpty
              ? supabaseRedirectUrl
              : null,
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? supabaseRedirectUrl;
}
