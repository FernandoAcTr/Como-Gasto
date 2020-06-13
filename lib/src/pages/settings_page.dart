import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:como_gasto/src/providers/login_state_provider.dart';
import 'package:como_gasto/src/providers/theme_state_provider.dart';

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SettingsPage'),
      ),
      body: Consumer<ThemeStateProvider>(
        builder:
            (BuildContext context, ThemeStateProvider themeSate, Widget child) {
          return _body(themeSate, context);
        },
      ),
    );
  }

  Widget _body(ThemeStateProvider themeState, BuildContext context) {
    return Column(
      children: <Widget>[
        SwitchListTile(
          value: themeState.isDarkModeEnable,
          onChanged: (newValue) {
            themeState.darkMode = newValue;
          },
          title: Text('Dark Mode'),
        ),
        Expanded(child: Container()),
        Container(
          width: double.infinity,
          child: RaisedButton(
            child: Text('Log Out'),
            onPressed: () {
              themeState.darkMode = false;
              Provider.of<LoginStateProvider>(context, listen: false).logout();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
