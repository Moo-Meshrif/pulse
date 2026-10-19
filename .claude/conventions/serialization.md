# Serialization
Rule: hand-written `fromJson`/`toJson` wire models in `data/model/*_model.dart`, via `JsonMapper` (lib/core/utils/json_mapper.dart), nullable fields. Enums own wire values (`data/enums`).
Example: lib/features/profile/data/model/profile_model.dart
Lists/rows in datasources: `rpc<List<dynamic>>`, then `List<Map<String, dynamic>>.from(rows).map(Model.fromJson).toList()`; one row `Map<String, dynamic>.from(row as Map)`; request lists `items.map((i) => i.toJson()).toList()`. No `as List` / `as Map<String, dynamic>`, no `[for …]` (collection-for only to drop nulls or spread).
Example: lib/features/post/data/datasource/post_tags_datasource.dart
