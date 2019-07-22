import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReturnEvent extends Equatable {
  ReturnEvent([List props = const []]) : super(props);
}

class ReturnTicketEvent extends ReturnEvent {
  final String section;
  final String position;
  ReturnTicketEvent({this.section, this.position});
}
