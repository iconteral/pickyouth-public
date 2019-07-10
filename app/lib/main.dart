import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

// _parseAndDecode(String response) {
// return jsonDecode(response);
// }

// parseJson(String text) {
// return compute(_parseAndDecode, text);
// }

final loginBloc = LoginBloc();
final ticketBloc = TicketBloc(loginBloc);
void main() async {
  timeago.setLocaleMessages("zh_CN", timeago.ZhCnMessages());
  runApp(BlocProviderTree(
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
}

class LoginPage extends StatelessWidget {
  _loginListener(BuildContext context, LoginState state) {
    ScaffoldState scaffoldState = Scaffold.of(context);
    if (state is LoginFailed) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(SnackBar(
        content: Text(state.errorMessage),
        backgroundColor: Colors.red,
      ));
    }
    if (state is LoggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ScanPage()));
    }
  }

  _ticketListener(BuildContext context, TicketState state) {
    ScaffoldState scaffoldState = Scaffold.of(context);
    if (state is InvalidTicketEvent) {
      scaffoldState.hideCurrentSnackBar();
      scaffoldState.showSnackBar(SnackBar(
        content: Text("票信息错误，请重试"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc2 = BlocProvider.of<LoginBloc>(context);
    final ticketBloc2 = BlocProvider.of<TicketBloc>(context);

    return Scaffold(
        appBar: AppBar(title: Text("Reply 2019 检票")),
        body: BlocListenerTree(
          child: Center(
            child: LoginForm(),
          ),
          blocListeners: <BlocListener>[
            BlocListener(
                bloc: loginBloc2,
                listener: (context, state) => _loginListener(context, state)),
            BlocListener(
              bloc: ticketBloc2,
              listener: (context, state) => _ticketListener(context, state),
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
              return Expanded(
                flex: 3,
                child: CarouselSlider(
                  initialPage: state.ticketList.length,
                  enableInfiniteScroll: false,
                  items: state.ticketList.map((ticket) {
                    return _buildTicketCard(context, ticket);
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
    DateTime usedTime =
        DateTime.parse(ticket.checkedDate.add(Duration(hours: 8)).toString());
    print(usedTime);
    print(DateTime.now());
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('#' + ticket.uid,
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 0.7)),
              Text("检票时间：" +
                  timeago.format(usedTime,
                      locale: 'zh_CN', clock: DateTime.now())),
              Text("手机号：" + ticket.phoneNumber)
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
  final Dio client;

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
  final Dio client;

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
      BaseOptions options = BaseOptions(baseUrl: "http://39.105.70.152:8080");
      Dio client = new Dio(options);
      var dataPath = await getApplicationDocumentsDirectory();
      var cookieJar = PersistCookieJar(dir: dataPath.path);
      client.interceptors.add(CookieManager(cookieJar));
      if (event.username == "" || event.password == "") {
        this.dispatch(LoginFailedEvent(errorMessage: "不能为空"));
      } else {
        var postData = {"username": event.username, "password": event.password};
        FormData formData = FormData.from(postData);
        print(postData);
        Response response = await client.post("/login", data: formData);
        if (response.data.toString() == 'wrong.') {
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
  Dio client;

  final LoginBloc loginClientBloc;
  TicketBloc(this.loginClientBloc) {
    loginBlocSubscription = loginClientBloc.state.listen((state) {
      if (state is LoggedIn) {
        client = state.client;
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
      List<Ticket> newList = List.from(currentState.ticketList);
      int ticketIndex = newList.indexOf(event.ticket);
      if (ticketIndex == -1) {
        newList.add(event.ticket);
      } else {
        newList.add(newList.removeAt(ticketIndex));
      }
      TicketState newState = TicketState(ticketList: newList);
      yield newState;
    }
    if (event is ScannedEvent) {
      Ticket ticket = Ticket(event.data);
      if (!currentState.isDuplicated(uid: event.data)) {
        await ticket.init(this.client);
        if (ticket.isVaild) {
          this.dispatch(AddTicketEvent(ticket));
        } else {
          this.dispatch(InvalidTicketEvent());
        }
      } else {
        this.dispatch(AddTicketEvent(ticket));
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
      : super([uid]);
  @override
  String toString() {
    return uid;
  }

  Future<void> init(Dio client) async {
    var url = '/ticket/check/' + uid;
    var response = await client.get(url);
    var ticketInfo = response.data;
    if (ticketInfo['message'] == 'ticket has been checked successfully.' ||
        ticketInfo['message'] == 'ticket has already been used.') {
      ticketInfo = ticketInfo['data'];
      phoneNumber = ticketInfo['phone_number'];
      checkedDate = DateTime.parse(ticketInfo['used_date']);
      isChecked = ticketInfo['used'];
      isVaild = true;
    }
  }
}
