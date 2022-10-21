import 'dart:async';

import 'package:dart_buoy/dart_buoy.dart';

Future receive(ReceiveOptions options, {ReceiveContext? ctx}) {
  final com = Completer();
  final future = com.future;

  Listener listener = Listener(options);

  done({dynamic message, Error? error}) {
    if (error != null) {
      com.completeError(error);
    } else if (message != null) {
      com.complete(message);
    }
    listener.disconnect();
  }

  listener.on(EventTypes.message, (event) {
    done(message: event);
  });

  listener.on(EventTypes.error, (event) {
    done(error: event);
  });

  return future;
}
