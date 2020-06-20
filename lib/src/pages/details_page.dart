import 'package:como_gasto/src/pages/ui/day_expense_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db_repository.dart';

import '../models/expense.dart';

class DetailsParams {
  final month;
  final year;
  final category;

  DetailsParams(this.month, this.year, this.category);
}

class DetailsPageContainer extends StatefulWidget {
  final DetailsParams params;

  DetailsPageContainer(this.params);

  @override
  _DetailsPageContainerState createState() => _DetailsPageContainerState();
}

///ContainerViewPattern donde el widget que encapsula toda la logica (llamado Container)
///Contiene dentro al widget que representa la vista
class _DetailsPageContainerState extends State<DetailsPageContainer> {
  @override
  void initState() {
    super.initState();
    var db = Provider.of<DBRepository>(context, listen: false);
    var params = widget.params;
    db.getCategoryExpenses(params.category, params.year, params.month + 1);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
        stream: Provider.of<DBRepository>(context, listen: false)
            .categoryExpensesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return _DetailsPage(
            categoryName: widget.params.category,
            expensesList: snapshot.data,
            onDelete: (String documentId) {
              var db = Provider.of<DBRepository>(context, listen: false);
              db.deleteCategoryExpense(documentId);
            },
          );
        });
  }
}

class _DetailsPage extends StatelessWidget {
  final String categoryName;
  final List<Expense> expensesList;
  final Function(String) onDelete;

  const _DetailsPage(
      {Key key, this.categoryName, this.expensesList, this.onDelete})
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
          var expense = expensesList[index];
          return Dismissible(
            key: UniqueKey(),
            child: DayExpenseListTile(expense: expense),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              onDelete(expense.expenseID);
            },
          );
        },
        itemCount: expensesList.length,
      ),
    );
  }
}
