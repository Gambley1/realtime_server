/*
 * ----------------------------------------------------------------------------
 *
 * This file is part of the metal_bonus_backend project, available at:
 * https://github.com/Gambley1/realtime_server/
 *
 * Created by: Emil Zulufov
 * ----------------------------------------------------------------------------
 *
 * Copyright (c) 2020 Emil Zulufov
 *
 * Licensed under the MIT License.
 *
 * ----------------------------------------------------------------------------
*/

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:realtime_server/_internal.dart';
import 'package:stormberry/stormberry.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _createPost(context),
    HttpMethod.get => _getPosts(context),
    HttpMethod.put => _updatePost(context),
    HttpMethod.delete => _deletePost(context),
    _ => Future.value(
        Response.json(
          statusCode: HttpStatus.methodNotAllowed,
          body: {
            'error': 'Method ${context.request.method} is not allowed',
            'code': ErrorCode.methodNotAllowed.value,
          },
        ),
      ),
  };
}

Future<Response> _createPost(RequestContext context) async {
  late Map<String, dynamic>? body;
  try {
    body = await context.safeRequestJSON();
  } on RequestBodyException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'error': 'Something went wrong with request body. $e',
        'code': ErrorCode.unexpectedError.value,
      },
    );
  }

  if (body == null) {
    return Response.json(
      statusCode: HttpStatus.notAcceptable,
      body: {
        'error': 'Missing request body.',
        'code': ErrorCode.missingRequestBody.value,
      },
    );
  }

  final userId = body['userId'] as String;
  final description = body['description'] as String;

  try {
    final db = context.read<Database>();
    final postRepository = PostsRepository(db: db);

    await postRepository.createPost(userId: userId, description: description);
    print('Successfully create post!');
    return Response(
      body: 'Successfully create post!',
    );
  } on SocketException {
    print('[Posts.create] Can not connect to the database.');
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {
        'error': 'Cannot connect to the database.',
        'code': ErrorCode.databaseConnectionError.value,
      },
    );
  } catch (e) {
    print('[Posts.create] Unexpected error occured.');
    print('Error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': e,
        'code': ErrorCode.unexpectedError.value,
        'message': 'An unexpected error occured. Please try again later.',
      },
    );
  }
}

Future<Response> _getPosts(RequestContext context) async {
  try {
    final db = context.read<Database>();
    final postsRepository = PostsRepository(db: db);

    final posts = await postsRepository.readPosts();

    return Response.json(
      body: {
        'posts': posts,
      },
    );
  } on SocketException {
    print('[Posts.get] Can not connect to the database.');
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {
        'error': 'Cannot connect to the database.',
        'code': ErrorCode.databaseConnectionError.value,
      },
    );
  } catch (e) {
    print('[Posts.get] Unexpected error occured.');
    print('Error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': e,
        'code': ErrorCode.unexpectedError.value,
        'message': 'An unexpected error occured. Please try again later.',
      },
    );
  }
}

Future<Response> _updatePost(RequestContext context) async {
  late Map<String, dynamic>? body;
  try {
    body = await context.safeRequestJSON();
  } on RequestBodyException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'error': 'Something went wrong with request body. $e',
        'code': ErrorCode.unexpectedError.value,
      },
    );
  }

  if (body == null) {
    return Response.json(
      statusCode: HttpStatus.notAcceptable,
      body: {
        'error': 'Missing request body.',
        'code': ErrorCode.missingRequestBody.value,
      },
    );
  }

  final id = body['postId'] as String;
  final description = body['description'] as String?;
  final like = body['like'] as String?;

  try {
    final db = context.read<Database>();
    final postsRepository = PostsRepository(db: db);

    if (like != null) {
      await postsRepository.likePost(id: id, like: like);
    } else {
      await postsRepository.updatePost(
        id: id,
        description: description,
      );
    }

    return Response(
      body: 'Successfully updated post!',
    );
  } on SocketException {
    print('[Posts.update] Can not connect to the database.');
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {
        'error': 'Cannot connect to the database.',
        'code': ErrorCode.databaseConnectionError.value,
      },
    );
  } catch (e) {
    print('[Posts.update] Unexpected error occured.');
    print('Error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': e,
        'code': ErrorCode.unexpectedError.value,
        'message': 'An unexpected error occured. Please try again later.',
      },
    );
  }
}

Future<Response> _deletePost(RequestContext context) async {
  late Map<String, dynamic>? body;
  try {
    body = await context.safeRequestJSON();
  } on RequestBodyException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'error': 'Something went wrong with request body. $e',
        'code': ErrorCode.unexpectedError.value,
      },
    );
  }

  if (body == null) {
    return Response.json(
      statusCode: HttpStatus.notAcceptable,
      body: {
        'error': 'Missing request body.',
        'code': ErrorCode.missingRequestBody.value,
      },
    );
  }

  final id = body['postId'] as String;

  try {
    final db = context.read<Database>();
    final postsRepository = PostsRepository(db: db);

    await postsRepository.deletePost(id: id);

    return Response(
      body: 'Successfully deleted post!',
    );
  } on SocketException {
    print('[Posts.delete] Can not connect to the database.');
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {
        'error': 'Cannot connect to the database.',
        'code': ErrorCode.databaseConnectionError.value,
      },
    );
  } catch (e) {
    print('[Posts.delete] Unexpected error occured.');
    print('Error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': e,
        'code': ErrorCode.unexpectedError.value,
        'message': 'An unexpected error occured. Please try again later.',
      },
    );
  }
}
