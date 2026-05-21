sealed class AuthActionState {
  const AuthActionState();
}

class AuthIdle extends AuthActionState {
  const AuthIdle();
}

class AuthLoading extends AuthActionState {
  const AuthLoading();
}

class AuthFailure extends AuthActionState {
  const AuthFailure(this.message);

  final String message;
}
