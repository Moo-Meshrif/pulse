# Serialization
Rule: hand-written `fromJson`/`toJson` wire models in `data/model/*_model.dart`, via `JsonMapper` (lib/core/utils/json_mapper.dart), nullable fields. Enums own wire values (`data/enums`).
Example: lib/features/profile/data/model/profile_model.dart
