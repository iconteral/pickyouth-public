import 'package:app/ticket.dart';

class TicketState {
  int currentTicket = 0;
  final List<Ticket> _ticketList;
  List<Ticket> get ticketList => _ticketList;
  TicketState({this.currentTicket = 0, ticketList = const <Ticket>[]})
      : this._ticketList = ticketList;
  bool isDuplicated({String uid}) {
    return _ticketList.any((ticket) => ticket.toString() == uid);
  }

  int find(Ticket ticket) {
    return _ticketList.indexOf(ticket);
  }
}
