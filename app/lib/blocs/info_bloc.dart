import 'dart:async';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/states/login_states.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import './info_event.dart';
import './info_state.dart';
import 'package:app/ticket.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  Dio client;
  @override
  InfoState get initialState => TicketInfoState();
  StreamSubscription subscription;
  LoginBloc loginBloc;

  InfoBloc(this.loginBloc) {
    subscription = loginBloc.state.listen((state) {
      if (state is LoggedIn) {
        client = state.client;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Stream<InfoState> mapEventToState(
    InfoEvent event,
  ) async* {
    if (event is Entered) {
      if (event.query.trim().length == 8) {
        var ticket = Ticket(uid: int.parse(event.query));
        await ticket.init(client, check: false);
        if (ticket.isVaild) {
          yield TicketInfoState(ticket: ticket);
        } else {
          yield TicketInfoState(
              ticket: (currentState as TicketInfoState).ticket, error: true);
        }
      }
      if (event.query.trim().length == 11) {
        var ticket = Ticket(phoneNumber: int.parse(event.query));
        await ticket.init(client, check: false);
        if (ticket.isVaild) {
          yield TicketInfoState(ticket: ticket);
        } else {
          yield TicketInfoState(
              ticket: (currentState as TicketInfoState).ticket, error: true);
        }
      }
      if (event.query.trim().length != 11 && event.query.trim().length != 8) {
        yield TicketInfoState(
            ticket: (currentState as TicketInfoState).ticket, error: true);
      }
    }
  }
}
