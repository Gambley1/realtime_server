import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

Middleware databaseProvider() {
  //TODO(): replace to env variabled
  final db = Database(
    database: 'database',
    port: 5432,
    user: 'fl0user',
    password: 'SReUD1TP7JEl',
    host: 'ep-twilight-paper-31204147.ap-southeast-1.aws.neon.fl0.io',
  );

  return provider<Database>((context) => db);
}
