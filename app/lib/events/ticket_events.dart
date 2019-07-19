import 'package:equatable/equatable.dart';

import 'package:app/ticket.dart';

class TicketEvent extends Equatable {
  TicketEvent([List props = const []]) : super(props);
}

class TicketPageChanged extends TicketEvent {
  final int currentPage;
  TicketPageChanged(this.currentPage) : super([currentPage]);
}

class AddTicketEvent extends TicketEvent {
  final Ticket ticket;
  AddTicketEvent(this.ticket) : super([ticket]);
}

class ScannedEvent extends TicketEvent {
  final String data;
  ScannedEvent(this.data) : super([data]);
}
