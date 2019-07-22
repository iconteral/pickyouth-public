import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SeatEvent extends Equatable {
  SeatEvent([List props = const []]) : super(props);
}

class LoadEvent extends SeatEvent {}

class SwitchSectionEvent extends SeatEvent {
  final String to;
  SwitchSectionEvent(this.to);
}
