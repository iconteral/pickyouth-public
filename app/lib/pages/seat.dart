import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/blocs/seat_bloc.dart';
import 'package:app/blocs/seat_event.dart';
import 'package:app/blocs/seat_state.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SeatPage extends StatelessWidget {
  WebViewController controller;
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<SeatBloc>(context).dispatch(LoadEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text("座位状态"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            BlocProvider.of<SeatBloc>(context).dispatch(LoadEvent()),
        child: Icon(Icons.refresh),
      ),
      body: BlocBuilder(
        bloc: BlocProvider.of<SeatBloc>(context),
        builder: (context, state) {
          return Column(children: <Widget>[
            Expanded(
              flex: 1,
              child: _buildSeatView(context, state),
            ),
            Expanded(
              flex: 9,
              child: _buildWebView(context, state.currespondingUrl),
            )
          ]);
        },
      ),
    );
  }

  Widget _buildWebView(BuildContext context, String url) {
    return BlocListener(
      bloc: BlocProvider.of<SeatBloc>(context),
      listener: (context, state) {
        controller?.loadUrl((state as Loaded).currespondingUrl +
            "?pass=5d5c86660eeb4235344c00ef67d6514e");
      },
      child: WebView(
        initialUrl: url + "?pass=5d5c86660eeb4235344c00ef67d6514e",
        onWebViewCreated: (WebViewController c) => controller = c,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  Widget _buildSeatView(BuildContext context, Loaded state) {
    List<String> sections = ["vip", "B", "C", "D", "E", "F"];
    Map<String, int> total = {
      "vip": 50,
      'B': 80,
      'C': 88,
      'D': 15 * 8,
      'E': 80,
      'F': 49
    };
    var columns = sections.map((section) {
      return Expanded(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text(section),
              onPressed: () => BlocProvider.of<SeatBloc>(context)
                  .dispatch(SwitchSectionEvent(section)),
            ),
            Text((total[section] - state.count[section.toLowerCase()])
                .toString())
          ],
        ),
      );
    });
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: columns.toList(),
    );
  }
}
