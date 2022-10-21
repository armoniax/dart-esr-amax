import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../dart_buoy.dart';

class Listener {
  late ListenerOptions options;
  late String baseUrl;
  late String url;
  late ListenerEncoding encoding;
  late WebSocket webSocket;
  bool active = false;
  Map<EventTypes, Function> events = {};
  Listener(this.options) {
    baseUrl = options.service.replaceFirst('http', 'ws');
    url = "$baseUrl/${options.channel}";
    encoding = options.encoding ?? ListenerEncoding.text;
    if (options.autoConnect == true) {
      connect();
    }
  }
  callback(EventTypes type, {dynamic payload}) {
    if (events[type] != null) {
      if (payload != null) {
        events[type]!(payload);
      } else {
        events[type]!();
      }
    }
  }

  Uint8List hexToUint8List(String hex) {
    if (hex.length % 2 != 0) {
      throw 'Odd number of hex digits';
    }
    var l = hex.length ~/ 2;
    var result = Uint8List(l);
    for (var i = 0; i < l; ++i) {
      var x = int.parse(hex.substring(i * 2, (2 * (i + 1))), radix: 16);
      if (x.isNaN) {
        throw 'Expected hex string';
      }
      result[i] = x;
    }
    return result;
  }

  String uint8ArrayToString(list) {
    String str = utf8.decode(
      list,
      allowMalformed: true,
    );
    return str;
  }

  connect() async {
    if (active) return;
    active = true;
    webSocket = await WebSocket.connect(url);
    webSocket.listen(
      (event) {
        callback(
          EventTypes.message,
          payload: event,
        );
      },
      onError: events[EventTypes.error],
      onDone: () {
        callback(EventTypes.done);
      },
    );

    switch (webSocket.readyState) {
      case WebSocket.open:
        callback(EventTypes.open);
        break;
      case WebSocket.closed:
        callback(EventTypes.closed);
        break;
      case WebSocket.closing:
        callback(EventTypes.closing);
        break;
      case WebSocket.connecting:
        callback(EventTypes.connecting);
        break;
      default:
    }
  }

  on(EventTypes type, Function callback) {
    events[type] = callback;
  }

  disconnect() {
    active = false;
    if (webSocket.readyState == WebSocket.open ||
        webSocket.readyState == WebSocket.connecting) {
      webSocket.close();
      if (events[EventTypes.disconnect] != null) {
        events[EventTypes.disconnect]!();
      }
    }
  }

  bool get isConnected {
    return active && webSocket.readyState == WebSocket.open;
  }
}
