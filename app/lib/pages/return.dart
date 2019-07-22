import 'package:app/blocs/return_state.dart';
import 'package:flutter/material.dart';
import 'package:app/blocs/return_bloc.dart';
import 'package:app/blocs/return_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Size {
  int rows;
  int columns;
  Size(this.rows, this.columns);
}

class ReturnPage extends StatefulWidget {
  @override
  ReturnPageState createState() => ReturnPageState();
}

class ReturnPageState extends State {
  String currentSection = 'vip';
  int row = -1;
  int column = -1;
  final List<String> sections = ['vip', 'b', 'c', 'd', 'e', 'f'];
  Map<String, Size> sizes = {
    'vip': Size(6, 10),
    'b': Size(9, 10),
    'c': Size(11, 8),
    'd': Size(15, 8),
    'e': Size(4, 10),
    'f': Size(8, 8)
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("退座"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton(
                items: sections.map((section) {
                  return DropdownMenuItem<String>(
                      value: section, child: Text(section));
                }).toList(),
                onChanged: (section) {
                  setState(() {
                    currentSection = section.value;
                  });
                },
              ),
              Text("区"),
              DropdownButton(
                  onChanged: (item) {
                    setState(() {
                      row = item.value;
                    });
                  },
                  items: new List<int>.generate(
                      sizes[currentSection].rows, (i) => i + 1).map((i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text((i + 1).toString()),
                    );
                  }).toList()),
              Text("排"),
              DropdownButton(
                  onChanged: (item) {
                    setState(() {
                      column = item.value;
                    });
                  },
                  items: new List<int>.generate(
                      sizes[currentSection].columns, (i) => i + 1).map((i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text((i + 1).toString()),
                    );
                  }).toList()),
              Text("座")
            ],
          ),
          BlocListener(
            bloc: BlocProvider.of<ReturnBloc>(context),
            listener: (conetxt, state) {
              var scaffold = Scaffold.of(context);
              scaffold.hideCurrentSnackBar();
              if (state is FailedReturnState) {
                scaffold.showSnackBar(SnackBar(
                  content: Text("退座失败"),
                  backgroundColor: Colors.red,
                ));
              }
              if (state is SuccessfulReturnState) {
                scaffold.showSnackBar(SnackBar(
                  content: Text("退座成功"),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: RaisedButton(
              child: Text("退座"),
              onPressed: () {
                BlocProvider.of<ReturnBloc>(context).dispatch(ReturnTicketEvent(
                    section: currentSection, position: "${row}_$column"));
              },
            ),
          )
        ],
      ),
    );
  }
}
