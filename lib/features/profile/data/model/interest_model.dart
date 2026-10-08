import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `public.interests`: a topic the user can pick on the Interests step. The app's concept
/// matches the row, so presentation uses this model directly (no entity that would only copy it).
class InterestModel extends Equatable {
  final int? id;
  final String? slug;
  final String? nameEn;
  final String? nameAr;
  final int? sortOrder;

  const InterestModel({
    this.id,
    this.slug,
    this.nameEn,
    this.nameAr,
    this.sortOrder,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) => InterestModel(
    id: JsonMapper.integer(json['id']),
    slug: JsonMapper.string(json['slug']),
    nameEn: JsonMapper.string(json['name_en']),
    nameAr: JsonMapper.string(json['name_ar']),
    sortOrder: JsonMapper.integer(json['sort_order']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name_en': nameEn,
    'name_ar': nameAr,
    'sort_order': sortOrder,
  };

  /// The name for a language code (`ar`, anything else is English), falling back to the other one.
  String? nameFor(String languageCode) =>
      languageCode == 'ar' ? (nameAr ?? nameEn) : (nameEn ?? nameAr);

  @override
  List<Object?> get props => [id, slug, nameEn, nameAr, sortOrder];
}
