import 'package:realtime_server/src/data/models/postgres/db_post.dart';

class Post {
  Post({
    required this.id,
    required this.userId,
    required this.description,
    required this.likes,
  });

  factory Post.fromDb(DbPostView post) => Post(
        id: post.id,
        userId: post.userId,
        description: post.description,
        likes: post.likes,
      );

  final String id;
  final String userId;
  final String description;
  final List<String> likes;
}
