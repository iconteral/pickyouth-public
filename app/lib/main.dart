import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wakelock/wakelock.dart';

import 'package:app/blocs/login_bolc.dart';
import 'package:app/blocs/ticket_bloc.dart';
import 'package:app/blocs/torch_bloc.dart';
import 'package:app/events/login_events.dart';
import 'package:app/events/torch_events.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/states/login_states.dart';
import 'package:app/ticket.dart';

void main() async {
  timeago.setLocaleMessages("zh_CN", timeago.ZhCnMessages());
  final _loginBloc = LoginBloc();
  final _ticketBloc = TicketBloc(_loginBloc);
  final _torchBloc = TorchBloc();
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
                padding: EdgeInsets.symmetric(horizontal: 32.0),
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
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Stack(
              children: <Widget>[
                QRScanner(),
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        IconButton(
                          splashColor: Colors.blue,
                          color: Colors.blue,
                          icon: Icon(Icons.flash_on),
                          onPressed: () {
                            BlocProvider.of<TorchBloc>(context)
                                .dispatch(Toggle());
                          },
                        ),
                        Text(
                          "233",
                          style: TextStyle(color: Colors.blue),
                        ),
                        IconButton(
                          splashColor: Colors.blue,
                          color: Colors.blue,
                          icon: Icon(Icons.add_box),
                          onPressed: () {
                            _showAlert(context);
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          BlocBuilder<TicketEvent, TicketState>(
            bloc: _ticketBloc,
            builder: (BuildContext context, TicketState state) {
              var carouselSlider = CarouselSlider(
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  initialPage: state.currentTicket,
                  enableInfiniteScroll: false,
                  onPageChanged: (page) {
                    // _ticketBloc.dispatch(TicketPageChanged(page));
                  },
                  items: state.ticketList.map((ticket) {
                    final String background = ticket.justChecked
                        ? "assets/successful.png"
                        : "assets/warning.png";
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Stack(
                        children: <Widget>[
                          Image.asset(background),
                          _buildTicketCard(context, ticket)
                        ],
                      ),
                    );
                  }).toList());
              return Expanded(
                flex: 3,
                child: BlocListener(
                  bloc: BlocProvider.of<TicketBloc>(context),
                  listener: (context, state) {
                    carouselSlider.animateToPage(state.ticketList.length - 1,
                        duration: Duration(milliseconds: 10),
                        curve: Curves.easeInOut);
                  },
                  child: carouselSlider,
                ),
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
              keyboardType: TextInputType.number,
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
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('2333333',
                  // Text('#' + ticket.uid,
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 2.0)),
              Text("检票时间：" +
                  timeago.format(usedTime,
                      locale: 'zh_CN', clock: DateTime.now())),
              Text("手机号：" + ticket.phoneNumber)
            ],
          ),
          Column(
            children: <Widget>[
              Text(
                ticket.justChecked ? '成功检票' : '票已用过',
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 2.0),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
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
    return BlocListener(
      bloc: BlocProvider.of<TorchBloc>(context),
      listener: (context, state) {
        controller.flipFlash();
      },
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }

  void _onQRViewCreated(QRViewController controller) {
    Wakelock.enable();
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
