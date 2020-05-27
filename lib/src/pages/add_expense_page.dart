import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/providers/login_state.dart';
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
  String category = '';
  int value = 0;
  double realValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          title: Text('Category', 
            style: TextStyle(
              color: Colors.grey
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.grey,
            )
          ],
        ),
        body: _body(),         
    );
  }

  _body(){
    return Column(
      children: <Widget>[
        _categorySelector(),
        _currentValue(),
        _numPad(),
        _submit()
      ],
    );
  }

  Widget _categorySelector(){
    var db = Provider.of<DBRepository>(context, listen: false);

    return Container(
      height: 80.0,
      child: StreamBuilder<QuerySnapshot>(
        stream: db.getCategories(),
        builder: (context, snapshot) {
          if(!snapshot.hasData)
            return CircularProgressIndicator();

          final documents = snapshot.data.documents;
          Map<String, IconData> categories = {};

          documents.forEach((doc){
            categories.addAll({
              doc['name'] : iconList[doc['icon']]
            });
          });

          categories.addAll({
              'Add Category' : Icons.add
            });
          
          return CategorySelectorWidget(
            categories: categories,
            onValueChanged: (newCategory) {
              if(newCategory == 'Add Category')
                Navigator.of(context).pushNamed(Routes.addCategoryPage);
              else
                category = newCategory;
            },
          );
        }
      ),
    );
  }

  Widget _currentValue(){

    return Container(
      height: 120.0,
      child: Center(
        child: Text('\$${realValue.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 50.0,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _numPad(){
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var heigth = constraints.biggest.height / 4;
          return Table(
            border: TableBorder.all(color: Colors.grey),
            children: [
              TableRow(
                children: [
                  _num('1', heigth),
                  _num('2', heigth),
                  _num('3', heigth),
                ]
              ),
              TableRow(
                children: [
                  _num('4', heigth),
                  _num('5', heigth),
                  _num('6', heigth),
                ]
              ),
              TableRow(
                children: [
                  _num('7', heigth),
                  _num('8', heigth),
                  _num('9', heigth),
                ]
              ),
              TableRow(
                children: [
                  _num(',', heigth),
                  _num('0', heigth),
                  _backspace(heigth),
                ]
              ),
            ],
          );
        }
      )
    );
  }

  Widget _num(String numeric, double heigth){ 
                     
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        setState(() {
           if(numeric == ','){
             value *= 100;
          }else{
             value = value*10 + int.parse(numeric);
          }
            realValue = value / 100;
        });       
      },
      child: Container(
        height: heigth, 
        child: Center(
          child: Text(numeric,
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.blueGrey
            ),
          )
        )
      ),
    );    
  }

  Widget _backspace(double heigth){                  
    return GestureDetector(
      onTap: (){
        setState(() {
           value = value ~/ 10;
           realValue = value / 100;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: heigth, 
        child: Center(
          child: Icon(
            Icons.backspace, 
            size: 30.0,
            color: Colors.blueGrey
          ),
        )
      ),
    );    
  }

  Widget _submit(){
    var db = Provider.of<DBRepository>(context, listen: false);

    return Hero(
      tag: 'floating',
      child: Container(
        width: double.infinity,
        height: 50.0,
        child: MaterialButton(
          child: Text('Submit'),
          color: Colors.blueAccent,
          onPressed: (){
            if(realValue > 0 && category != ''){
              var user = Provider.of<LoginState>(context, listen: false).currentUser;
              db.addExpense(category, realValue);
              Navigator.of(context).pop();
            }else
              utils.mostrarSnackbar(scaffoldKey, 'Slect a value and a category');
          },
        ),
      ),
    );
  }
}