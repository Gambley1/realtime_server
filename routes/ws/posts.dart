import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:intl/intl.dart';
import 'package:stormberry/stormberry.dart';

final clients = <WebSocketChannel>[];

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) async {
      clients.add(channel);
      print('Active clients: ${clients.length}');

      late Database db;
      late PostgreSQLConnection connection;
      try {
        db = context.read<Database>();
        connection = await db.currentConnection;

        await connection.execute('LISTEN posts_changed_channel');
      } catch (e) {
        print('Database connection error: $e');
        db = context.read<Database>();
        connection = await db.currentConnection;

        await connection.execute('LISTEN posts_changed_channel');
      }
      try {
        connection.notifications.listen(
          (notification) {
            print('Notification: ${notification.detailedJson()}');

            final json = notification.detailedJson();

            channel.sink.add(json);
          },
          onError: (dynamic e) {
            print('Error, listening to the connection notifications.');
            print(e);
          },
          onDone: () {
            clients.remove(channel);
            print('On done, listening to the connection notifications');
          },
          // cancelOnError: true,
        );
      } on SocketException {
        print('Can not connect to the database, reconnect.');
        rethrow;
      } catch (e) {
        print('Uncaught exception occured.');
        print('$e');
      }
    },
    allowedOrigins: ['*'],
  );
  return handler(context);
}

extension on Notification {
  Map<String, dynamic> toMap() => {
        'channel': channel,
        'payload': payload,
        'proccessId': processID,
      };

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> detailed() => {
        'notification': toJson(),
        'createdAt': DateTime.now().prettier(),
      };

  String detailedJson() => jsonEncode(detailed());
}

extension on DateTime {
  static final f = DateFormat('yyyy-MM-dd hh:mm');

  String prettier() => f.format(this);
}
