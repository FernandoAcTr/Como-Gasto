import 'package:como_gasto/src/pages/details_page.dart';
import 'package:como_gasto/src/providers/date_provider.dart';
import 'package:como_gasto/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:como_gasto/src/firestore/db.dart';
import 'package:como_gasto/src/widgets/graph_widget.dart';
import 'package:como_gasto/src/utils/icon_utils.dart' as iconUtils;

enum GraphType {
  LINES,
  PIE
}

class MonthWidget extends StatefulWidget {

  final List<DocumentSnapshot> documents;
  final double total;
  final List<double> perDay; 
  final Map<String, double> categories;
  final graphType; 

  MonthWidget({Key key, this.graphType, this.documents, days}) : 
    //se suma el value de todos los documentos
    total = documents.map((doc) => doc['value'])
                     .fold(0.0, (a,b) => a+b),

    perDay = List.generate(days, (index){
      //se filtran todos los documentos que corespondan al dia 
      //del widget y se suman los valores del gasto
      return documents.where((doc) => doc['day'] == (index+1))
                      .map((doc) => doc['value'])
                      .fold(0.0, (a,b) => a+b);
    }),

    categories = documents.fold({}, (Map<String, double> map, document){
      //si en el mapa no existe la categoria, se crea su llave con valor de 0
      if(!map.containsKey(document['category'])){
        map[document['category']] = 0.0;
       }

      map[document['category']] += document['value'];
      return map;
    }),
    super(key: key);

  @override
  _MonthWidgetState createState() => _MonthWidgetState();
}

class _MonthWidgetState extends State<MonthWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.categories);
    return Expanded(
      child: Column(
        children: <Widget>[
          _expenses(),
          _graph(),
          _divider(16.0),
          _list()
        ],
      ),
    );
  } 

   Widget _expenses(){
     return Column(
       children: <Widget>[
        Text(
            '\$${widget.total.toStringAsFixed(2)}', 
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

     if(widget.graphType == GraphType.LINES){
        return Container(
          height: 220.0,
          child: LinesGraphWidget(data: widget.perDay)
        );
     }
      else{
        var perCategory = widget.categories.keys.map((name) => widget.categories[name] / widget.total).toList();
        return Container(
          height: 220.0,
          child: PieGraphWidget(data: perCategory)
        );  
      }    
   }

   Widget _list(){
     var db = Provider.of<DBRepository>(context, listen: false);

      return Expanded(
        child: ListView.separated(            
          itemBuilder: (BuildContext context, int index) {
            var catName = widget.categories.keys.elementAt(index);
            var catTotal = widget.categories[catName];
            double percent = 100 * catTotal / widget.total;

            return FutureBuilder(
              future: db.getCategoryIcon(catName),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasData){

                    if(snapshot.data.documents.length > 0){
                      var iconName = snapshot.data.documents.first['icon'];
                      return _listItem(iconUtils.iconList[iconName], catName,catTotal,percent.toStringAsFixed(2));
                    }else
                      return _listItem(Icons.broken_image, catName,catTotal,percent.toStringAsFixed(2));
                  }
                  return _listItem(null, catName,catTotal,percent.toStringAsFixed(2));
              },
            );

          },
          separatorBuilder: (context, index) => _divider(3.0), 
          itemCount: widget.categories.keys.length,          
        ),
      );
   }

   Widget _divider(double heigth){
     return Divider(
       color: Colors.blueAccent.withOpacity(0.1),
       thickness: heigth,
     );
   }

   ListTile _listItem(IconData icon, String name, double total, String percent){
     return ListTile(       
       leading: icon == null ? CircularProgressIndicator() : Icon(icon, size: 35.0,),
       title: Text(name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
       ),
       subtitle: Text('$percent\% of expenses',
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