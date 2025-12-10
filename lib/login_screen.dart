import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(
    Future<void> Function(AuthFacade facade) action,
  ) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final facade = context.read<AuthFacade>();
      await action(facade);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Unexpected error, try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 40,
                        offset: Offset(0, 28),
                        color: Color(0x22000000),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.bolt, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SwipePlan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sign in to sync your swipes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child:
                              _error == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                    _error!,
                                    key: ValueKey(_error),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.login),
                                onPressed:
                                    _loading
                                        ? null
                                        : () => _handleAuth(
                                              (facade) => facade.signIn(
                                                email: _emailCtrl.text.trim(),
                                                password:
                                                    _passwordCtrl.text.trim(),
                                              ),
                                            ),
                                label: const Text('Sign In'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                icon: const Icon(Icons.person_add_alt_1),
                                onPressed:
                                    _loading
                                        ? null
                                        : () => _handleAuth(
                                              (facade) => facade.signUp(
                                                email: _emailCtrl.text.trim(),
                                                password:
                                                    _passwordCtrl.text.trim(),
                                              ),
                                            ),
                                label: const Text('Create Account'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.g_mobiledata),
                            onPressed:
                                _loading
                                    ? null
                                    : () => _handleAuth(
                                          (facade) => facade.signInWithGoogle(),
                                        ),
                            label: const Text('Continue with Google'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class AuthFacade {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signInWithGoogle();
}

class SupabaseAuthFacade implements AuthFacade {
  SupabaseAuthFacade(this._client, {this.redirectUrl});

  final SupabaseClient _client;
  final String? redirectUrl;

  @override
  Future<void> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
    );
  }
}
