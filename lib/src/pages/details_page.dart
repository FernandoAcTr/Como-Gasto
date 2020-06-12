import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:como_gasto/src/pages/ui/day_expense_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db.dart';

class DetailsParams {
  final month;
  final year;
  final category;

  DetailsParams(this.month, this.year, this.category);
}

class DetailsPageContainer extends StatefulWidget {
  @override
  _DetailsPageContainerState createState() => _DetailsPageContainerState();
}

///ContainerViewPattern donde el widget que encapsula toda la logica (llamado Container)
///Contiene dentro al widget que representa la vista
class _DetailsPageContainerState extends State<DetailsPageContainer> {
  DetailsParams params;

  @override
  Widget build(BuildContext context) {
    params = ModalRoute.of(context).settings.arguments;
    var db = Provider.of<DBRepository>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
        stream: db.getCategoryExpenses(params.category, params.year, params.month + 1),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return _DetailsPage(
            categoryName: params.category,
            documentList: snapshot.data.documents,
            onDelete: (String documentId){
              db.deleteCategoryExpense(documentId);
            },
          );
        });
  }
}

class _DetailsPage extends StatelessWidget {
  final String categoryName;
  final List<DocumentSnapshot> documentList;
  final Function(String) onDelete;

  const _DetailsPage({Key key, this.categoryName, this.documentList, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var document = documentList[index];
          return Dismissible(
            key: UniqueKey(),
            child: DayExpenseListTile(document: document),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              onDelete(document.documentID);
            },
          );
        },
        itemCount: documentList.length,
      ),
    );
  }
}
