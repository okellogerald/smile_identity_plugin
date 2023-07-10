import 'smile_data.dart';

class SmileState {
  final bool captured;
  final bool submitted;
  final SmileData? data;
  final String? error;

  const SmileState({
    this.captured = false,
    this.submitted = false,
    this.data,
    this.error,
  });

  SmileState copyWith({
    bool? captured,
    bool? submitted,
    SmileData? data,
  }) {
    return SmileState(
      captured: captured ?? this.captured,
      submitted: submitted ?? this.submitted,
      data: data ?? this.data,
      error: error,
    );
  }

  bool get hasError => error != null;

  SmileState addError(String error) {
    return SmileState(
      captured: captured,
      submitted: submitted,
      data: data,
      error: error,
    );
  }
}
