import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:vibration/vibration.dart';

import 'package:app/states/login_states.dart';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/ticket.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  @override
  TicketState get initialState => TicketState();
  StreamSubscription loginBlocSubscription;
  Dio client;

  final LoginBloc loginClientBloc;
  TicketBloc(this.loginClientBloc) {
    loginBlocSubscription = loginClientBloc.state.listen((state) {
      if (state is LoggedIn) {
        client = state.client;
      }
    });
  }

  @override
  void dispose() {
    loginBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Stream<TicketState> mapEventToState(TicketEvent event) async* {
    if (event is AddTicketEvent) {
      await event.ticket.init(client);
      if (event.ticket.isVaild) {
        if (event.ticket.justChecked && event.ticket.ticketNumber != 0) {
          Vibration.vibrate(duration: 1000);
        }
        int ticketIndex = currentState.ticketList.indexOf(event.ticket);
        if (ticketIndex == -1 ||
            ticketIndex != currentState.ticketList.length - 1) {
          List<Ticket> newList = List.from(currentState.ticketList);
          if (ticketIndex == -1) {
            newList.add(event.ticket);
          } else {
            newList.removeAt(ticketIndex);
            newList.add(event.ticket);
          }
          TicketState newState = TicketState(
              ticketList: newList, currentTicket: currentState.currentTicket);

          yield newState;
        }
      } else {}
    }
    if (event is ScannedEvent) {
      if (event.data.trim().length == 8) {
        try {
          if (currentState.ticketList.length == 0 ||
              currentState.ticketList.last.uid.toString() !=
                  event.data.trim()) {
            Vibration.vibrate(duration: 100);
            dispatch(AddTicketEvent(Ticket(uid: int.parse(event.data))));
          }
        } finally {
          print('error');
        }
      }
    }
    if (event is TicketPageChanged) {
      yield TicketState(
          ticketList: currentState.ticketList,
          currentTicket: event.currentPage);
    }
  }
}
