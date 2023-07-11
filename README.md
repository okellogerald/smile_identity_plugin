# smile_identity_plugin

A new Flutter plugin project.

## Getting Started

### Android Set-up

> Add `smile_config.json` file in android/app folder

#### In `android/app/build.gradle`

1. Add `apply plugin: 'com.smileidentity.smile-id-android'`
2. Add the following dependecies:

```gradle
dependecies {
    ...
    implementation 'com.smileidentity:smile-id-sdk:7.3.27'
    implementation 'com.smileidentity:smile-id-ui:1.0.10'
    implementation 'com.smileidentity:netjava:1.0.4'
}
```

3. Add the following packaging options

```gradle
packagingOptions {
    exclude 'META-INF/androidx.*'
    exclude 'androidx.*'
    exclude 'META-INF/DEPENDENCIES'
}
```

4. The `minSdkVersion` should be atleast 19

#### In `android/build.gradle`

1. Add the following in the `buildscript` section

```gradle
buildscript {
    dependencies {
        ...
        classpath 'com.smileidentity:smile-id-android:1.0.1'
    }

    repositories {
        ...
        maven { url 'https://oss.sonatype.org/content/repositories/snapshots' }
    }

}
```

### iOS Set-up

#### In your `ios/Runner` folder:

> Add your `smile_config.json` file

> Set `NSCameraUsageDescription` in your `info.plist` file
> Example:

```xml
	<key>NSCameraUsageDescription</key>
	<string>Using Camera for Smile Identity</string>
```

> In your `ios/Runner/Podfile` file, add the following pods:

```Swift
target 'Runner' do
  ...

  pod 'Smile_Identity_SDK'
  pod 'MaterialComponents/Snackbar'

  ...
end

```

> Set `platform :ios, '13.0'`
