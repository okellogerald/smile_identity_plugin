import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture_state.freezed.dart';

@freezed
sealed class CaptureState with _$CaptureState {
  const CaptureState._();

  const factory CaptureState.none() = _None;

  const factory CaptureState.capturing() = _Capturing;

  const factory CaptureState.captured() = _Captured;

  const factory CaptureState.error(String error) = _Error;

  bool get didCaptureSuccessfully {
    return maybeWhen(
      captured: () => true,
      orElse: () => false,
    );
  }

  String? get error {
    return maybeWhen(
      error: (error) => error,
      orElse: () => null,
    );
  }
}
