import 'package:flutter/foundation.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/utils/typedef.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseService {
  SupabaseDatabaseService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String> addDocument({
    required String collection,
    required DataMap data,
    String? parentCollection,
    String? parentDocId,
  }) async {
    try {
      final response = await _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .insert(data)
          .select('id')
          .single();
      final id = response['id']?.toString() ?? '';
      debugPrint('SupabaseService addDocument: $id -> $collection');
      return id;
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error adding row to $collection: $e');
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
      await _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .upsert({'id': docId, ...data});
      debugPrint('SupabaseService setDocument: $docId -> $collection');
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error setting row $docId in $collection: $e');
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
      await _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .update(data)
          .eq('id', docId);
      debugPrint('SupabaseService updateDocument: $docId -> $collection');
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error updating row $docId in $collection: $e');
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
      await _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .delete()
          .eq('id', docId);
      debugPrint('SupabaseService deleteDocument: $docId -> $collection');
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error deleting row $docId from $collection: $e');
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
      return await _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .select()
          .eq('id', docId)
          .maybeSingle();
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error getting row $docId from $collection: $e');
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
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
          .from(_tableName(collection, parentCollection, parentDocId))
          .select();
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }
      final rows = await query;
      return rows;
    } on PostgrestException catch (e) {
      _handleSupabaseError(e, collection);
    } catch (e) {
      debugPrint('Error getting table $collection: $e');
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  Stream<DataMap?> documentStream({
    required String collection,
    required String docId,
    String? parentCollection,
    String? parentDocId,
  }) {
    return _client
        .from(_tableName(collection, parentCollection, parentDocId))
        .stream(primaryKey: ['id'])
        .eq('id', docId)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Stream<List<DataMap>> collectionStream({
    required String collection,
    DataMap? filters,
    String? parentCollection,
    String? parentDocId,
  }) {
    final stream = _client
        .from(_tableName(collection, parentCollection, parentDocId))
        .stream(primaryKey: ['id']);

    return stream.map((rows) {
      if (filters == null || filters.isEmpty) return rows;
      return rows.where((row) {
        return filters.entries.every((entry) => row[entry.key] == entry.value);
      }).toList();
    });
  }

  String _tableName(
    String collection,
    String? parentCollection,
    String? parentDocId,
  ) {
    if (parentCollection != null && parentDocId != null) {
      debugPrint(
        '[SupabaseService] Nested collection path requested: '
        '$parentCollection/$parentDocId/$collection. Using $collection table.',
      );
    }
    return collection;
  }

  Never _handleSupabaseError(PostgrestException e, String context) {
    debugPrint('SupabaseService error in $context: ${e.message}');
    throw APIException(
      message: e.message,
      statusCode: int.tryParse(e.code ?? '') ?? 500,
    );
  }
}

@Deprecated('Use SupabaseDatabaseService instead.')
typedef FirestoreService = SupabaseDatabaseService;
