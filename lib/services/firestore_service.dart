import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/utils/typedef.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> addDocument({
    required String collection,
    required DataMap data,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      final ref = await _collectionRef(
        collection,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      ).add(data);
      debugPrint('FirestoreService addDocument: ${ref.id} → $collection');
      return ref.id;
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error adding document to $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Future<void> setDocument({
    required String collection,
    required String docId,
    required DataMap data,
    bool merge = false,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      await _docRef(
        collection,
        docId,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      ).set(data, SetOptions(merge: merge));
      debugPrint('FirestoreService setDocument: $docId → $collection');
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error setting document $docId in $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required DataMap data,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      await _docRef(
        collection,
        docId,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      ).update(data);
      debugPrint('FirestoreService updateDocument: $docId → $collection');
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error updating document $docId in $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      await _docRef(
        collection,
        docId,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      ).delete();
      debugPrint('FirestoreService deleteDocument: $docId → $collection');
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error deleting document $docId in $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Future<DataMap?> getDocument({
    required String collection,
    required String docId,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      final snap = await _docRef(
        collection,
        docId,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      ).get();
      return snap.data();
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error getting document $docId from $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Future<List<DataMap>> getCollection({
    required String collection,
    DataMap? filters,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      Query<DataMap> query = _collectionRef(
        collection,
        parentCollection: parentCollection,
        parentDocId: parentDocId,
      );
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }
      final snap = await query.get();
      return snap.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
    } on FirebaseException catch (e, stack) {
      _handleFirebaseError(e, collection, stackTrace: stack);
    } on Exception catch (e) {
      debugPrint('Error getting collection $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Stream<DataMap?> documentStream({
    required String collection,
    required String docId,
    String? parentCollection,
    String? parentDocId,
  }) {
    return _docRef(
      collection,
      docId,
      parentCollection: parentCollection,
      parentDocId: parentDocId,
    ).snapshots().map((snap) => snap.data());
  }

  Stream<List<DataMap>> collectionStream({
    required String collection,
    DataMap? filters,
    String? parentCollection,
    String? parentDocId,
  }) {
    Query<DataMap> query = _collectionRef(
      collection,
      parentCollection: parentCollection,
      parentDocId: parentDocId,
    );
    if (filters != null) {
      for (final entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  CollectionReference<DataMap> _collectionRef(
    String collection, {
    String? parentCollection,
    String? parentDocId,
  }) {
    if (parentCollection != null && parentDocId != null) {
      return _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(collection);
    }
    return _firestore.collection(collection);
  }

  DocumentReference<DataMap> _docRef(
    String collection,
    String docId, {
    String? parentCollection,
    String? parentDocId,
  }) {
    return _collectionRef(
      collection,
      parentCollection: parentCollection,
      parentDocId: parentDocId,
    ).doc(docId);
  }

  Never _handleFirebaseError(
    FirebaseException e,
    String context, {
    StackTrace? stackTrace,
  }) {
    String errorMessage = 'An error occurred, please try again.';
    switch (e.code) {
      case 'permission-denied':
        errorMessage = "You don't have permission to perform this action.";
      case 'not-found':
        errorMessage = 'The requested document was not found.';
      case 'already-exists':
        errorMessage = 'The document already exists.';
      case 'resource-exhausted':
        errorMessage = 'Too many requests, please try again later.';
      case 'unauthenticated':
        errorMessage = 'Authentication required. Please sign in.';
      case 'unavailable':
        errorMessage = 'Service temporarily unavailable. Please try again.';
      case 'cancelled':
        errorMessage = 'The operation was cancelled.';
      case 'deadline-exceeded':
        errorMessage = 'The request timed out. Please try again.';
      case 'invalid-argument':
        errorMessage = 'Invalid data provided.';
      case 'internal':
        errorMessage = 'An internal error occurred. Please try again.';
      case 'data-loss':
        errorMessage = 'Unexpected data loss. Please try again.';
    }
    debugPrint('FirestoreService error: $errorMessage');
    // TODO: uncomment to enable crashlytics
    // FirebaseCrashlytics.instance.recordError(
    //   e,
    //   stackTrace ?? StackTrace.current,
    //   reason: 'FirestoreService error',
    // );
    throw APIException(
      message: errorMessage,
      statusCode: int.tryParse(e.code) ?? 500,
    );
  }
}
