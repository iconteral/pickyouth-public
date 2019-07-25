import 'package:app/ticket.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InfoState {}

class TicketInfoState extends InfoState {
  final Ticket ticket;
  final bool error;
  TicketInfoState({this.ticket, this.error = false});
}
