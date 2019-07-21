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
    if (event is PasswordEntered) {
      if (event.password.trim().length == 8) {
        var ticket = Ticket(uid: int.parse(event.password));
        await ticket.init(client, check: false);
        yield TicketInfoState(ticket: ticket);
      }
    }
    if (event is PhoneEntered) {
      if (event.phoneNumber.trim().length == 11) {
        var ticket = Ticket(phoneNumber: int.parse(event.phoneNumber));
        await ticket.init(client, check: false);
        yield TicketInfoState(ticket: ticket);
      }
    }
  }
}
