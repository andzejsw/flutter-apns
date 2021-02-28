import 'package:flutter_apns/src/apns_connector.dart';
import 'package:flutter_apns/src/connector.dart';

export 'package:flutter_apns/src/apns_connector.dart';
export 'package:flutter_apns/src/connector.dart';

/// Creates APNS connector to manage the push notification registration.
PushConnector createPushConnector() {
  return ApnsPushConnector();
}
