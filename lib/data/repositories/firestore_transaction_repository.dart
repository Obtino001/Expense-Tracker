import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Firestore-backed transaction store with real-time streams.
///
/// All reads/writes are scoped to the authenticated user. Pass the
/// current `uid` once (via the repository provider) and every method
/// operates on that user's data — security rules enforce it server-side.
class FirestoreTransactionRepository {
  FirestoreTransactionRepository({required this.uid, FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String uid;

  // ---------- Collection refs (typed via withConverter) ----------

  CollectionReference<TransactionModel> get _txCol => _db
      .collection(FirestorePaths.userTransactions(uid))
      .withConverter<TransactionModel>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> s, _) =>
            TransactionModel.fromJson(s.data()!),
        toFirestore: (TransactionModel t, _) => t.toJson(),
      );

  CollectionReference<CategoryModel> get _catCol => _db
      .collection(FirestorePaths.userCategories(uid))
      .withConverter<CategoryModel>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> s, _) =>
            CategoryModel.fromJson(s.data()!),
        toFirestore: (CategoryModel c, _) => c.toJson(),
      );

  CollectionReference<BudgetModel> get _budgetCol => _db
      .collection(FirestorePaths.userBudgets(uid))
      .withConverter<BudgetModel>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> s, _) =>
            BudgetModel.fromJson(s.data()!),
        toFirestore: (BudgetModel b, _) => b.toJson(),
      );

  // ---------- Transactions ----------

  /// Real-time stream of all transactions, newest first.
  Stream<List<TransactionModel>> watchAll() {
    return _txCol
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot<TransactionModel> s) =>
            s.docs.map((QueryDocumentSnapshot<TransactionModel> d) =>
                d.data()).toList());
  }

  /// Stream the transactions of a given month for the analytics screen.
  Stream<List<TransactionModel>> watchMonth(int year, int month) {
    final String key = '$year-${month.toString().padLeft(2, '0')}';
    return _txCol
        .where('yearMonth', isEqualTo: key)
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot<TransactionModel> s) =>
            s.docs.map((QueryDocumentSnapshot<TransactionModel> d) =>
                d.data()).toList());
  }

  Future<TransactionModel> add({
    required String title,
    required double amount,
    required DateTime date,
    required CategoryModel category,
    required TransactionType type,
    String note = '',
  }) async {
    final DocumentReference<TransactionModel> ref = _txCol.doc();
    final TransactionModel tx = TransactionModel(
      id: ref.id,
      userId: uid,
      title: title,
      amount: amount,
      date: date,
      category: category,
      type: type,
      note: note,
    );
    await ref.set(tx);
    return tx;
  }

  Future<void> update(TransactionModel tx) => _txCol.doc(tx.id).set(tx);

  Future<void> delete(String id) => _txCol.doc(id).delete();

  // ---------- Categories ----------

  Stream<List<CategoryModel>> watchCategories() {
    return _catCol.snapshots().map(
          (QuerySnapshot<CategoryModel> s) => s.docs
              .map((QueryDocumentSnapshot<CategoryModel> d) => d.data())
              .toList(),
        );
  }

  Future<void> addCategory(CategoryModel c) =>
      _catCol.doc(c.id).set(c);

  Future<void> deleteCategory(String id) => _catCol.doc(id).delete();

  /// Seed the user's category list with sensible defaults on first login.
  /// Idempotent — only writes docs that don't exist yet.
  Future<void> seedDefaultCategories(List<CategoryModel> defaults) async {
    final WriteBatch batch = _db.batch();
    for (final CategoryModel c in defaults) {
      batch.set(_catCol.doc(c.id), c, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ---------- Budgets ----------

  Stream<List<BudgetModel>> watchBudgets() {
    return _budgetCol.snapshots().map(
          (QuerySnapshot<BudgetModel> s) => s.docs
              .map((QueryDocumentSnapshot<BudgetModel> d) => d.data())
              .toList(),
        );
  }

  Future<BudgetModel> setBudget(BudgetModel b) async {
    await _budgetCol.doc(b.id).set(b);
    return b;
  }

  Future<void> deleteBudget(String id) => _budgetCol.doc(id).delete();
}
