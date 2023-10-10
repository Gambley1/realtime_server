// ignore_for_file: annotate_overrides

part of 'db_post.dart';

extension DbPostRepositories on Database {
  DbPostRepository get dbPosts => DbPostRepository._(this);
}

abstract class DbPostRepository
    implements
        ModelRepository,
        ModelRepositoryInsert<DbPostInsertRequest>,
        ModelRepositoryUpdate<DbPostUpdateRequest>,
        ModelRepositoryDelete<String> {
  factory DbPostRepository._(Database db) = _DbPostRepository;

  Future<DbPostView?> queryDbPost(String id);
  Future<List<DbPostView>> queryDbPosts([QueryParams? params]);
}

class _DbPostRepository extends BaseRepository
    with
        RepositoryInsertMixin<DbPostInsertRequest>,
        RepositoryUpdateMixin<DbPostUpdateRequest>,
        RepositoryDeleteMixin<String>
    implements DbPostRepository {
  _DbPostRepository(super.db) : super(tableName: 'Post', keyName: 'id');

  @override
  Future<DbPostView?> queryDbPost(String id) {
    return queryOne(id, DbPostViewQueryable());
  }

  @override
  Future<List<DbPostView>> queryDbPosts([QueryParams? params]) {
    return queryMany(DbPostViewQueryable(), params);
  }

  @override
  Future<void> insert(List<DbPostInsertRequest> requests) async {
    if (requests.isEmpty) return;
    final values = QueryValues();
    await db.query(
      'INSERT INTO "Post" ( "id", "user_id", "description", "likes" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.id)}:text, ${values.add(r.userId)}:text, ${values.add(r.description)}:text, ${values.add(r.likes)}:_text )').join(', ')}\n',
      values.values,
    );
  }

  @override
  Future<void> update(List<DbPostUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    final values = QueryValues();
    await db.query(
      'UPDATE "Post"\n'
      'SET "user_id" = COALESCE(UPDATED."user_id", "Post"."user_id"), "description" = COALESCE(UPDATED."description", "Post"."description"), "likes" = COALESCE(UPDATED."likes", "Post"."likes")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:text::text, ${values.add(r.userId)}:text::text, ${values.add(r.description)}:text::text, ${values.add(r.likes)}:_text::_text )').join(', ')} )\n'
      'AS UPDATED("id", "user_id", "description", "likes")\n'
      'WHERE "Post"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class DbPostInsertRequest {
  DbPostInsertRequest({
    required this.id,
    required this.userId,
    required this.description,
    required this.likes,
  });

  final String id;
  final String userId;
  final String description;
  final List<String> likes;
}

class DbPostUpdateRequest {
  DbPostUpdateRequest({
    required this.id,
    this.userId,
    this.description,
    this.likes,
  });

  final String id;
  final String? userId;
  final String? description;
  final List<String>? likes;
}

class DbPostViewQueryable extends KeyedViewQueryable<DbPostView, String> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(String key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "Post".*'
      'FROM "Post"';

  @override
  String get tableAlias => 'Post';

  @override
  DbPostView decode(TypedMap map) => DbPostView(
      id: map.get('id'),
      userId: map.get('user_id'),
      description: map.get('description'),
      likes: map.getListOpt('likes') ?? const [],);
}

class DbPostView {
  DbPostView({
    required this.id,
    required this.userId,
    required this.description,
    required this.likes,
  });

  final String id;
  final String userId;
  final String description;
  final List<String> likes;
}
