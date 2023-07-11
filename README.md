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

> Add `smile_config.json` file in ios/Runner folder

#### In your `ios/Runner/Podfile` file

> Add the following pods:

```Swift
target 'Runner' do
  # use_frameworks!
  use_modular_headers!

  # pods to add
  pod 'Smile_Identity_SDK'
  pod 'MaterialComponents/Snackbar'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

```

> Set `platform :ios, '13.0'`
