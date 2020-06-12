import 'package:como_gasto/src/providers/theme_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          return _body(themeSate);
        },
      ),
    );
  }

  Widget _body(ThemeStateProvider themeState) {
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
