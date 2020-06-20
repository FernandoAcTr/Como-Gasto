import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
export '../models/expense.dart';

import '../models/category.dart';
export '../models/category.dart';

class DBRepository {
  String _userID;

  DBRepository(this._userID);

  Stream<List<Expense>> _expensesStream;
  Stream<List<Expense>> get expensesStream => _expensesStream;

  Stream<List<Category>> _categoryStream;
  Stream<List<Category>> get categoryStream => _categoryStream;

  Stream<QuerySnapshot> _categoryExpensesStream;
  Stream<QuerySnapshot> get categoryExpensesStream => _categoryExpensesStream;

  void addExpense(Expense expense, File photo) async {
    var document = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .document();
    await document.setData(expense.toMap());

    if (photo != null) {
      var imageName = Uuid().v1();
      var imagePath = '/users/$_userID/$imageName.jpg';
      var resizedImagePath =
          '/users/$_userID/${imageName}_200x200.jpg'; //el path que genera automaticamente firebase Storage

      final StorageReference storageReference =
          FirebaseStorage().ref().child(imagePath);
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
      streamSubscription.cancel(); //liberamos memoria
      document.setData({'imagePath': resizedImagePath}, merge: true);
    }
  }

  void addCategory(Category category) async {
    Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .document()
        .setData(category.toMap());
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

  void deleteCategoryExpense(String expenseID) async {
    Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .document(expenseID)
        .delete();
  }

  void getExpenses(int year, int month) {
    print("peticion getExpenses");

    _expensesStream = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((document) => Expense.fromMap(document.data))
            .toList());
  }

  void getCategories() {
    print("Peticion get categories");

    _categoryStream = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((document) => Category.fromMap(document.data))
            .toList());
  }

  Future<QuerySnapshot> getCategoryIcon(String categoryName) async {
    print("Peticion getCategoryIcon");

    return Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .snapshots()
        .first;
  }

  void getCategoryExpenses(String category, int year, int month) {
    print("Peticion getCategoryExpenses");

    _categoryExpensesStream = Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .where("category", isEqualTo: category)
        .snapshots();
  }
}
