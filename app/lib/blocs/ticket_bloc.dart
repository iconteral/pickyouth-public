import 'dart:async';

import 'package:app/sound_player.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:app/states/login_states.dart';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/ticket.dart';

final player = SoundPlayer(['assets/scanned.mp3'])..init();

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
      List<Ticket> newList = List.from(currentState.ticketList);
      int ticketIndex = newList.indexOf(event.ticket);
      if (ticketIndex == -1) {
        newList.add(event.ticket);
      } else {
        newList.add(newList.removeAt(ticketIndex));
      }
      TicketState newState = TicketState(ticketList: newList);
      yield newState;
    }
    if (event is ScannedEvent) {
      player.play(0);
      Ticket ticket = Ticket(event.data);
      if (!currentState.isDuplicated(uid: event.data)) {
        await ticket.init(this.client);
        if (ticket.isVaild) {
          this.dispatch(AddTicketEvent(ticket));
        } else {
          this.dispatch(InvalidTicketEvent());
        }
      } else {
        this.dispatch(AddTicketEvent(ticket));
      }
    }
    if (event is TicketPageChanged) {
      yield TicketState(
          ticketList: currentState.ticketList, currentPage: event.currentPage);
    }
  }
}
