import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:como_gasto/src/pages/ui/DayExpenseListTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db.dart';

class DetailsParams {
  final month;
  final year;
  final category;

  DetailsParams(this.month, this.year, this.category);
}

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  DetailsParams params;

  @override
  Widget build(BuildContext context) {
    params = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(params.category),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    var db = Provider.of<DBRepository>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
        stream: db.getCategoryExpenses(params.category, params.year, params.month + 1),
        builder: (context, snapshot) {

          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());


          var widgets = snapshot.data.documents.map((document) {
            
            return Dismissible(
                  key: UniqueKey(),
                  child: DayExpenseListTile(document: document),
                  background: Container(color: Colors.red),
                  onDismissed: (direction){
                    db.deleteCategoryExpense(document.documentID);
                  },
              );

          }).toList();

          return ListView(
            children: widgets,       
          );
        });
  }

}

