import 'dart:async';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/states/login_states.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import './seat_event.dart';
import './seat_state.dart';

class SeatBloc extends Bloc<SeatEvent, Loaded> {
  @override
  Loaded get initialState => Loaded(
      count: {'vip': 0, 'b': 0, 'c': 0, 'd': 0, 'e': 0, 'f': 0},
      currespondingUrl: '');

  StreamSubscription subscription;
  LoginBloc loginBloc;
  Dio client;

  SeatBloc(this.loginBloc) {
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
  Stream<Loaded> mapEventToState(
    SeatEvent event,
  ) async* {
    if (event is SwitchSectionEvent) {
      yield (Loaded(
          count: currentState.count,
          currespondingUrl:
              'http://reply2019.club/ty84961528/index-${event.to}.php'));
    }

    if (event is LoadEvent) {
      Response response = await client.get("/ticket/info/used_count");
      yield Loaded(
          count: response.data,
          currespondingUrl: currentState.currespondingUrl);
    }
  }
}
