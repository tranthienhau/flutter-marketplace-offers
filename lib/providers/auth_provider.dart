import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
  });

  AuthState copyWith({User? user, bool? isAuthenticated, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    final mockUser = User(
      id: 'user-1',
      name: 'Demo User',
      email: email,
    );
    state = AuthState(
      user: mockUser,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
