import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SeatState extends Equatable {
  SeatState([List props = const []]) : super(props);
}

class InitialSeatState extends SeatState {}
