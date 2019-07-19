import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginFailedEvent extends LoginEvent {
  final String errorMessage;

  LoginFailedEvent({this.errorMessage = "登录失败"}) : super([errorMessage]);
}

class LoginPressedEvent extends LoginEvent {
  final String username;
  final String password;

  LoginPressedEvent(this.username, this.password);
}

class LoggedInEvent extends LoginEvent {
  final Dio client;

  LoggedInEvent(this.client);
}
