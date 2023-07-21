# smile_identity_plugin

Wraps official iOS and Android SmileIdentity SDKs.

## Set-up

### Android Set-up

Please visit this [link](https://docs.usesmileid.com/integration-options/mobile/flutter/android-setup) to set up Smile Identity for Android.

While setting up for Android, make sure to:

1. Set `minSdkVersion` to be at-least 19 
2. In `android/src/main/kotlin/com/{packageName}/MainActivity.kt` extend `SmileidentityMainActivity`

Example:
```kotlin
package com.example.example

import com.tembo_plus.smile_identity_plugin.SmileIdentityMainActivity
import io.flutter.embedding.android.FlutterActivity

class MainActivity: SmileIdentityMainActivity() {

}
```
</br>

### iOS Set-up
Please visit this [link](https://docs.usesmileid.com/integration-options/mobile/ios) to set up Smile Identity for iOS.

While setting up for iOS, make sure to:
1. Set `NSCameraUsageDescription` in your project's `info.plist` file

Example:
```xml
 <key>NSCameraUsageDescription</key>
 <string>Using Camera for Smile Identity</string>
```

2. Add the following pods In your `Podfile`:

```Swift
target 'Runner' do
  ...

  pod 'Smile_Identity_SDK'
  pod 'MaterialComponents/Snackbar'

  ...
end

```

3. Set the platform version to be at-least 13

## Getting Started

1. Collect user data and create a `SmileData` object.

Example
```dart
final data = SmileData(
    firstName: "John",
    lastName: "Smith",
    country: "KE",
    idType: "NATIONAL_ID",
    idNumber: "00000000",
    userId: "specific-user-id",
    jobType: 1,
    captureType: CaptureType.selfieAndIdCapture,
)
```

2. Start the Smile Identity verification process by calling the `capture` method

Example
```dart
final smileIdentity = SmileIdentityPlugin()
smileIdentity.capture(data)
```
By default the plugin handles camera permissions for each platform. You may disable this by setting the `capture` method `handleCameraPermission` parameter to `false`
```dart
smileIdentity.capture(data, handleCameraPermission: false)
```


3. Handle states

The entire process involves two steps: Capturing and Submitting. Hence all possible states are categorized into two groups namely `CaptureState` and `SubmitState`.

NB: After capturing necessary images, the plugin will automatically initiate the submission phase.

```dart
@freezed
sealed class CaptureState with _$CaptureState {
  const CaptureState._();

  // Have not started capturing images yet
  const factory CaptureState.none() = _None;

  const factory CaptureState.capturing() = _Capturing;

  // Captured images successfully
  const factory CaptureState.captured() = _Captured;

  // An error happened while capturing images
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


@freezed
sealed class SubmitState with _$SubmitState {
  const SubmitState._();

  // Have not started submitting data yet
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

  // An error happened while submitting data
  String? get error {
    return maybeWhen(
      error: (error) => error,
      orElse: () => null,
    );
  }
}

```

If the entire process goes successfully, this will be the states progression: CaptureState.none, SubmitState.none -> CaptureState.capturing, SubmitState.none -> CaptureState.captured, SubmitState.none -> CaptureState.captured, SubmitState.submitting -> CaptureState.captured, SubmitState.submitted 

The plugin, however, exposes `SmileState` stream having both `CaptureState`, `SubmitState` as well as `SmileData` as properties.
```dart
class SmileState {
  final CaptureState captureState;
  final SubmitState submitState;
  final SmileData? data;

  const SmileState({
    this.captureState = const CaptureState.none(),
    this.submitState = const SubmitState.none(),
    this.data,
  });
}
```

Subscribe to a stream of `SmileState`s and handle the states however you want.

Example
```dart
smilePlugin.onStateChanged.listen((event) {
    // code here
})
```
