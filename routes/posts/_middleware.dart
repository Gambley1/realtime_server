import 'package:dart_frog/dart_frog.dart';
import 'package:realtime_server/src/data/providers/database_provider.dart';
import 'package:realtime_server/src/data/providers/error_logger.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(errorLogger())
      .use(databaseProvider());
}
