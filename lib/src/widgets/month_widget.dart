import 'package:como_gasto/src/pages/details_page.dart';
import 'package:como_gasto/src/providers/date_provider.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db_repository.dart';
import 'package:como_gasto/src/widgets/graph_widget.dart';
import 'package:como_gasto/src/utils/icon_utils.dart' as iconUtils;

import '../firestore/db_repository.dart';
import '../models/expense.dart';

enum GraphType {
  LINES,
  PIE
}

class MonthWidget extends StatelessWidget {

  final List<Expense> expensesList;
  final double total;
  final List<double> perDay; 
  final Map<String, double> categories;
  final graphType; 
  final DBRepository db;

  MonthWidget({Key key, @required this.db, this.graphType, this.expensesList, days}) : 
    //se suma el value de todos los documentos
    total = expensesList.map((expense) => expense.value)
                     .fold(0.0, (a,b) => a+b),

    perDay = List.generate(days, (index){
      //se filtran todos los documentos que corespondan al dia 
      //del widget y se suman los valores del gasto
      return expensesList.where((expense) => expense.day == (index+1))
                      .map((expense) => expense.value)
                      .fold(0.0, (a,b) => a+b);
    }),

    categories = expensesList.fold({}, (Map<String, double> map, expense){
      //si en el mapa no existe la categoria, se crea su llave con valor de 0
      if(!map.containsKey(expense.category)){
        map[expense.category] = 0.0;
       }

      map[expense.category] += expense.value;
      return map;
    }),
    super(key: key);


  @override
  Widget build(BuildContext context) {
    // _getIcons();

    return Expanded(
      child: Column(
        children: <Widget>[
          _expenses(),
          _graph(),
          _divider(16.0),
          _list(context)
        ],
      ),
    );
  }

   Widget _expenses(){
     return Column(
       children: <Widget>[
        Text(
            '\$${total.toStringAsFixed(2)}', 
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold
            )
        ),
        Text(
            'Total Expenses', 
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey
            )
        ),
       ],
     );
   }

   Widget _graph(){

     if(graphType == GraphType.LINES){
        return Container(
          height: 220.0,
          child: LinesGraphWidget(data: perDay)
        );
     }
      else{
        var perCategory = categories.keys.map((name) => categories[name] / total).toList();
        return Container(
          height: 220.0,
          child: PieGraphWidget(data: perCategory)
        );  
      }    
   }

   Widget _list(BuildContext context){
      return Expanded(
        child: ListView.separated(            
          itemBuilder: (BuildContext context, int index) {
            var catName = categories.keys.elementAt(index);
            var catTotal = categories[catName];
            double percent = 100 * catTotal / total;

            return FutureBuilder<String>(
              future: db.getCategoryIcon(catName),
              builder: (context, AsyncSnapshot<String> snapshot){
                  if(snapshot.hasData){

                    if(snapshot.data != ''){
                      var iconName = snapshot.data;
                      return _listItem(iconUtils.categoryIcons[iconName], catName,catTotal,percent.toStringAsFixed(2), context);
                    }else
                      return _listItem(Icons.broken_image, catName,catTotal,percent.toStringAsFixed(2), context);
                  }
                  return _listItem(null, catName,catTotal,percent.toStringAsFixed(2), context);
              },
            );

          },
          separatorBuilder: (context, index) => _divider(3.0), 
          itemCount: categories.keys.length,          
        ),
      );
   }

   Widget _divider(double heigth){
     return Divider(
       color: Colors.blueAccent.withOpacity(0.1),
       thickness: heigth,
     );
   }

   ListTile _listItem(IconData icon, String name, double total, String percent, BuildContext context){
     return ListTile(       
       leading: icon == null ? CircularProgressIndicator() : Icon(icon, size: 35.0,),
       title: Text(name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
       ),
       subtitle: Text('$percent\% of expensesList',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.blueGrey,
          ),
       ),
       trailing: Container(
         child: Padding(
           child: Text('\$${total.toStringAsFixed(2)}', 
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
           ),
           padding: EdgeInsets.all(8.0),
          ),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(5.0),
           color: Colors.blueAccent.withOpacity(0.2),
         ),
       ),
       onTap: (){
         final dateProvider = Provider.of<DateProvider>(context, listen: false);
         Navigator.pushNamed(context, Routes.detailsPage, arguments: DetailsParams(dateProvider.month, dateProvider.year, name));
       },
     );
   }

}

