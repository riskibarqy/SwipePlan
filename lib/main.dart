import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'auth/user_session.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'groups/group_context.dart';
import 'groups/group_repository.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GroupContext>(create: (_) => GroupContext()),
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
          create: (_) => SupabaseUserSession(client),
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
        home: const AuthGate(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSub;
  Session? _session;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    _session = auth.currentSession;
    _authSub = auth.onAuthStateChange.listen(
      (event) => setState(() => _session = event.session),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
