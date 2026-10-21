import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/content_kind.dart';

/// Hears the server when a post or a story row changes. Opens the connection when listened to and closes
/// it when the listener cancels. It says only which kind changed, never what.
abstract interface class ContentLiveDatasource {
  Stream<ContentKind> pings();
}

/// [ContentLiveDatasource] as an adapter over Supabase Realtime (`posts` and `stories`).
@LazySingleton(as: ContentLiveDatasource)
final class SupabaseContentLiveDatasource implements ContentLiveDatasource {
  SupabaseContentLiveDatasource(this._client);

  final SupabaseClient _client;

  @override
  Stream<ContentKind> pings() {
    RealtimeChannel? channel;
    // ignore: close_sinks, closed when the listener cancels.
    late final StreamController<ContentKind> controller;
    controller = StreamController<ContentKind>(
      onListen: () {
        void ping(ContentKind kind) {
          if (!controller.isClosed) controller.add(kind);
        }

        channel = _client
            .channel('content-changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'posts',
              callback: (_) => ping(ContentKind.post),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'stories',
              callback: (_) => ping(ContentKind.story),
            )
            .subscribe();
      },
      onCancel: () async {
        final open = channel;
        if (open != null) await _client.removeChannel(open);
      },
    );
    return controller.stream;
  }
}
