// =============================================
// core/utils/firestore_stream_error.dart
// Shared onError handler for Firestore .snapshots() listeners.
//
// When a user signs out, the auth token is revoked before every active
// listener has been cancelled. Firestore pushes a permission-denied
// error into each stream that is still open. That is expected churn,
// not a crash — but without an onError the error escapes to
// FlutterError.onError, which main.dart forwards to
// recordFlutterFatalError, so Crashlytics logs it as a fatal
// [cloud_firestore/permission-denied].
//
// Anything else is genuinely unexpected, so it is recorded as a
// NON-fatal: still visible in Crashlytics, without dragging down the
// crash-free-users metric.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

void handleFirestoreStreamError(
  String source,
  Object error,
  StackTrace stack,
) {
  if (error is FirebaseException && error.code == 'permission-denied') {
    debugPrint('$source: listener closed by sign-out (permission-denied)');
    return;
  }
  debugPrint('$source: $error');
  FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: 'Firestore stream error in $source',
    fatal: false,
  );
}
