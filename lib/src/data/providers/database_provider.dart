import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

Middleware databaseProvider() {
  //TODO(): complete database providre
  final db = Database();

  return provider<Database>((context) => db);
}
