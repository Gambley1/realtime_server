import 'package:dart_frog/dart_frog.dart';
import 'package:realtime_server/src/data/providers/database_provider.dart';

Handler middleware(Handler handler) {
  return handler.use(databaseProvider());
}
