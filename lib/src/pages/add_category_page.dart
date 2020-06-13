import 'package:flutter/material.dart';
import 'package:como_gasto/src/firestore/db_repository.dart';
import 'package:como_gasto/src/utils/icon_utils.dart' as iconUtils;
import 'package:como_gasto/src/widgets/category_selector_widget.dart';
import 'package:como_gasto/src/widgets/search_Icon_delegate.dart';
import 'package:provider/provider.dart';


class AddCategoryPage extends StatefulWidget {

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategoryPage> {

  String currentIcon = '';
  String categoryName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          title: Text('Add Category'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => showSearch(
                context: context, 
                delegate: SearchIcon(
                  onSelectedValue: (newIcon) => setState(() => currentIcon = newIcon )
                )
              ),
            ),
          ],
       ),
       body: _body(),       
    );
  }

  Widget _body() {    
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _categoryInputName(),
            _previewIcon(),
          ],
        ),
        Expanded(child: _listIcons()),
        _addButton(),
      ],
    );
  }

  Widget _categoryInputName(){
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: TextField(
            decoration: InputDecoration(
              labelText: 'Category Name',            
            ),
            onChanged: (newValue){
              setState(() => categoryName = newValue.trim());
            },
        ),
      ),
    );
  }

  Widget _previewIcon(){
    return CategoryItemWidget(
      icon: iconUtils.materialIconList[currentIcon],
      name: categoryName,
      selected: true,
    );
  }

  Widget _listIcons(){
    final widgets = <Widget>[];

    iconUtils.materialIconList.forEach((name, icon){
      widgets.add(
        _iconItem(name, icon)
      );
    });

    return GridView.count(
      crossAxisCount: 4,
      children: widgets,
    );
  }

  Widget _iconItem(String name, IconData icon){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          setState(() {
            currentIcon = name;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            child: Icon(
              icon,
              size: 40,
            ),
            decoration: BoxDecoration(
              color: name == currentIcon ? Colors.lightBlueAccent.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      );
  }

  Widget _addButton(){
    var db = Provider.of<DBRepository>(context, listen: false);
    return Container(
      width: double.infinity,
      height: 50.0,
      child: MaterialButton(
        child: Text('Add Category'),
        color: Colors.blueAccent,
        onPressed: (){
           db.addCategory(currentIcon, categoryName);
           Navigator.of(context).pop();
        },
      ),
    );
  }
}