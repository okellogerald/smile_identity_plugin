import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_state.freezed.dart';

@freezed
class SubmitState with _$SubmitState {
  const SubmitState._();

  const factory SubmitState.none() = _None;

  const factory SubmitState.submitting() = _Submitting;

  const factory SubmitState.submitted() = _Submitted;

  const factory SubmitState.error(String error) = _Error;

  bool get isNone {
    return maybeWhen(
      none: () => true,
      orElse: () => false,
    );
  }

  bool get didSubmitSuccessfully {
    return maybeWhen(
      submitted: () => true,
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
