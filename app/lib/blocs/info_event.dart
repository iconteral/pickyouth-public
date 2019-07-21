import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InfoEvent extends Equatable {
  InfoEvent([List props = const []]) : super(props);
}

class PasswordEntered extends InfoEvent {
  final String password;
  PasswordEntered({this.password});
}

class PhoneEntered extends InfoEvent {
  final String phoneNumber;
  PhoneEntered({this.phoneNumber});
}
