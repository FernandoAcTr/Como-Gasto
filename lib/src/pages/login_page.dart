import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:como_gasto/src/providers/login_state_provider.dart';

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

  Widget _body(BuildContext context) {
    return Center(
      child: Consumer<LoginStateProvider>(
        builder: (BuildContext context, LoginStateProvider state, Widget child) {
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
            _loginButtons(),
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
        // Image.asset(
        //   'assets/img/initial-image.png',
        //   height: 250.0,
        //   width: double.infinity,
        // ),
        Container(
          height: 250.0,
          width: double.infinity,
          child: FlareActor(
            'assets/img/splash.flr',
            animation: 'idle',
          ),
        ),
        Text('Your personal finance app')
      ],
    );
  }

  Widget _loginButtons() {
    return Container(
      width: 220.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Color(0xff4285f4),
            child: Icon(FontAwesomeIcons.google),
            onPressed: () =>
                Provider.of<LoginStateProvider>(context, listen: false).login(LoginType.GOOGLE),
          ),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(0, 172, 238, 1),
            child: Icon(FontAwesomeIcons.twitter),
            onPressed: () =>
                Provider.of<LoginStateProvider>(context, listen: false).login(LoginType.TWITTER),
          ),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(59, 89, 152, 1),
            child: Icon(FontAwesomeIcons.facebook),
            onPressed: () =>
                Provider.of<LoginStateProvider>(context, listen: false).login(LoginType.FACEBOOK),
          ),
        ],
      ),
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
