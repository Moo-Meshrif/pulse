import 'package:injectable/injectable.dart';

import '../../../../../core/services/photo_picker_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../data/datasource/problem_report_datasource.dart';
import '../../../data/enums/problem_category.dart';
import 'report_state.dart';

@injectable
class ReportCubit extends BaseCubit<ReportState> {
  ReportCubit(this._datasource) : super(const ReportState());
  final ProblemReportDatasource _datasource;
  void categoryChanged(ProblemCategory category) {
    if (!state.sending) emit(state.copyWith(category: category));
  }

  void messageChanged(String message) {
    if (!state.sending) emit(state.copyWith(message: message));
  }

  void logsChanged(bool value) {
    if (!state.sending) emit(state.copyWith(includeLogs: value));
  }

  void addPhotos(List<PickedPhoto> photos) {
    if (!state.sending) {
      emit(
        state.copyWith(photos: [...state.photos, ...photos].take(3).toList()),
      );
    }
  }

  void removePhoto(int index) {
    if (!state.sending) {
      emit(state.copyWith(photos: [...state.photos]..removeAt(index)));
    }
  }

  Future<void> send() => run(
    () => _datasource.submit(
      category: state.category!.wire,
      message: state.message,
      photos: state.photos,
      includeLogs: state.includeLogs,
      onProgress: (count) => emit(state.copyWith(completed: count)),
    ),
    prevent: !state.canSend,
    loading: state.copyWith(sending: true, completed: 0),
    onSuccess: (_) => state.copyWith(sending: false, sent: true),
    onFailure: (failure) => state.copyWith(sending: false, failure: failure),
  );
}
