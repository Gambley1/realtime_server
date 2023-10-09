import 'package:stormberry/stormberry.dart';

part 'db_post.schema.dart';

@Model(tableName: 'Post')
abstract class DbPost {
  @PrimaryKey()
  String get id;

  String get userId;

  String get description;

  List<String> get likes;
}
