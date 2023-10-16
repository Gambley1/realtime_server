import 'package:dart_frog/dart_frog.dart';
import 'package:realtime_server/_internal.dart';
import 'package:stormberry/stormberry.dart';

final _env = Env();

const _replicationMode = ReplicationMode.logical;
final _db = Database(
  database: _env.pgDatabase,
  port: _env.pgPort,
  user: _env.pgUser,
  password: _env.pgPassword,
  host: _env.pgHost,
  replicationMode: _replicationMode,
);

Middleware databaseProvider() {
  return provider<Database>((context) => _db);
}
