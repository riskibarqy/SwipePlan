import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AuthProviderType { supabase, clerk }

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.authProvider,
    this.supabaseRedirectUrl,
    this.clerkPublishableKey,
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

    final authProviderRaw =
        (env.maybeGet('AUTH_PROVIDER') ?? 'supabase').toLowerCase();
    final authProvider = AuthProviderType.values.firstWhere(
      (value) => value.name == authProviderRaw,
      orElse: () => AuthProviderType.supabase,
    );

    final clerkKey = env.maybeGet('CLERK_PUBLISHABLE_KEY');
    if (authProvider == AuthProviderType.clerk &&
        (clerkKey == null || clerkKey.isEmpty)) {
      throw StateError(
        'AUTH_PROVIDER=clerk but CLERK_PUBLISHABLE_KEY is not set in .env.',
      );
    }

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      supabaseRedirectUrl: supabaseRedirectUrl,
      authProvider: authProvider,
      clerkPublishableKey: clerkKey,
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? supabaseRedirectUrl;
  final AuthProviderType authProvider;
  final String? clerkPublishableKey;

  bool get usesSupabaseAuth => authProvider == AuthProviderType.supabase;
  bool get usesClerk => authProvider == AuthProviderType.clerk;
}
