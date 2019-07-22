import 'dart:async';
import 'package:bloc/bloc.dart';
import './seat_event.dart';
import './seat_state.dart';

class SeatBloc extends Bloc<SeatEvent, SeatState> {
  @override
  SeatState get initialState => InitialSeatState();

  @override
  Stream<SeatState> mapEventToState(
    SeatEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
