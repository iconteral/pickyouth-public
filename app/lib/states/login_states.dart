class LoginState {}

class LoginInitial extends LoginState {
  @override
  String toString() {
    return "Login init";
  }
}

class LoggedIn extends LoginState {
  final Dio client;

  LoggedIn(this.client);
}

class LoginFailed extends LoginState {
  final String errorMessage;

  LoginFailed({this.errorMessage = "登录失败"});
}
