import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';

class AppSessionController extends ChangeNotifier {
  AppSessionController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  StreamSubscription<UserProfile?>? _subscription;

  UserProfile? _currentUser;
  bool _isLoading = true;

  UserProfile? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  bool get isSignedIn => _currentUser != null && _currentUser!.isActive;

  void start() {
    _subscription ??= _authRepository.authStateChanges().listen((profile) {
      _currentUser = profile?.isActive == true ? profile : null;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithApple() async {
    _currentUser = await _authRepository.signInWithApple();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _currentUser = await _authRepository.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> softDeleteAccount() async {
    await _authRepository.softDeleteAccount();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String displayName,
    required String? avatarUrl,
  }) async {
    await _authRepository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

class AppSessionScope extends InheritedNotifier<AppSessionController> {
  const AppSessionScope({
    required AppSessionController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppSessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSessionScope>();
    assert(scope != null, 'AppSessionScope is missing.');

    return scope!.notifier!;
  }
}
