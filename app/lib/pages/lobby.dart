import 'package:app/pages/info.dart';
import 'package:app/pages/seat.dart';
import 'package:flutter/material.dart';

import 'package:app/pages/check.dart';

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reply 9102"),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildButton(context, Icons.scanner, "检票", ScanPage()),
                _buildButton(context, Icons.backspace, "退票", null),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildButton(context, Icons.event_seat, "座位状态", SeatPage()),
                _buildButton(context, Icons.info, "查票", InfoPage()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, IconData icon, String text, Widget navigateTo) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => navigateTo));
      },
      child: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 60.0,
            ),
            Text(text)
          ],
        ),
      ),
    );
  }
}
