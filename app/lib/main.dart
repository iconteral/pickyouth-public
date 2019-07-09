import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';

final loginBloc = LoginBloc();
final ticketBloc = TicketBloc(loginBloc);
void main() => runApp(BlocProviderTree(
      blocProviders: [
        BlocProvider<LoginBloc>(
          builder: (BuildContext context) => loginBloc,
        ),
        BlocProvider<TicketBloc>(
          builder: (BuildContext context) => ticketBloc,
        )
      ],
      child: MaterialApp(
        title: 'Pickyouth 检票系统',
        home: LoginPage(),
      ),
    ));

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
        appBar: AppBar(title: Text("Reply 2019 检票")),
        body: BlocListenerTree(
          child: Center(
            child: LoginForm(),
          ),
          blocListeners: <BlocListener>[
            BlocListener(
                bloc: loginBloc,
                listener: (BuildContext context, LoginState state) {
                  ScaffoldState scaffoldState = Scaffold.of(context);
                  if (state is LoginFailed) {
                    scaffoldState.hideCurrentSnackBar();
                    scaffoldState.showSnackBar(SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ));
                  }
                  if (state is LoggedIn) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ScanPage()));
                  }
                }),
            BlocListener(
              bloc: ticketBloc,
              listener: (BuildContext context, TicketState state) {
                ScaffoldState scaffoldState = Scaffold.of(context);
                if (state is InvalidTicketEvent) {
                  scaffoldState.hideCurrentSnackBar();
                  scaffoldState.showSnackBar(SnackBar(
                    content: Text("票信息错误，请重试"),
                  ));
                }
              },
            )
          ],
        ));
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<LoginFormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(hintText: "用户"),
              controller: usernameController,
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "密码"),
              obscureText: true,
              controller: passwordController,
            ),
            RaisedButton(
              onPressed: () {
                BlocProvider.of<LoginBloc>(context).dispatch(LoginPressedEvent(
                    usernameController.text, passwordController.text));
                // Navigator.push(context,
                // MaterialPageRoute(builder: (context) => ScanPage()));
              },
              child: Text("登录"),
            )
          ],
        ));
  }
}

class ScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TicketBloc _ticketBloc = BlocProvider.of<TicketBloc>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: QRScanner(),
          ),
          BlocBuilder<TicketEvent, TicketState>(
            bloc: _ticketBloc,
            builder: (BuildContext context, TicketState state) {
              // return Expanded(
              //   flex: 3,
              //   child: ListView.separated(
              //     padding: EdgeInsets.symmetric(vertical: 16.0),
              //     itemCount: state.ticketList.length + 1,
              //     separatorBuilder: (BuildContext context, int index) =>
              //         const Divider(),
              //     itemBuilder: (BuildContext context, int index) {
              //       return _buildTicket(context, index);
              //     },
              //   ),
              // );
              return Expanded(
                flex: 3,
                child: CarouselSlider(
                  enableInfiniteScroll: false,
                  items: state.ticketList.map((ticket) {
                    // return Builder(
                    // builder: (BuildContext context) {
                    return _buildTicketCard(context, ticket);
                    // },
                    // );
                  }).toList()
                    ..add(_buildAddTicketManually(context)),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildAddTicketManually(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[Icon(Icons.add_circle), Text("输入编号检票")],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('#' + ticket.uid,
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 3.0))
            ],
          )
        ],
      ),
    );
  }
}

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // var data = "";
  QRViewController controller;
  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final channel = controller.channel;
    controller.init(qrKey);
    this.controller = controller;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          dynamic arguments = call.arguments;
          BlocProvider.of<TicketBloc>(context)
              .dispatch(ScannedEvent(arguments.toString()));

          break;
        default:
      }
    });
  }
}

class LoginState {}

class LoginInitial extends LoginState {
  @override
  String toString() {
    return "Login init";
  }
}

class LoggedIn extends LoginState {
  final Client client;

  LoggedIn(this.client);
}

