import '../../../../../core/error/failures.dart';
import '../../../../../core/services/photo_picker_service.dart';
import '../../../data/enums/problem_category.dart';

class ReportState {
  const ReportState({
    this.category,
    this.message = '',
    this.photos = const [],
    this.includeLogs = true,
    this.sending = false,
    this.completed = 0,
    this.sent = false,
    this.failure,
  });
  final ProblemCategory? category;
  final String message;
  final List<PickedPhoto> photos;
  final bool includeLogs;
  final bool sending;
  final int completed;
  final bool sent;
  final Failure? failure;
  bool get isMessageValid =>
      message.trim().length >= 10 && message.length <= 500;
  bool get canSend => !sending && category != null && isMessageValid;
  ReportState copyWith({
    ProblemCategory? category,
    String? message,
    List<PickedPhoto>? photos,
    bool? includeLogs,
    bool? sending,
    int? completed,
    bool? sent,
    Failure? failure,
  }) => ReportState(
    category: category ?? this.category,
    message: message ?? this.message,
    photos: photos ?? this.photos,
    includeLogs: includeLogs ?? this.includeLogs,
    sending: sending ?? this.sending,
    completed: completed ?? this.completed,
    sent: sent ?? this.sent,
    failure: failure,
  );
}
