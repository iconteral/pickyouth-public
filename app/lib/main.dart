import 'package:app/blocs/info_bloc.dart';
import 'package:app/blocs/seat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:app/blocs/login_bolc.dart';
import 'package:app/blocs/ticket_bloc.dart';
import 'package:app/blocs/torch_bloc.dart';

import 'package:app/pages/login.dart';

void main() async {
  timeago.setLocaleMessages("zh_CN", timeago.ZhCnMessages());
  final _loginBloc = LoginBloc();
  final _ticketBloc = TicketBloc(_loginBloc);
  final _torchBloc = TorchBloc();
  final _infoBloc = InfoBloc(_loginBloc);
  final _seatBloc = SeatBloc(_loginBloc);
  runApp(BlocProviderTree(
    blocProviders: [
      BlocProvider<LoginBloc>(
        builder: (BuildContext context) => _loginBloc,
      ),
      BlocProvider<TicketBloc>(
        builder: (BuildContext context) => _ticketBloc,
      ),
      BlocProvider<TorchBloc>(
        builder: (BuildContext context) => _torchBloc,
      ),
      BlocProvider<InfoBloc>(
        builder: (BuildContext context) => _infoBloc,
      ),
      BlocProvider<SeatBloc>(
        builder: (BuildContext context) => _seatBloc,
      )
    ],
    child: MaterialApp(
      title: 'Reply 9102 检票系统',
      home: LoginPage(),
    ),
  ));
}
