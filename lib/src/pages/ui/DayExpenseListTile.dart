import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DayExpenseListTile extends StatelessWidget {
  final document;

  const DayExpenseListTile({
    Key key,
    this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            size: 40,
          ),
          Positioned(
            child: Text(
              document['day'].toString(),
              textAlign: TextAlign.center,
            ),
            left: 0.0,
            right: 0.0,
            bottom: 10.0,
          )
        ],
      ),
      title: Container(
        child: Padding(
          child: Text(
            '${document['value']}',
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
      subtitle: document['imagePath'] == null
          ? null
          : FutureBuilder<String>(
              future: _getDownloadURL(document['imagePath']),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData){
                  print('Snapshot: ' + snapshot.data);
                  return _getImage(snapshot.data);
                } 
                return Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  Future<String> _getDownloadURL(String imagePath) async {
    final StorageReference storageReference =
        FirebaseStorage().ref().child(imagePath);
    var url = (await storageReference.getDownloadURL()).toString();
    return url;
  }

  Widget _getImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Image.network(
        imagePath,
        height: 200.0,
        width: double.infinity,
      ),
    );
  }
}
