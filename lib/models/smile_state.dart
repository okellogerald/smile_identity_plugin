
import 'smile_data.dart';

class SmileState {
  final bool captured;
  final bool submitted;
  final SmileData? data;

  const SmileState({
    this.captured = false,
    this.submitted = false,
    this.data,
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
    );
  }
}
