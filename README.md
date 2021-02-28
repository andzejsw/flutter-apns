# apns

[flutter_apns](https://github.com/mwaylabs/flutter-apns) fork without any `firebase_messaging` dependencies, bringing you APNS push notifications on iOS while allowing you to use (or not) any version of `firebase_messaging`.

## Why this plugin was made?

Original `flutter-apns` extends and use `firebase_messaging` but is no more compatible with its 8+ version. This plugin doesn't extends it so you're free to use it on iOS without `firebase_messaging` or while having your own `firebase_messaging` setup.

## Usage
1. On iOS, make sure you have correctly configured your app to support push notifications, and that you have generated certificate/token for sending pushes.
2. Add the following lines to the `didFinishLaunchingWithOptions` method in the AppDelegate.m/AppDelegate.swift file of your iOS project

Objective-C:
```objc
if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
```

Swift:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

3. Add `flutter_apns` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
4. Using `createPushConnector()` method, configure push service according to your needs. `PushConnector` closely resembles `FirebaseMessaging`, so Firebase samples may be useful during implementation. You should create the connector as soon as possible to get the onLaunch callback working on closed app launch.
```dart
import 'package:flutter_apns/apns.dart';

final connector = createPushConnector();
connector.configure(
    onLaunch: _onLaunch,
    onResume: _onResume,
    onMessage: _onMessage,
);
connector.requestNotificationPermissions()
```
5. Build on device and test your solution using Firebase Console and NWPusher app.

## Additional APNS features:
### Displaying notification while in foreground

```dart
final connector = createPushConnector();
if (connector is ApnsPushConnector) {
  connector.shouldPresent = (x) => Future.value(true);
}
```

### Handling predefined actions

Firstly, configure supported actions:
```dart
final connector = createPushConnector();
if (connector is ApnsPushConnector) {
  connector.setNotificationCategories([
    UNNotificationCategory(
      identifier: 'MEETING_INVITATION',
      actions: [
        UNNotificationAction(
          identifier: 'ACCEPT_ACTION',
          title: 'Accept',
          options: [],
        ),
        UNNotificationAction(
          identifier: 'DECLINE_ACTION',
          title: 'Decline',
          options: [],
        ),
      ],
      intentIdentifiers: [],
      options: [],
    ),
  ]);
}
```

Then, handle possible actions in your push handler:
```dart
Future<dynamic> onPush(String name, Map<String, dynamic> payload) {
  storage.append('$name: $payload');

  final action = UNNotificationAction.getIdentifier(payload);

  if (action == 'MEETING_INVITATION') {
    // do something
  }

  return Future.value(true);
}
```

Note: if user clickes your notification while app is in the background, push will be delivered through onResume without actually waking up the app. Make sure your handling of given action is quick and error free, as execution time in for apps running in the background is very limited.

Check the example project for fully working code.

## Troubleshooting

1. Ensure that you are testing on actual device. NOTE: this may not be needed from 11.4: https://ohmyswift.com/blog/2020/02/13/simulating-remote-push-notifications-in-a-simulator/
2. If onToken method is not being called, add error logging to your AppDelegate, see code below.
3. Open Console app for macOS, connect your device, and run your app. Search for "PUSH registration failed" string in logs. The error message will tell you what was wrong.

*swift*
```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
     NSLog("PUSH registration failed: \(error)")
  }
}

```

*objc*
```objc
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
```
