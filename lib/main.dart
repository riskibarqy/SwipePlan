import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'auth/user_session.dart';
import 'clerk/noop_file_cache.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'groups/group_context.dart';
import 'watch_tab.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final config = AppConfig.fromEnv(dotenv);
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );
  runApp(SwipePlanApp(config: config));
}

class SwipePlanApp extends StatelessWidget {
  const SwipePlanApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    Widget app = MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        ChangeNotifierProvider<GroupContext>(create: (_) => GroupContext()),
        if (config.usesSupabaseAuth)
          Provider<AuthFacade>(
            create:
                (_) => SupabaseAuthFacade(
                  client,
                  redirectUrl: config.supabaseRedirectUrl,
                ),
          ),
        Provider<GroupRepository>(
          create: (_) => SupabaseGroupRepository(client),
        ),
        ChangeNotifierProvider<UserSession>(
          create: (context) {
            if (config.usesClerk) {
              final auth = ClerkAuth.of(context, listen: false);
              return ClerkUserSession(auth);
            }
            return SupabaseUserSession(client);
          },
        ),
        ChangeNotifierProvider<WatchController>(
          lazy: false,
          create:
              (context) => WatchController(
                watchRepository: SupabaseWatchRepository(client),
                swipeService: SupabaseSwipeService(
                  client,
                  context.read<UserSession>(),
                  context.read<GroupContext>(),
                ),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'SwipePlan',
        theme: AppTheme.light,
        home: AuthGate(config: config),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );

    if (config.usesClerk) {
      app = ClerkAuth(
        config: _buildClerkConfig(config),
        child: ClerkErrorListener(child: app),
      );
    }

    return app;
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.config});

  final AppConfig config;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSub;
  Session? _session;

  @override
  void initState() {
    super.initState();
    if (widget.config.usesSupabaseAuth) {
      _session = Supabase.instance.client.auth.currentSession;
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
        (event) => setState(() => _session = event.session),
      );
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.usesClerk) {
      return const _ClerkAuthGate();
    }
    if (_session == null) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}

class _ClerkAuthGate extends StatelessWidget {
  const _ClerkAuthGate();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: const Stack(
        children: [
          ClerkSignedIn(child: HomeScreen()),
          ClerkSignedOut(child: _ClerkResponsiveAuth()),
        ],
      ),
    );
  }
}

class _ClerkResponsiveAuth extends StatelessWidget {
  const _ClerkResponsiveAuth();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 880;
          final horizontalPadding = isWide ? 48.0 : 20.0;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 1100 : 640,
                ),
                child:
                    isWide
                        ? const Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _ClerkHeroPanel()),
                            SizedBox(width: 24),
                            Expanded(child: _ClerkFormPanel()),
                          ],
                        )
                        : const Column(
                          children: [
                            _ClerkHeroPanel(),
                            SizedBox(height: 16),
                            _ClerkFormPanel(),
                          ],
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClerkHeroPanel extends StatelessWidget {
  const _ClerkHeroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: BorderRadius.all(Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            offset: Offset(0, 28),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Powered by Clerk',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Sign in to continue planning together',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Use your preferred provider to access SwipePlan. '
              'All sessions stay synced across devices.',
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.movie, color: Colors.white),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondary,
                  child: const Icon(Icons.group, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Colors.black87,
                  child: Icon(Icons.security, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClerkFormPanel extends StatelessWidget {
  const _ClerkFormPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            offset: Offset(0, 28),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Secure login',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: const ClerkAuthentication(),
            ),
          ],
        ),
      ),
    );
  }
}

ClerkAuthConfig _buildClerkConfig(AppConfig config) {
  final publishableKey = config.clerkPublishableKey!;
  if (kIsWeb) {
    return ClerkAuthConfig(
      publishableKey: publishableKey,
      persistor: clerk.Persistor.none,
      fileCache: NoopClerkFileCache(),
    );
  }
  return ClerkAuthConfig(publishableKey: publishableKey);
}
