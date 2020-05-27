import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/providers/date_provider.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:como_gasto/src/pages/add_category_page.dart';
import 'package:como_gasto/src/pages/add_expense_page.dart';
import 'package:como_gasto/src/pages/details_page.dart';
import 'package:como_gasto/src/pages/home_page.dart';
import 'package:como_gasto/src/pages/login_page.dart';
import 'package:como_gasto/src/providers/login_state.dart';
import 'package:como_gasto/src/shared_prefs/preferencias_usuario.dart';

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
        ChangeNotifierProvider<LoginState>(create: (context) => LoginState()),
        ChangeNotifierProvider<DateProvider>(create: (context) => DateProvider()),
      ],
      child: MaterialApp(
        title: 'Como Gasto',
        initialRoute: Routes.homePage,
        routes: {
          Routes.homePage: (context) {
            var state = Provider.of<LoginState>(context);

            if (state.isLoggedIn)
              return HomePage();
            else
              return LoginPage();
          },
          Routes.addExpensePage: (context) => AddExpensePage(),
          Routes.addCategoryPage: (context) => AddCategoryPage(),
          Routes.detailsPage: (context) => DetailsPage(),
        },
      ),
    );
  }

}
