import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:como_gasto/como_gasto_icons.dart';
import 'package:como_gasto/src/providers/date_provider.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:como_gasto/src/utils/utils.dart';
import 'package:como_gasto/src/widgets/month_widget.dart';
import 'package:como_gasto/src/firestore/db.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PageController _controller;
  GraphType currentGraphType = GraphType.LINES;
  DateProvider dateProvider;

  //manejador de notificaciones
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() { 
    super.initState();
    setupNotificationPlugin();
  }

  @override
  Widget build(BuildContext context) {
    dateProvider = Provider.of<DateProvider>(context);

    return Consumer<DateProvider>(
      builder: (BuildContext context, DateProvider dateProvider, _) {
          _controller = PageController(
          initialPage: dateProvider.month,
          viewportFraction: 0.4,
        );

        return Scaffold(
          body: SafeArea(child: _body()),
          bottomNavigationBar: _bottomAppBar(),     
          floatingActionButton: _floattingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

   Widget _iconButton(IconData icon, Function callBack){
    return IconButton(
      icon: Icon(icon),
      onPressed: callBack,
    );
  }

  BottomAppBar _bottomAppBar(){
      return BottomAppBar(
          notchMargin: 8.0,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
                _iconButton(ComoGastoIcons.stats_bars, (){
                  setState(() {
                    currentGraphType = GraphType.LINES;
                  });
                }),
                _iconButton(ComoGastoIcons.pie_chart, (){
                  setState(() {
                    currentGraphType = GraphType.PIE;
                  });
                }),
                SizedBox(width: 48.0),
                _iconButton(ComoGastoIcons.cart, (){}),
                _iconButton(ComoGastoIcons.settings, (){
                    Navigator.of(context).pushNamed(Routes.settingsPage);
                }),
            ],
          ),
      );
  } 

  Widget _floattingActionButton(){
     return FloatingActionButton(
        heroTag: 'floating',
        onPressed: (){
          Navigator.of(context).pushNamed(Routes.addExpensePage);
        },
        child: Icon(ComoGastoIcons.plus)
      );
  }

  Widget _body(){
    var db = Provider.of<DBRepository>(context, listen: false);

    return Column(
      children: <Widget>[
        _yearSelector(),
        _monthSelector(),    
        StreamBuilder<QuerySnapshot>(
          stream: db.getExpenses(dateProvider.year, dateProvider.month+1),
          builder: (context, snapshot) {
            if(snapshot.hasData){
                if(snapshot.data.documents.length > 0){
                  var dateProvider = Provider.of<DateProvider>(context, listen: false);

                return MonthWidget(
                  days: daysInMonth(dateProvider.month +1),
                  graphType: currentGraphType,
                  documents: snapshot.data.documents
                );
              }else{
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset('assets/img/empty.png'),
                      Text('And an expense to begin')
                    ],
                  ),
                );
              }
            }
            else
              return CircularProgressIndicator();
          }
        ),    
      ],
    );
  }


  Widget _monthSelectorItem(String name, int position){
    var selected = TextStyle(
      fontSize: 20.0,
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.bold
    );

    var unselected = TextStyle(
      fontSize: 20.0,
      color: Colors.blueGrey.withOpacity(0.4),
      fontWeight: FontWeight.normal
    );

    var _alignment;

    if(position == dateProvider.month)
      _alignment = Alignment.center;
    else if(position > dateProvider.month)
      _alignment = Alignment.centerRight;
    else 
      _alignment = Alignment.centerLeft;

    return Align(
      child: Text(
        name,
        style: dateProvider.month == position ? selected : unselected,
      ),
      alignment: _alignment,  
    );
  }

  Widget _monthSelector(){
    return Container(
      height: 50.0,
      child: PageView(
        controller: _controller,
        onPageChanged: (position){

          dateProvider.month = position;
          print(dateProvider.month);
        },
        children: <Widget>[
          _monthSelectorItem('Enero',0),
          _monthSelectorItem('Febrero',1),
          _monthSelectorItem('Marzo',2),
          _monthSelectorItem('Abril',3),
          _monthSelectorItem('Mayo',4),
          _monthSelectorItem('Junio',5),
          _monthSelectorItem('Julio',6),
          _monthSelectorItem('Agosto',7),
          _monthSelectorItem('Septiembre',8),
          _monthSelectorItem('Octubre',9),
          _monthSelectorItem('Noviembre',10),
          _monthSelectorItem('Diciembre',11),
        ],
      ),
    );
   }

  _yearSelector() {
    final size = MediaQuery.of(context).size;

    return Container(
      height: 50.0,
      width: double.infinity,
      child: NumberPicker.integer(
              initialValue: dateProvider.year,
              minValue: 2020,
              maxValue: DateTime.now().year + 5,       
              scrollDirection: Axis.horizontal,    
              itemExtent: size.width/3, 
              onChanged: (newYear){
                dateProvider.year = newYear;
                print(dateProvider.year);
              }
            ),
    );
  }

  /// ----------------------------- Notifications Config --------------------
  ///
  ///------------------------------------------------------------------------

  void setupNotificationPlugin() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('notify_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification
       );

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, 
        initializationSettingsIOS
        );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification
    ).then((init){
      setupNotification();
    });
  }

  void setupNotification() async {
    var time = Time(21, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'daily-notification', //channel id
        'Daily Notifications', //chanel title
        'Daily Notifications');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

        //Metodo que dispara la notificacion
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Spend-o-meter',
        "Don't forget to add your expenses",
        time,
        platformChannelSpecifics);
  }

  Future selectNotification(String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("'Don't forget to add your expenses'"),
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


  