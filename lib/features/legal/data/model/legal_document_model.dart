import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row returned by `legal_document(p_type, p_locale)`: the page's title and its HTML, in the
/// requested language or in English when that one is missing ([locale] says which came back).
class LegalDocumentModel extends Equatable {
  final String? title;
  final String? html;
  final String? locale;

  const LegalDocumentModel({this.title, this.html, this.locale});

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) =>
      LegalDocumentModel(
        title: JsonMapper.string(json['title']),
        html: JsonMapper.string(json['html']),
        locale: JsonMapper.string(json['locale']),
      );

  Map<String, dynamic> toJson() => {
    'title': title,
    'html': html,
    'locale': locale,
  };

  @override
  List<Object?> get props => [title, html, locale];
}
