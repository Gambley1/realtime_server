import 'package:realtime_server/_internal.dart';
import 'package:stormberry/stormberry.dart';

abstract class PostsException implements Exception {
  const PostsException(this.error);

  final Object error;

  @override
  String toString() => 'PostsException: $error';
}

final class PostNotFound extends PostsException {
  const PostNotFound() : super('Post not found!');

  @override
  String toString() => 'PostNotFound: $error';
}

class PostsRepository implements PostsDataSource {
  PostsRepository({required Database db}) : _db = db;

  final Database _db;

  Future<bool> _postExists({required String id}) async {
    final exists =
        ((await _db.query('SELECT check_post_exists(@postId)', {'postId': id}))
            .first
            .first) as bool;
    return exists;
  }

  @override
  Future<void> createPost({
    required String userId,
    required String description,
  }) =>
      _db.dbPosts.insertOne(
        DbPostInsertRequest(
          id: UuidGenerator.v4(),
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
  Future<Post?> readPost({required String id}) async {
    final dbPost = await _db.dbPosts.queryDbPost(id);
    if (dbPost == null) return null;
    return Post.fromDb(dbPost);
  }

  @override
  Future<void> updatePost({
    required String id,
    String? description,
    String? like,
  }) =>
      _db.query('SELECT update_post(@postId, @like, @new_description);', {
        'like': like,
        'postId': id,
        'new_description': description,
      });

  @override
  Future<void> deletePost({
    required String id,
  }) async {
    final exists = await _postExists(id: id);
    if (!exists) throw const PostNotFound();

    await _db.dbPosts.deleteOne(id);
  }
}

abstract class PostsDataSource {
  Future<void> createPost({
    required String userId,
    required String description,
  });

  Future<List<Post>> readPosts();

  Future<Post?> readPost({required String id});

  Future<void> updatePost({
    required String id,
    String? description,
    String? like,
  });

  Future<void> deletePost({
    required String id,
  });
}
