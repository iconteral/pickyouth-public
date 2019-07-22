import 'package:app/ticket.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  TicketCard(this.ticket);
  final exp = new RegExp(r"([a-zA-Z]+)(\d+)_(\d+)");
  String _buildSeatString(String raw) {
    RegExpMatch m = exp.firstMatch(raw);
    return "${m.group(1).toUpperCase()}区${m.group(2)}排${m.group(3)}座";
  }

  @override
  Widget build(BuildContext context) {
    var usedDateWidget;
    if (ticket.isChecked) {
      DateTime usedTime = DateTime.parse(ticket.checkedDate.toString());

      usedDateWidget = Text("检票时间：" +
          timeago.format(usedTime, locale: 'zh_CN', clock: DateTime.now()));
    } else {
      usedDateWidget = Text("尚未使用");
    }
    List<Text> seatText = [];
    for (var i = 0; i < ticket.ticketNumber; i++) {
      if (i == 0) {
        seatText.add(Text(_buildSeatString(ticket.seat1)));
      } else {
        seatText.add(Text(_buildSeatString(ticket.seat2)));
      }
    }
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('#' + ticket.uid.toString(),
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 2.0)),
              usedDateWidget,
              ...seatText,
              Text("手机号：" + ticket.phoneNumber.toString())
            ],
          ),
          Column(
            children: <Widget>[
              Text(
                ticket.isChecked
                    ? ticket.justChecked ? '成功检票' : '票已用过'
                    : '尚未使用',
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 2.0),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          )
        ],
      ),
    );
  }
}
