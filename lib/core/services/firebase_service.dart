// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth      auth      = FirebaseAuth.instance;
  final FirebaseStorage   storage   = FirebaseStorage.instance;

  // ── Firestore Collection References ────────────────────────────────────────
  CollectionReference get users          => firestore.collection('users');
  CollectionReference get students       => firestore.collection('students');
  CollectionReference get teachers       => firestore.collection('teachers');
  CollectionReference get admins         => firestore.collection('admins');
  CollectionReference get fees           => firestore.collection('fees');
  CollectionReference get installments   => firestore.collection('installments');
  CollectionReference get attendance     => firestore.collection('attendance');
  CollectionReference get lectures       => firestore.collection('lectures');
  CollectionReference get notifications  => firestore.collection('notifications');
  CollectionReference get studyMaterials => firestore.collection('study_materials');
  CollectionReference get results        => firestore.collection('results');
  CollectionReference get announcements  => firestore.collection('announcements');
  CollectionReference get batches        => firestore.collection('batches');
  CollectionReference get homework       => firestore.collection('homework');

  // ── Auth Helpers ────────────────────────────────────────────────────────────
  User? get currentUser => auth.currentUser;
  String? get currentUid => auth.currentUser?.uid;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmail(String email, String password) async {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async => auth.signOut();

  // ── Firestore Helpers ───────────────────────────────────────────────────────
  Future<DocumentSnapshot> getDoc(String collection, String id) {
    return firestore.collection(collection).doc(id).get();
  }

  Future<void> setDoc(
    String collection, String id, Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return firestore.collection(collection).doc(id).set(
      data, SetOptions(merge: merge),
    );
  }

  Future<void> updateDoc(String collection, String id, Map<String, dynamic> data) {
    return firestore.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDoc(String collection, String id) {
    return firestore.collection(collection).doc(id).delete();
  }

  Future<DocumentReference> addDoc(String collection, Map<String, dynamic> data) {
    return firestore.collection(collection).add(data);
  }

  Stream<DocumentSnapshot> watchDoc(String collection, String id) {
    return firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot> watchCollection(
    String collection, {
    List<List<dynamic>> whereConditions = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = firestore.collection(collection);
    for (final cond in whereConditions) {
      query = query.where(cond[0] as String, isEqualTo: cond[1]);
    }
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null)   query = query.limit(limit);
    return query.snapshots();
  }

  // ── Timestamp ───────────────────────────────────────────────────────────────
  static Timestamp get now => Timestamp.now();
  static Timestamp fromDate(DateTime date) => Timestamp.fromDate(date);
}
