import 'package:cloud_firestore/cloud_firestore.dart';

class DBRepository {

  String _userID;

  DBRepository(this._userID);

  void addExpense(String category, double value, DateTime date) {
    Firestore.instance
      .collection('users')
      .document(_userID)
      .collection('expenses').document().setData({
          'category': category,
          'value': value,
          'month': date.month,
          'day': date.day,
          'year': date.year
        }
      );
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

  void addCategory(String icon, String name) {
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
    .collection('categories').snapshots();
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
    final query =  await Firestore.instance
          .collection('users')
          .document(_userID)
          .collection('categories')
          .where('name', isEqualTo: name)
          .snapshots()
          .first;

    final doc = query.documents.firstWhere((doc){
        return doc['name'] == name;
    });

    Firestore.instance
    .collection('users')
    .document(_userID)
    .collection('categories')
    .document(doc.documentID).delete();
  }

  Stream<QuerySnapshot> getCategoryExpenses(String category, int year, int month){
      return Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .where("category", isEqualTo: category)
        .snapshots();
  }

  void deleteCategoryExpense(String expenseID){
      Firestore.instance
        .collection('users')
        .document(_userID)
        .collection('expenses')
        .document(expenseID)
        .delete();
  }
}
