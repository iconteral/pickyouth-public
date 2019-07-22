import 'package:meta/meta.dart';

@immutable
abstract class ReturnState {}

class InitialReturnState extends ReturnState {}

class SuccessfulReturnState extends ReturnState {}

class FailedReturnState extends ReturnState {}
