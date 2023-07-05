# smile_identity_plugin

A new Flutter plugin project.

## Getting Started

> Add `smile_config.json` file in android/app folder

</br>

### In `android/app/build.gradle`

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

</br>

### In `android/build.gradle`

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
