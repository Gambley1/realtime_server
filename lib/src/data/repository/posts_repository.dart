import 'package:realtime_server/_internal.dart';
import 'package:stormberry/stormberry.dart';

class PostsRepository implements PostsDataSource, PostsLikesSource {
  PostsRepository({required Database db}) : _db = db;

  final Database _db;

  @override
  Future<void> createPost({
    required String userId,
    required String description,
  }) =>
      _db.dbPosts.insertOne(
        DbPostInsertRequest(
          id: UuidGenerator.generateRandomv4Uid(),
          userId: userId,
          description: description,
          likes: [],
        ),
      );

  @override
  Future<List<Post>> readPosts() async {
    final posts = <Post>[];
    final dbPosts = await _db.dbPosts.queryDbPosts();
    if (dbPosts.isEmpty) return [];

    for (final dbPost in dbPosts) {
      final post = Post.fromDb(dbPost);
      posts.add(post);
    }
    return posts;
  }

  @override
  Future<void> updatePost({
    required String id,
    String? description,
    String? like,
    List<String>? likes,
  }) async {
    final likes$ = <String>[...?likes];
    if (likes$.contains(like)) {
      likes$.remove(like);
    } else {
      likes$.add(like!);
    }
    await _db.dbPosts.updateOne(
      DbPostUpdateRequest(
        id: id,
        likes: likes$,
        description: description,
      ),
    );
  }

  @override
  Future<void> deletePost({
    required String id,
  }) =>
      _db.dbPosts.deleteOne(id);

  @override
  Future<List<String>> readLikes({required String id}) async {
    const query = '''
      SELECT likes FROM "Post" WHERE id = @id
    ''';
    final result = await _db.query(query, {'id': id});
    final row = result.firstOrNull;
    //TODO(): throw an actuall PostNotFound exception.
    if (row == null) throw Exception('Post not found!');

    final likes = row.first as List<String>;
    return likes;
  }

  @override
  Future<void> likePost({required String id, required String like}) async {
    final likes = await readLikes(id: id);
    await updatePost(id: id, like: like, likes: likes);
  }
}

abstract class PostsDataSource {
  Future<void> createPost({
    required String userId,
    required String description,
  });

  Future<List<Post>> readPosts();

  Future<void> updatePost({
    required String id,
    String? description,
    String? like,
  });

  Future<void> deletePost({
    required String id,
  });
}

abstract class PostsLikesSource {
  Future<List<String>> readLikes({required String id});

  Future<void> likePost({required String id, required String like});
}
