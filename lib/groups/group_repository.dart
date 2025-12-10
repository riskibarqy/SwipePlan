import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/user_id_mapper.dart';

class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int? memberCount;
  final DateTime? updatedAt;
}

abstract class GroupRepository {
  Future<String> createGroup({required String name, required String userId});
  Future<void> joinGroup({required String groupId, required String userId});
  Future<List<GroupSummary>> fetchUserGroups({required String userId});
}

class SupabaseGroupRepository implements GroupRepository {
  SupabaseGroupRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createGroup({
    required String name,
    required String userId,
  }) async {
    final dbUserId = UserIdMapper.normalize(userId);
    await _ensureUser(dbUserId);
    final response =
        await _client
            .from('groups')
            .insert({'name': name, 'created_by': dbUserId})
            .select()
            .single();
    return response['id'].toString();
  }

  @override
  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    final dbUserId = UserIdMapper.normalize(userId);
    await _ensureUser(dbUserId);
    await _client.from('group_members').upsert({
      'group_id': groupId,
      'user_id': dbUserId,
    }, onConflict: 'group_id,user_id');
  }

  @override
  Future<List<GroupSummary>> fetchUserGroups({required String userId}) async {
    final dbUserId = UserIdMapper.normalize(userId);
    final membershipResponse = await _client
        .from('group_members')
        .select('group_id')
        .eq('user_id', dbUserId)
        .order('joined_at', ascending: false);

    final membershipRows = List<Map<String, dynamic>>.from(
      membershipResponse as List? ?? const [],
    );
    final ids =
        membershipRows
            .map((row) => row['group_id']?.toString())
            .whereType<String>()
            .toList();
    if (ids.isEmpty) return const [];

    final groupsResponse = await _client
        .from('groups')
        .select('id,name,updated_at, group_members(count)')
        .inFilter('id', ids)
        .order('updated_at', ascending: false);

    final groups = List<Map<String, dynamic>>.from(
      groupsResponse as List? ?? const [],
    );
    return groups.map((row) {
      final membersData = List<Map<String, dynamic>>.from(
        row['group_members'] as List? ?? const [],
      );
      final memberCount =
          membersData.isEmpty
              ? null
              : int.tryParse(membersData.first['count'].toString());
      return GroupSummary(
        id: row['id'].toString(),
        name: row['name']?.toString() ?? 'Untitled crew',
        memberCount: memberCount,
        updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? ''),
      );
    }).toList();
  }

  Future<void> _ensureUser(String userId) {
    return _client.from('users').upsert({'id': userId}, onConflict: 'id');
  }
}
