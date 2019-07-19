import 'package:app/sound_player.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

final player = SoundPlayer(['assets/wrong.mp3', 'assets/checked.mp3']);

class Ticket extends Equatable {
  String uid;
  String phoneNumber;
  bool isChecked;
  DateTime checkedDate;
  bool isVaild = false;
  Ticket(this.uid, {this.phoneNumber, this.isChecked, this.checkedDate})
      : super([uid]);
  @override
  String toString() {
    return uid;
  }

  Future<void> init(Dio client) async {
    var url = '/ticket/check/' + uid;
    var response = await client.get(url);
    var ticketInfo = response.data;
    if (ticketInfo['message'] == 'ticket has been checked successfully.' ||
        ticketInfo['message'] == 'ticket has already been used.') {
      ticketInfo = ticketInfo['data'];
      phoneNumber = ticketInfo['phone_number'];
      checkedDate = DateTime.parse(ticketInfo['used_date']);
      isChecked = ticketInfo['used'];
      isVaild = true;
    }
    if (ticketInfo['message'] != 'ticket has been checked succesfully') {
      player.play(0);
    } else {
      player.play(1);
    }
  }
}
