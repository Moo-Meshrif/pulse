import '../../../../core/utils/json_mapper.dart';

class HelpArticleModel {
  const HelpArticleModel({
    this.id,
    this.questionEn,
    this.questionAr,
    this.answerEn,
    this.answerAr,
  });

  factory HelpArticleModel.fromJson(Map<String, dynamic> json) =>
      HelpArticleModel(
        id: JsonMapper.integer(json['id']),
        questionEn: JsonMapper.string(json['question_en']),
        questionAr: JsonMapper.string(json['question_ar']),
        answerEn: JsonMapper.string(json['answer_en']),
        answerAr: JsonMapper.string(json['answer_ar']),
      );

  final int? id;
  final String? questionEn;
  final String? questionAr;
  final String? answerEn;
  final String? answerAr;

  String question(String languageCode) =>
      (languageCode == 'ar' ? questionAr : questionEn) ?? questionEn ?? '';
  String answer(String languageCode) =>
      (languageCode == 'ar' ? answerAr : answerEn) ?? answerEn ?? '';
}
