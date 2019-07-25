import 'package:flutter/material.dart';

import 'package:app/widgets/ticket_card.dart';
import 'package:app/blocs/info_bloc.dart';
import 'package:app/blocs/info_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("查票"),
        ),
        body: Column(
          children: <Widget>[
            BlocListener(
              bloc: BlocProvider.of<InfoBloc>(context),
              listener: (context, state) {
                if (state.error) {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("错误"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "密码/手机号",
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => controller.text = "",
                                )),
                          ),
                        ),
                        Expanded(
                          child: RaisedButton(
                            child: Text("查票"),
                            onPressed: () {
                              BlocProvider.of<InfoBloc>(context)
                                  .dispatch(Entered(query: controller.text));
                            },
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            Expanded(
                flex: 8,
                child: BlocListener(
                  listener: (context, state) {
                    if (!state.ticket.isValid) {
                      Scaffold.of(context).hideCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("请输入正确的信息"),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  bloc: BlocProvider.of<InfoBloc>(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: BlocBuilder(
                      bloc: BlocProvider.of<InfoBloc>(context),
                      builder: (context, state) {
                        if (state.ticket != null) {
                          return TicketCard(state.ticket);
                        }
                        return Center(child: Text("输入信息"));
                      },
                    ),
                  ),
                ))
          ],
        ));
  }
}
