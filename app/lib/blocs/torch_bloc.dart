import 'package:torch/torch.dart';
import 'package:bloc/bloc.dart';
import 'package:app/events/torch_events.dart';
import 'package:app/states/torch_states.dart';

class TorchBloc extends Bloc<TorchEvent, TorchState> {
  @override
  TorchState get initialState => TorchState(turnedOn: false);

  @override
  Stream<TorchState> mapEventToState (TorchEvent event) async* {
    if (event is Toggle) {
      if (currentState.turnedOn) {
        Torch.turnOff();
      }else{
        Torch.turnOn();
      }
      yield TorchState(turnedOn: !currentState.turnedOn);
    }

  }
}
