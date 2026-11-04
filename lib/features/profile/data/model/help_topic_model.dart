import '../../../../core/utils/json_mapper.dart';

class HelpTopicModel {
  const HelpTopicModel({
    this.id,
    this.slug,
    this.icon,
    this.titleEn,
    this.titleAr,
  });

  factory HelpTopicModel.fromJson(Map<String, dynamic> json) => HelpTopicModel(
    id: JsonMapper.integer(json['id']),
    slug: JsonMapper.string(json['slug']),
    icon: JsonMapper.string(json['icon']),
    titleEn: JsonMapper.string(json['title_en']),
    titleAr: JsonMapper.string(json['title_ar']),
  );

  final int? id;
  final String? slug;
  final String? icon;
  final String? titleEn;
  final String? titleAr;

  String title(String languageCode) =>
      (languageCode == 'ar' ? titleAr : titleEn) ?? titleEn ?? '';
}
