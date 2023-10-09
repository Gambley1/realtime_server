// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'description': description,
      'likes': likes,
    };
  }

  String toJson() => json.encode(toMap());
}
