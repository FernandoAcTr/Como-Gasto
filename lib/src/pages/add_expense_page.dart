import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import 'package:como_gasto/como_gasto_icons.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:como_gasto/src/firestore/db.dart';
import 'package:como_gasto/src/utils/icon_utils.dart';
import 'package:como_gasto/src/utils/utils.dart' as utils;
import 'package:como_gasto/src/widgets/category_selector_widget.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  //variables para el estado del expense
  String category = '';
  int value = 0;
  double realValue = 0;
  String dateStr = 'Hoy';
  DateTime date = DateTime.now();
  File _foto;

  //Stream del query
  Stream query;

  //local autentication
  LocalAuthentication _localAuth;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();

    //verificar si el telefono cuenta con sensores biometricos
    _localAuth = LocalAuthentication();
    _localAuth.canCheckBiometrics.then((b) {
      setState(() {
        _isBiometricAvailable = b;
      });
    });

    var db = Provider.of<DBRepository>(context, listen: false);
    query = db.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.grey,
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        title: Text(
          'Category ($dateStr)',
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(ComoGastoIcons.calendar),
            color: Colors.grey,
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 7)),
                lastDate: DateTime.now(),
              ).then((newValue) {
                setState(() {
                  date = newValue;
                  String mes =
                      date.month < 9 ? '0${date.month}' : date.month.toString();
                  String dia =
                      date.day < 9 ? '0${date.day}' : date.day.toString();
                  dateStr = '${date.year}/$mes/$dia';
                });
              });
            },
          ),
          IconButton(
            icon: Icon(ComoGastoIcons.camera),
            color: Colors.grey,
            onPressed: () => _procesarImagen(ImageSource.camera),
          ),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    return Column(
      children: <Widget>[
        _categorySelector(),
        _expenseImage(),
        _currentValue(),
        _numPad(),
        _submit()
      ],
    );
  }

  Widget _categorySelector() {

    return Container(
      height: 80.0,
      child: StreamBuilder<QuerySnapshot>(
          stream: query,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            final documents = snapshot.data.documents;
            Map<String, IconData> categories = {};

            documents.forEach((doc) {
              categories.addAll({doc['name']: materialIconList[doc['icon']]});
            });

            categories.addAll({'Add Category': Icons.add});

            return CategorySelectorWidget(
              categories: categories,
              onValueChanged: (newCategory) {
                if (newCategory == 'Add Category')
                  Navigator.of(context).pushNamed(Routes.addCategoryPage);
                else
                  category = newCategory;
              },
            );
          }),
    );
  }

  Widget _expenseImage() {
    if (_foto != null) {
      return Container(
        height: 120.0,
        width: double.infinity,
        padding: EdgeInsets.only(top: 10.0),
        child: Image.file(_foto),
      );
    } else {
      return Container();
    }
  }

  Widget _currentValue() {
    return Container(
      height: 100.0,
      child: Center(
        child: Text(
          '\$${realValue.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 50.0,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _numPad() {
    return Expanded(child: LayoutBuilder(builder: (context, constraints) {
      var heigth = constraints.biggest.height / 4;
      return Table(
        border: TableBorder.all(color: Colors.grey),
        children: [
          TableRow(children: [
            _num('1', heigth),
            _num('2', heigth),
            _num('3', heigth),
          ]),
          TableRow(children: [
            _num('4', heigth),
            _num('5', heigth),
            _num('6', heigth),
          ]),
          TableRow(children: [
            _num('7', heigth),
            _num('8', heigth),
            _num('9', heigth),
          ]),
          TableRow(children: [
            _num(',', heigth),
            _num('0', heigth),
            _backspace(heigth),
          ]),
        ],
      );
    }));
  }

  Widget _num(String numeric, double heigth) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          if (numeric == ',') {
            value *= 100;
          } else {
            value = value * 10 + int.parse(numeric);
          }
          realValue = value / 100;
        });
      },
      child: Container(
          height: heigth,
          child: Center(
              child: Text(
            numeric,
            style: TextStyle(fontSize: 40.0, color: Colors.blueGrey),
          ))),
    );
  }

  Widget _backspace(double heigth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          value = value ~/ 10;
          realValue = value / 100;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
          height: heigth,
          child: Center(
            child: Icon(Icons.backspace, size: 30.0, color: Colors.blueGrey),
          )),
    );
  }

  Widget _submit() {
    return Hero(
      tag: 'floating',
      child: Container(
        width: double.infinity,
        height: 50.0,
        child: MaterialButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Add Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              if (_isBiometricAvailable)
                Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 40.0,
                )
            ],
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () => _addExpenseAction(),
        ),
      ),
    );
  }

  void _procesarImagen(ImageSource source) async {
    var picker = ImagePicker();

    final picketFile = await picker.getImage(source: source);
    if (picketFile != null) {
      _foto = new File(picketFile.path);
    }

    setState(() {});
  }

  ///Metodo que agrega la expense y la sube a la base de datos
  void _addExpenseAction() async {
    var db = Provider.of<DBRepository>(context, listen: false);

    if (realValue > 0 && category != '') {
      if (_isBiometricAvailable) {
        if (await authenticate())
          _saveAndBack(db);
        else
          utils.mostrarSnackbar(scaffoldKey, 'Please identify by yourself');
      } else
        _saveAndBack(db);
    } else
      utils.mostrarSnackbar(scaffoldKey, 'Select a value and a category');
  }

  void _saveAndBack(DBRepository db) {
    db.addExpense(category, realValue, date, _foto);
    Navigator.of(context).pop();
  }

  ///Autentifica al usuario de forma local por huella digital
  Future<bool> authenticate() async {
    bool didAuthenticate = await _localAuth.authenticateWithBiometrics(
      localizedReason: 'Please identify yoursel ',
    );
    return didAuthenticate;
  }
}
