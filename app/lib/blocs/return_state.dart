import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReturnState extends Equatable {
  ReturnState([List props = const []]) : super(props);
}

class InitialReturnState extends ReturnState {}

class SuccessfulReturnState extends ReturnState {}

class FailedReturnState extends ReturnState {}
