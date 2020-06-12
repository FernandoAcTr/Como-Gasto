
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';

import 'package:como_gasto/src/firestore/db.dart';

///Crea una barra de categorias para la pagina de AddExpensePage 
class CategorySelectorWidget extends StatefulWidget {
  
  final Map<String, IconData> categories;
  final Function(String) onValueChanged;

  const CategorySelectorWidget({Key key, this.categories, this.onValueChanged}) : super(key: key);

  @override
  _CategorySelectorWidgetState createState() => _CategorySelectorWidgetState();

}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  String currenItem = '';

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];

    widget.categories.forEach((name, icon){

      //asignar un key unico al rect del widget que se va a medir
       var globalKey = RectGetter.createGlobalKey();

        widgets.add(  

          GestureDetector(
            onTap: () {
              if(name != 'Add Category')
                setState(() {
                    currenItem = name;
                });
              widget.onValueChanged(name);
            },
            onLongPress: () async {
              if(name != 'Add Category'){
                  //obtenemos un rect para posicionar el menu
                  var rect = RectGetter.getRectFromKey(globalKey);                  
                  bool s = await showMenu<bool>(
                      context: context,
                      items: [
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: true,                        
                          )
                      ], 
                      position: RelativeRect.fromLTRB(
                        rect.left, 
                        rect.top + 50, 
                        rect.right, 
                        rect.bottom
                      )
                  );

                if(s != null && s){
                  deleteCategory(name);
                }
              }              
                
            },
            child: RectGetter(
              key: globalKey,
              child: CategoryItemWidget(
                  name: name,
                  icon: icon,
                  selected: name == currenItem,
              ),
            ),
          ),
        );
    });

    return ListView(
      scrollDirection: Axis.horizontal,
      children: widgets,
    );
  }

  void deleteCategory(String name){
    var db = Provider.of<DBRepository>(context, listen: false);
    db.deleteCategory(name);
  }
}

class CategoryItemWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;

  CategoryItemWidget({key, this.name = '', this.icon, this.selected = false}) : super(key: key);  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: selected ? Colors.blueAccent : Colors.blueGrey,
                width: selected ? 3.0 : 1.0
              )
            ),
            child: Icon(icon),
          ),
          Text(name),
        ],
      ),
    );
  }
}