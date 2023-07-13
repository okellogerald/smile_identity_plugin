import 'package:smile_identity_plugin/models/capture_state.dart';
import 'package:smile_identity_plugin/models/submit_state.dart';

import 'smile_data.dart';

class SmileState {
  final CaptureState captureState;
  final SubmitState submitState;
  final SmileData? data;

  const SmileState({
    this.captureState = const CaptureState.none(),
    this.submitState = const SubmitState.none(),
    this.data,
  });

  SmileState copyWith({
    CaptureState? captureState,
    SubmitState? submitState,
    SmileData? data,
  }) {
    return SmileState(
      captureState: captureState ?? this.captureState,
      submitState: submitState ?? this.submitState,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(covariant SmileState other) {
    if (identical(this, other)) return true;

    return other.captureState == captureState &&
        other.submitState == submitState &&
        other.data == data;
  }

  @override
  int get hashCode =>
      captureState.hashCode ^ submitState.hashCode ^ data.hashCode;

  @override
  String toString() =>
      'SmileState(captureState: $captureState, submitState: $submitState, data: $data)';
}
