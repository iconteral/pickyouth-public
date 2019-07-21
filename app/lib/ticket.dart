import 'package:app/sound_player.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

final player = SoundPlayer(['assets/wrong.mp3', 'assets/checked.mp3']);

class Ticket extends Equatable {
  int uid = 0;
  int phoneNumber = 0;
  bool isChecked;
  DateTime checkedDate;
  String seat1;
  String seat2;
  bool isVaild = false;
  bool justChecked = false;
  int ticketNumber;
  Ticket({
    this.uid,
    this.phoneNumber,
    this.isChecked,
    this.checkedDate,
    this.seat1,
    this.seat2,
  }) : super([uid]);
  @override
  String toString() {
    return uid.toString();
  }

  Future<void> init(Dio client, {bool check = true}) async {
    String lookup = (uid == null ? phoneNumber : uid).toString();
    var url;
    if (check) {
      url = '/ticket/check/$lookup';
    } else {
      url = '/ticket/$lookup';
    }
    var response = await client.get(url);
    var ticketInfo = response.data;
    String message = ticketInfo['message'];
    if (message == 'ticket has been checked successfully.' ||
        message == 'ticket has already been used.' ||
        message == 'ok') {
      ticketInfo = ticketInfo['data'];
      uid = ticketInfo['password'];
      phoneNumber = ticketInfo['phone_number'];
      ticketNumber = ticketInfo['number'];
      seat1 = ticketInfo['seat1'];
      seat2 = ticketInfo['seat2'];
      isChecked = ticketInfo['used'] == 1;
      if (isChecked) {
        checkedDate = DateTime.parse(ticketInfo['used_date']);
      }
      isVaild = true;
    }
    if (message == 'ticket has been checked successfully.') {
      justChecked = true;
    }
  }
}
