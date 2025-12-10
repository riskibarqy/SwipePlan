import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swipeplan/login_screen.dart';

class _FakeAuthFacade implements AuthFacade {
  String? lastEmail;
  String? lastPassword;
  bool signInCalled = false;
  bool signUpCalled = false;
  bool signInWithGoogleCalled = false;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalled = true;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> signInWithGoogle() async {
    signInWithGoogleCalled = true;
  }
}

void main() {
  testWidgets('Login screen triggers sign in with entered credentials', (
    tester,
  ) async {
    final fakeFacade = _FakeAuthFacade();

    await tester.pumpWidget(
      Provider<AuthFacade>.value(
        value: fakeFacade,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'super-secret');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(fakeFacade.signInCalled, isTrue);
    expect(fakeFacade.lastEmail, 'test@example.com');
    expect(fakeFacade.lastPassword, 'super-secret');
  });
}
