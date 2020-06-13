
import 'package:flutter/material.dart';

import 'package:como_gasto/src/utils/icon_utils.dart' as iconUtils;

class SearchIcon extends SearchDelegate{

  final Function(String) onSelectedValue;

  SearchIcon({@required this.onSelectedValue});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
        IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null), 
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty)
      return Container();

    var icons = <Widget>[];

    iconUtils.materialIconList.forEach((name, icon){
        if(name.contains(query.toLowerCase()))
          icons.add(  _iconItem(name, icon, context) );  
    });

    return GridView.count(
      crossAxisCount: 4,
      children: icons,
    );
  }

  Widget _iconItem(String name, IconData icon, BuildContext context){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          onSelectedValue(name);
          close(context, null);
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 40,
          ),
        ),
      );
  }



}