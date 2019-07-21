import 'package:app/widgets/ticket_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wakelock/wakelock.dart';

import 'package:app/blocs/torch_bloc.dart';
import 'package:app/blocs/ticket_bloc.dart';
import 'package:app/events/torch_events.dart';
import 'package:app/events/ticket_events.dart';
import 'package:app/states/ticket_states.dart';
import 'package:app/ticket.dart';

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
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: IconButton(
                          splashColor: Colors.blue,
                          color: Colors.blue,
                          icon: Icon(Icons.flash_on),
                          onPressed: () {
                            BlocProvider.of<TorchBloc>(context)
                                .dispatch(Toggle());
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          splashColor: Colors.blue,
                          color: Colors.blue,
                          icon: Icon(Icons.add_box),
                          onPressed: () {
                            _showAlert(context);
                          },
                        ),
                      )
                    ],
                  ),
                ),
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
                          TicketCard(ticket)
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
                        duration: Duration(milliseconds: 300),
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
                    BlocProvider.of<TicketBloc>(context).dispatch(
                        AddTicketEvent(
                            Ticket(uid: int.parse(controller.text))));
                  }
                },
              )
            ],
          );
        });
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
