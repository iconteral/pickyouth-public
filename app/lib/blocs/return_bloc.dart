import 'dart:async';
import 'package:app/states/login_states.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import './return_event.dart';
import './return_state.dart';

class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  @override
  ReturnState get initialState => InitialReturnState();

  StreamSubscription subscription;
  ReturnBloc loginBloc;
  Dio client;

  ReturnBloc(this.loginBloc) {
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
  Stream<ReturnState> mapEventToState(
    ReturnEvent event,
  ) async* {
    if (event is ReturnTicketEvent) {
      print('here');
    }
  }
}
