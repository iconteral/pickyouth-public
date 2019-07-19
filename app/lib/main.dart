import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:app/blocs/login_bolc.dart';
import 'package:app/blocs/ticket_bloc.dart';
import 'package:app/events/login_events.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/states/login_states.dart';
import 'package:app/ticket.dart';

void main() async {
  timeago.setLocaleMessages("zh_CN", timeago.ZhCnMessages());
  final _loginBloc = LoginBloc();
  final _ticketBloc = TicketBloc(_loginBloc);
  runApp(BlocProviderTree(
    blocProviders: [
      BlocProvider<LoginBloc>(
        builder: (BuildContext context) => _loginBloc,
      ),
      BlocProvider<TicketBloc>(
        builder: (BuildContext context) => _ticketBloc,
      )
    ],
    child: MaterialApp(
      title: 'Reply 2019 检票系统',
      home: LoginPage(),
    ),
  ));
}

class LoginPage extends StatelessWidget {
  void _loginListener(BuildContext context, LoginState state) {
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

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

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
                bloc: loginBloc,
                listener: (context, state) => _loginListener(context, state)),
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
            child: Stack(
              children: <Widget>[
                QRScanner(),
                Positioned(
                    bottom: 16.0,
                    right: 32.0,
                    child: IconButton(
                      icon: Icon(Icons.flash_on),
                      onPressed: () {},
                    )),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: IconButton(
                    icon: Icon(Icons.add_box),
                    onPressed: () {
                      _showAlert(context);
                    },
                  ),
                )
              ],
            ),
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
                      _ticketBloc.dispatch(TicketPageChanged(page));
                    },
                    items: state.ticketList.map((ticket) {
                      final String background = ticket.justChecked
                          ? "assets/successful.png"
                          : "assets/warning.png";
                      return Stack(
                        children: <Widget>[
                          Image.asset(background),
                          _buildTicketCard(context, ticket)
                        ],
                      );
                    }).toList()),
              );
            },
          )
        ],
      ),
    );
  }

  _showAlert(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("票号"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text("检"),
                onPressed: () {
                  if (controller.text.trim().length != 0) {
                    Navigator.of(context).pop();
                    BlocProvider.of<TicketBloc>(context)
                        .dispatch(AddTicketEvent(Ticket(controller.text)));
                  }
                },
              )
            ],
          );
        });
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
