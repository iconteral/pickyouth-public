import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:app/blocs/login_bolc.dart';
import 'package:app/blocs/ticket_bloc.dart';
import 'package:app/sound_player.dart';
import 'package:app/events/login_events.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/states/login_states.dart';
import 'package:app/ticket.dart';

final loginBloc = LoginBloc();
final ticketBloc = TicketBloc(loginBloc);

final player = SoundPlayer(
    ["assets/scanned.mp3", 'assets/checked.mp3', 'assets/wrong.mp3'])
  ..init();
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
      title: 'Reply 2019 检票系统',
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
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: LoginForm()),
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
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    initialPage: state.currentTicket,
                    enableInfiniteScroll: false,
                    onPageChanged: (page) {
                      ticketBloc.dispatch(TicketPageChanged(page));
                    },
                    items: state.ticketList.map((ticket) {
                      // return _buildTicketCard(context, ticket);
                      return Stack(
                        children: <Widget>[
                          Image.asset("assets/warning.png"),
                          _buildTicketCard(context, ticket)
                        ],
                      );
                    }).toList()
                    // ..add(_buildAddTicketManually(context)),
                    )
                  ..animateToPage(state.ticketList.length - 1),
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
