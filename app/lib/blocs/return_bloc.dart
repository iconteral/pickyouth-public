import 'dart:async';
import 'package:app/blocs/login_bolc.dart';
import 'package:app/states/login_states.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import './return_event.dart';
import './return_state.dart';

class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  @override
  ReturnState get initialState => InitialReturnState();

  StreamSubscription subscription;
  LoginBloc loginBloc;
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
      var postData = {"section": event.section, "position": event.position};
      FormData formData = FormData.from(postData);
      Response response = await client.post("/return", data: formData);
      if (response.data.toString() == 'wrong') {
        yield SuccessfulReturnState();
      } else {
        yield FailedReturnState();
      }
    }
  }
}
