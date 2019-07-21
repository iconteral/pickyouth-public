import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app/states/login_states.dart';
import 'package:app/events/login_events.dart';
import 'package:app/blocs/login_bolc.dart';

import 'package:app/pages/lobby.dart';

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => Lobby()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
        appBar: AppBar(title: Text("Reply 9102 检票")),
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
