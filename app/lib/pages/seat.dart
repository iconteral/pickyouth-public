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
        controller?.loadUrl(state.currespondingUrl);
      },
      child: WebView(
        initialUrl: url,
        onWebViewCreated: (WebViewController c) => controller = c,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  Widget _buildSeatView(BuildContext context, Loaded state) {
    List<String> sections = ["vip", "B", "C", "D", "E", "F"];
    var columns = sections.map((section) {
      return Expanded(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text(section),
              onPressed: () => BlocProvider.of<SeatBloc>(context)
                  .dispatch(SwitchSectionEvent(section)),
            ),
            Text(state.count[section.toLowerCase()].toString())
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
