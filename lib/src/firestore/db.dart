import 'package:cloud_firestore/cloud_firestore.dart';

class DB {

  static void addExpense(String category, double value, String userID) {
    Firestore.instance
      .collection('users')
      .document(userID)
      .collection('expenses').document().setData({
          'category': category,
          'value': value,
          'month': DateTime.now().month,
          'day': DateTime.now().day,
          'year': DateTime.now().year
        }
      );
  }

  static Stream<QuerySnapshot> getExpenses(int year, int month, String userID) {
    return Firestore.instance
        .collection('users')
        .document(userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .snapshots();
  }

  static void addCategory(String icon, String name, String userID) {
    Firestore.instance
        .collection('users')
        .document(userID)
        .collection('categories')
        .document()
        .setData({'icon': icon, 'name': name});
  }

  static Stream<QuerySnapshot> getCategories(String userID) {
    return Firestore.instance
    .collection('users')
    .document(userID)
    .collection('categories').snapshots();
  }

  static Future<QuerySnapshot> getCategoryIcon(String categoryName, String userID) async {
    final query = Firestore.instance
        .collection('users')
        .document(userID)
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .snapshots()
        .first;

    return query;
  }

  static deleteCategory(String name, String userID) async {
    final query =  await Firestore.instance
          .collection('users')
          .document(userID)
          .collection('categories')
          .where('name', isEqualTo: name)
          .snapshots()
          .first;

    final doc = query.documents.firstWhere((doc){
        return doc['name'] == name;
    });

    Firestore.instance
    .collection('users')
    .document(userID)
    .collection('categories')
    .document(doc.documentID).delete();
  }

  static getCategoryExpenses(String category, int year, int month, String userID){
      return Firestore.instance
        .collection('users')
        .document(userID)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where("month", isEqualTo: month)
        .where("category", isEqualTo: category)
        .snapshots();
  }

  static deleteCategoryExpense(String expenseID, String userID){
      Firestore.instance
        .collection('users')
        .document(userID)
        .collection('expenses')
        .document(expenseID)
        .delete();
  }
}
