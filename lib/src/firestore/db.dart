import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DBRepository {
  String _userID;

  DBRepository(this._userID);

  void addExpense(String category, double value, DateTime date, File photo) async {

    var document = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .document();
    await document.setData({
      'category': category,
      'value': value,
      'month': date.month,
      'day': date.day,
      'year': date.year
    });

    if (photo != null) {
      var imageName = Uuid().v1();
      var imagePath = '/users/$_userID/$imageName.jpg';
      var resizedImagePath = '/users/$_userID/${imageName}_200x200.jpg';

      final StorageReference storageReference = FirebaseStorage().ref().child(imagePath);
      final StorageUploadTask uploadTask = storageReference.putFile(photo);

      final StreamSubscription<StorageTaskEvent> streamSubscription =
          uploadTask.events.listen((event) {
        // You can use this to notify yourself or your user in any kind of way.
        // For example: you could use the uploadTask.events stream in a StreamBuilder instead
        // to show your user what the current status is. In that case, you would not need to cancel any
        // subscription as StreamBuilder handles this automatically.

        // Here, every StorageTaskEvent concerning the upload is printed to the logs.
        print('EVENT ${event.type}');
      });

      // Cancel your subscription when done.
      await uploadTask.onComplete;
      streamSubscription.cancel();
      document.setData({'imagePath': resizedImagePath}, merge: true);
    }
  }

  Stream<QuerySnapshot> getExpenses(int year, int month) {
    return Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .snapshots();
  }

  void addCategory(String icon, String name) async {
    Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .document()
        .setData({'icon': icon, 'name': name});
  }

  Stream<QuerySnapshot> getCategories() {
    return Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .snapshots();
  }

  Future<QuerySnapshot> getCategoryIcon(String categoryName) async {
    final query = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .snapshots()
        .first;

    return query;
  }

  void deleteCategory(String name) async {
    final query = await Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .where('name', isEqualTo: name)
        .snapshots()
        .first;

    final doc = query.documents.firstWhere((doc) {
      return doc['name'] == name;
    });

    Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .document(doc.documentID)
        .delete();
  }

  Stream<QuerySnapshot> getCategoryExpenses(
      String category, int year, int month) {
    return Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .where("category", isEqualTo: category)
        .snapshots();
  }

  void deleteCategoryExpense(String expenseID) async {
    Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .document(expenseID)
        .delete();
  }
}
