import 'dart:async';

import 'package:app/sound_player.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:app/states/login_states.dart';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/ticket.dart';

final player = SoundPlayer(
    ['assets/scanned.mp3', 'assets/wrong.mp3', 'assets/checked.mp3']);

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
        if (event.ticket.justChecked) {
          player.play(2);
        }
        int ticketIndex = currentState.ticketList.indexOf(event.ticket);
        if (ticketIndex == currentState.ticketList.length - 1) {
          List<Ticket> newList = List.from(currentState.ticketList);
          if (ticketIndex == -1) {
            newList.add(event.ticket);
          } else {
            newList.add(newList.removeAt(ticketIndex));
          }
          TicketState newState = TicketState(
              ticketList: newList, currentTicket: currentState.currentTicket);

          yield newState;
        }
      } else {
        player.play(1);
      }
    }
    if (event is ScannedEvent) {
      player.play(0);
      if (event.data.trim().length != 0) {
        dispatch(AddTicketEvent(Ticket(event.data)));
      }
    }
    if (event is TicketPageChanged) {
      yield TicketState(
          ticketList: currentState.ticketList,
          currentTicket: event.currentPage);
    }
  }
}
