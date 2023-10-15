import 'package:stormberry/stormberry.dart';

extension DropFunctionTrigger on Database {}

extension PostsDatabaseFunctionsAndTriggersRepositories
    on PostgreSQLConnection {
  PostsDatabaseFunctionsAndTriggersRepository get postsFuncTriggers =>
      PostsDatabaseFunctionsAndTriggersRepository._(connection: this);
}

abstract class BasePostgreSQLDatabase {
  const BasePostgreSQLDatabase({
    required this.connection,
    required this.tableName,
  });

  final PostgreSQLConnection connection;

  final String tableName;

  String get tableLowerCase => tableName.toLowerCase();

  String get insertChannel => '${tableLowerCase}_insertions';

  String get updateChannel => '${tableLowerCase}_deletions';

  String get deleteChannel => '${tableLowerCase}_updates';

  List<String> get listenChannels => [
        insertChannel,
        updateChannel,
        deleteChannel,
      ];
}

sealed class _Droppable {
  Future<void> dropFunction({required String name});

  Future<void> dropTrigger({
    required String name,
    String? table,
  });
}

sealed class _Listenable {
  Future<void> listen({List<String>? channels});
}

abstract class PostsDatabaseFunctionsAndTriggersRepository
    implements _Droppable, _Listenable {
  factory PostsDatabaseFunctionsAndTriggersRepository._({
    required PostgreSQLConnection connection,
  }) =>
      _PostsDatabaseFunctionsAndTriggersRepository._(connection: connection);
  Future<void> executePostUpdateFunction({bool drop = false});

  Future<void> executePostUpdateTrigger({bool drop = false});

  Future<void> executePostInsertFunction({bool drop = false});

  Future<void> executePostInsertTrigger({bool drop = false});

  Future<void> executePostDeleteFunction({bool drop = false});

  Future<void> executePostDeleteTrigger({bool drop = false});
}

class _PostsDatabaseFunctionsAndTriggersRepository
    extends BasePostgreSQLDatabase
    implements PostsDatabaseFunctionsAndTriggersRepository {
  _PostsDatabaseFunctionsAndTriggersRepository._({required super.connection})
      : super(
          tableName: 'Post',
        );

  Future<void> _execute(String query) => connection.execute(query);

  @override
  Future<void> listen({List<String>? channels}) async {
    Future<void> listen(String channel) => _execute('LISTEN $channel');
    if (channels != null) {
      for (final channel in channels) {
        await listen(channel);
      }
    } else {
      for (final channel in listenChannels) {
        print('Listen for channel: $channel');
        await listen(channel);
      }
    }
  }

  @override
  Future<void> executePostDeleteFunction({bool drop = false}) async {
    if (drop) {
      await dropFunction(name: 'notify_post_delete');
      return;
    }

    final query = '''
    CREATE OR REPLACE FUNCTION notify_post_delete() RETURNS TRIGGER AS \$\$
        DECLARE
            payload text;
            channel text := '$deleteChannel';
        BEGIN
            payload := json_build_object(
              'change', TG_OP,
              'post_id', OLD.id
            )::text;
            PERFORM pg_notify(channel, payload);
            
            RETURN OLD;
        END;
        \$\$ LANGUAGE plpgsql;
    ''';

    await _execute(query);
  }

  @override
  Future<void> executePostDeleteTrigger({bool drop = false}) async {
    if (drop) {
      await dropTrigger(name: 'post_delete_trigger')
          .then((_) => dropFunction(name: 'notify_post_delete'));
      return;
    }
    final query = '''
    CREATE TRIGGER post_delete_trigger
      AFTER DELETE ON "$tableName"
      FOR EACH ROW
      EXECUTE FUNCTION notify_post_delete();
    ''';

    await _execute(query);
  }

  @override
  Future<void> executePostInsertFunction({bool drop = false}) async {
    if (drop) {
      await dropFunction(name: 'notify_post_insert');
      return;
    }

    final query = '''
      CREATE OR REPLACE FUNCTION notify_post_insert() RETURNS TRIGGER AS \$\$
DECLARE
    payload text;
    channel text := '$insertChannel';
BEGIN
    payload := json_build_object(
        'change', TG_OP,
        'post_id', NEW.id,
        'description', NEW.description,
        'likes', NEW.likes,
        'user_id', NEW.user_id
    )::text;

    PERFORM pg_notify(channel, payload);
    
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;
    ''';

    await _execute(query);
  }

  @override
  Future<void> executePostInsertTrigger({bool drop = false}) async {
    if (drop) {
      await dropTrigger(name: 'post_insert_trigger')
          .then((_) => dropFunction(name: 'notify_post_insert'));
      return;
    }

    final query = '''
      CREATE TRIGGER post_insert_trigger
   AFTER INSERT ON "$tableName"
   FOR EACH ROW
   EXECUTE FUNCTION notify_post_insert();
    ''';

    await _execute(query);
  }

  @override
  Future<void> executePostUpdateFunction({bool drop = false}) async {
    if (drop) {
      await dropFunction(name: 'notify_post_update');
      return;
    }

    final query = '''
    CREATE OR REPLACE FUNCTION notify_post_update()
        RETURNS TRIGGER AS \$\$
        DECLARE
          payload text;
          channel text := '$updateChannel';
          changed_fields JSON;

        BEGIN
          IF NEW.likes <> OLD.likes THEN
        changed_fields := json_build_object('likes', NEW.likes);
    ELSE
        changed_fields := '{}'::JSON;
    END IF;

    IF NEW.description <> OLD.description THEN
        changed_fields := json_build_object('description', NEW.description);
    END IF;
    
    payload := json_build_object(
        'change', TG_OP,
        'post_id', NEW.id,
        'changed_fields', changed_fields,
        'timestamp', now() AT TIME ZONE 'Europe/Paris'
    )::text;

    PERFORM pg_notify(channel, payload);

          RETURN NEW;
        END;
      \$\$
      LANGUAGE plpgsql;
    ''';

    await _execute(query);
  }

  @override
  Future<void> executePostUpdateTrigger({bool drop = false}) async {
    if (drop) {
      await dropTrigger(name: 'post_update_trigger')
          .then((_) => dropFunction(name: 'notify_post_update'));
      return;
    }

    final query = '''
    CREATE TRIGGER post_update_trigger
        AFTER UPDATE ON "$tableName"
        FOR EACH ROW
        EXECUTE FUNCTION notify_post_update();
    ''';

    await _execute(query);
  }

  @override
  Future<void> dropFunction({required String name}) async {
    final query = 'DROP FUNCTION IF EXISTS $name;';

    await _execute(query);
  }

  @override
  Future<void> dropTrigger({
    required String name,
    String? table,
  }) async {
    final query = 'DROP TRIGGER IF EXISTS $name ON "$tableName";';

    await _execute(query);
  }
}
