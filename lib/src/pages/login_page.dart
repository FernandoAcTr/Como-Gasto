import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:como_gasto/src/providers/login_state.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TapGestureRecognizer _recognizer1;
  TapGestureRecognizer _recognizer2;

  @override
  void initState() {
    super.initState();

    _recognizer1 = TapGestureRecognizer()
      ..onTap = () {
        showHelp(
            "This service is provided AS IS and has no current warranty on how the"
            " data and uptime is managed. The final terms will be released when the final version of the app"
            " will be released.");
      };

    _recognizer2 = TapGestureRecognizer()
      ..onTap = () {
        showHelp(
            "All your data is saved anonymously on Firebase Firestore database and will be remain that way."
            " no other users will have access to it.");
      };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body(context)),
    );
  }

  void _login(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).login();
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Consumer<LoginState>(
        builder: (BuildContext context, LoginState state, Widget child) {
          if (state.isLoading) return CircularProgressIndicator();

          return child;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // Flex(direction: Axis.vertical),
            _whiteSpace(),
            _name(context),
            _whiteSpace(),
            _image(),
            _whiteSpace(),
            _loginButton(),
            _whiteSpace(),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _name(BuildContext context) {
    return Text(
      'Spend-o-meter',
      style: Theme.of(context).textTheme.display1,
    );
  }

  Widget _image() {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/img/initial-image.png',
          height: 250.0,
          width: double.infinity,
        ),
        Text('Your personal finance app')
      ],
    );
  }

  Widget _loginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text('Sing In with Google'),
          onPressed: () => _login(context),
        )
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.body1,
          text: 'To user this app you need to agree our ',
          children: [
            TextSpan(
              text: 'Terms of Service',
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.bold),
              recognizer: _recognizer1,
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.bold),
              recognizer: _recognizer2,
            ),
          ],
        ),
      ),
    );
  }

  Expanded _whiteSpace() {
    return Expanded(
      child: Container(),
      flex: 1,
    );
  }

  void showHelp(String s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(s),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
