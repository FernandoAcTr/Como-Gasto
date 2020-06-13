import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db.dart';
import 'package:como_gasto/src/providers/date_provider.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:como_gasto/src/pages/add_category_page.dart';
import 'package:como_gasto/src/pages/add_expense_page.dart';
import 'package:como_gasto/src/pages/details_page.dart';
import 'package:como_gasto/src/pages/home_page.dart';
import 'package:como_gasto/src/pages/login_page.dart';
import 'package:como_gasto/src/providers/login_state_provider.dart';
import 'package:como_gasto/src/shared_prefs/preferencias_usuario.dart';
import 'package:como_gasto/src/pages/settings_page.dart';
import 'package:como_gasto/src/providers/theme_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DateProvider>(
            create: (context) => DateProvider()),
        ChangeNotifierProvider<LoginStateProvider>(
            create: (context) => LoginStateProvider()),
        //sirve para crear un provider a parir del valor de otro
        ProxyProvider<LoginStateProvider, DBRepository>(
          update: (_, LoginStateProvider login, __) =>
              DBRepository(login.currentUser.uid),
        ),
        ChangeNotifierProvider<ThemeStateProvider>(
          create: (context) => ThemeStateProvider(),
        ),
      ],
      child: Consumer<ThemeStateProvider>(
        builder:
            (BuildContext context, ThemeStateProvider themeState, Widget child) {
          return MaterialApp(
            title: 'Como Gasto',
            initialRoute: Routes.homePage,
            theme: themeState.currentTheme,
            routes: {
              Routes.homePage: (context) {
                var state = Provider.of<LoginStateProvider>(context);

                if (state.isLoggedIn)
                  return HomePage();
                else
                  return LoginPage();
              },
              Routes.addExpensePage: (context) => AddExpensePage(),
              Routes.addCategoryPage: (context) => AddCategoryPage(),
              Routes.detailsPage: (context) => DetailsPageContainer(),
              Routes.settingsPage: (context) => SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
