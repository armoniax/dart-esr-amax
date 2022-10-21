import 'dart:io';

class Options {
  /// The buoy channel to listen to, minimum 10 chars, usually a uuid string. */
  String channel;

  /// The buoy service url, e.g. 'https://cb.anchor.link'. */
  String service;

  Options(
    this.service,
    this.channel,
  );
}

class SendOptions extends Options {
  int? timeout;
  bool? requireDelivery;
  @override
  late String channel;
  @override
  late String service;
  SendOptions(
    this.service,
    this.channel, {
    this.requireDelivery,
    this.timeout,
  }) : super(
          service,
          channel,
        );
}

class ReceiveContext {
  late Function cancel;

  /// Can be called by sender to cancel the receive. */
  ReceiveContext(this.cancel);
}

enum ListenerEncoding {
  binary,
  text,
  json,
}

class ListenerOptions extends Options {
  bool? autoConnect = true;
  bool? json;
  ListenerEncoding? encoding;
  WebSocket? webSocket;
  @override
  late String channel;
  @override
  late String service;
  ListenerOptions(
    this.service,
    this.channel, {
    this.encoding,
    this.webSocket,
    this.autoConnect,
    this.json,
  }) : super(
          service,
          channel,
        );
}

// class ReceiveContext {
//   late Function cancel;
//     /// Can be called by sender to cancel the receive. */
//     ReceiveContext(this.cancel);
// }

class ReceiveOptions extends ListenerOptions {
  int? timeout;
  @override
  late String channel;
  @override
  late String service;
  ReceiveOptions(
    this.service,
    this.channel, {
    this.timeout,
  }) : super(
          service,
          channel,
        );
}

enum EventTypes {
  message,
  error,
  open,
  closing,
  closed,
  connecting,
  done,
  disconnect,
}

// export interface ReceiveOptions extends ListenerOptions {
//     /** How many milliseconds to wait before giving up. */
//     timeout?: number
// }
