import 'package:app/ticket.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InfoState {}

class TicketInfoState extends InfoState {
  final Ticket ticket;
  TicketInfoState({this.ticket});
}