class LoginFailed extends LoginState {
  final String errorMessage;

  LoginFailed({this.errorMessage = "登录失败"});
}

class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginFailedEvent extends LoginEvent {
  final String errorMessage;

  LoginFailedEvent({this.errorMessage = "登录失败"}) : super([errorMessage]);
}

class LoginPressedEvent extends LoginEvent {
  final String username;
  final String password;

  LoginPressedEvent(this.username, this.password);
}

class LoggedInEvent extends LoginEvent {
  final Client client;

  LoggedInEvent(this.client);
}

class TicketState {
  final List<Ticket> _ticketList;
  List<Ticket> get ticketList => _ticketList;
  TicketState({ticketList = const <Ticket>[]}) : this._ticketList = ticketList;
  bool isDuplicated({String uid}) {
    return _ticketList.any((ticket) => ticket.toString() == uid);
  }
}

class TicketEvent extends Equatable {
  TicketEvent([List props = const []]) : super(props);
}

class AddTicketEvent extends TicketEvent {
  final Ticket ticket;
  AddTicketEvent(this.ticket) : super([ticket]);
}

class ScannedEvent extends TicketEvent {
  final String data;
  ScannedEvent(this.data) : super([data]);
}

class InvalidTicketEvent extends TicketEvent {}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginFailedEvent) {
      yield LoginFailed(errorMessage: event.errorMessage);
    }
    if (event is LoggedInEvent) {
      yield LoggedIn(event.client);
    }
    if (event is LoginPressedEvent) {
      Client client = Client();
      if (event.username == "" || event.password == "") {
        this.dispatch(LoginFailedEvent(errorMessage: "不能为空"));
      } else {
        var response = await client.post('http://39.105.70.152/login',
            body: {'username': event.username, 'password': event.password});
        if (response.body == 'wrong.') {
          this.dispatch(LoginFailedEvent(errorMessage: "信息错误"));
        } else {
          this.dispatch(LoggedInEvent(client));
        }
      }
    }
  }
}

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  @override
  TicketState get initialState => TicketState();
  StreamSubscription loginBlocSubscription;
  Client client;

  final LoginBloc loginClientBloc;
  TicketBloc(this.loginClientBloc) {
    loginBlocSubscription = loginClientBloc.state.listen((state) {
      if (state is LoggedIn) {
        client = (state as LoggedIn).client;
      }
    });
  }

  @override
  void dispose() {
    loginBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Stream<TicketState> mapEventToState(TicketEvent event) async* {
    if (event is AddTicketEvent) {
      List<Ticket> newList = List.from(currentState.ticketList)
        ..add(event.ticket);
      TicketState newState = TicketState(ticketList: newList);
      yield newState;
    }
    if (event is ScannedEvent) {
      if (event.data.length == 8 &&
          !currentState.isDuplicated(uid: event.data)) {
        Ticket ticket = Ticket(event.data);
        await ticket.init(this.client);
        if (ticket.isVaild) {
          this.dispatch(AddTicketEvent(ticket));
        } else {
          this.dispatch(InvalidTicketEvent());
        }
      }
    }
  }
}

class Ticket extends Equatable {
  String uid;
  String phoneNumber;
  bool isChecked;
  DateTime checkedDate;
  bool isVaild = false;
  Ticket(this.uid, {this.phoneNumber, this.isChecked, this.checkedDate})
      : super([uid, phoneNumber, isChecked, checkedDate]);
  @override
  String toString() {
    return uid;
  }

  Future<void> init(Client client) async {
    var url = 'http://39.105.70.152/ticket/check/' + uid;
    var response = await client.get(url);
    var ticketInfo = jsonDecode(response.body)['data'];
    if (ticketInfo['status'] == 'ok') {
      phoneNumber = ticketInfo['phone_number'];
      checkedDate = DateTime.parse(ticketInfo['used_date']);
      isChecked = ticketInfo['used'];
    } else {
      isVaild = false;
    }
  }
}
