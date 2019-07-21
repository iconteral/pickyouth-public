import 'package:flutter/material.dart';

import 'package:app/widgets/ticket_card.dart';
import 'package:app/blocs/info_bloc.dart';
import 'package:app/blocs/info_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoPage extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("查票"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "密码",
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () =>
                                        passwordController.text = "",
                                  )),
                            ),
                          ),
                          RaisedButton(
                            child: Text("查票"),
                            onPressed: () {
                              BlocProvider.of<InfoBloc>(context).dispatch(
                                  PasswordEntered(
                                      password: passwordController.text));
                            },
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "手机号",
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () => phoneController.text = "",
                                  )),
                            ),
                          ),
                          RaisedButton(
                            child: Text("查票"),
                            onPressed: () {
                              BlocProvider.of<InfoBloc>(context).dispatch(
                                  PhoneEntered(
                                      phoneNumber: phoneController.text));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )),
            Expanded(
                flex: 7,
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
