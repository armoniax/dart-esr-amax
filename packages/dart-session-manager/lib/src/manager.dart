import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_buoy/dart_buoy.dart';
import 'package:uuid/uuid.dart';
import 'package:amaxdart_ecc/amaxdart_ecc.dart';
import 'package:amaxdart/amaxdart.dart' as Client;

import '../dart_session_manager.dart';

var uuid = Uuid();

class AnchorLinkSessionManagerEventHander {
  Function(String payload) onIncomingRequest;
  Function(String storage) onStorageUpdate;
  Function(String type, dynamic event) onSocketEvent;
  AnchorLinkSessionManagerEventHander({
    required this.onIncomingRequest,
    required this.onStorageUpdate,
    required this.onSocketEvent,
  });
}

String generateK1() {
  var privateKey = AMAXPrivateKey.fromRandom();
  privateKey.format = 'WIF';
  privateKey.keyType = 'K1';
  return privateKey.toString();
}

class AnchorLinkSessionManager {
  AnchorLinkSessionManagerEventHander handler;
  dynamic fetch;
  late Listener listener;
  String? linkUrl;
  late ListenerOptions listenerOptions;
  late AnchorLinkSessionManagerStorage storage;
  late WebSocket webSocket;

  AnchorLinkSessionManager(
    this.handler, {
    this.fetch,
    this.linkUrl = 'fwd.aplink.app',
    AnchorLinkSessionManagerStorage? sessionStorage,
    WebSocket? socket,
  }) {
    sessionStorage ??= AnchorLinkSessionManagerStorage(
      uuid.v4(),
      linkUrl as String,
      generateK1(),
      [],
    );

    handler.onStorageUpdate(sessionStorage.serialize());

    storage = sessionStorage;

    listenerOptions = ListenerOptions(
      "https://${storage.linkUrl}",
      storage.linkId,
      autoConnect: false,
    );

    listener = setupListener();
  }

  updateLastUsed(String publicKey) {
    storage.updateLastUsed(publicKey);
    handler.onStorageUpdate(storage.serialize());
  }

  AnchorLinkSessionManagerSession? getSession(
    String chainId,
    String account,
    String permission,
  ) {
    return storage.get(
      chainId,
      account,
      permission,
    );
  }

  clearSessions() {
    storage.clear();
    handler.onStorageUpdate(storage.serialize());
  }

  removeSession(AnchorLinkSessionManagerSession session) {
    storage.remove(session);
    handler.onStorageUpdate(storage.serialize());
  }

  save() {
    handler.onStorageUpdate(storage.serialize());
  }

  addSession(AnchorLinkSessionManagerSession session) {
    storage.add(session);
    handler.onStorageUpdate(storage.serialize());
  }

  Future<void> connect() async {
    await listener.connect();
  }

  disconnect() {
    listener.disconnect();
  }

  setupListener() {
    listener = Listener(listenerOptions);

    listener.on(EventTypes.open, () {
      try {
        handler.onSocketEvent('onopen', {});
      } catch (e) {
        // throw 'SessionManager on:connect exception';
      }
    });

    listener.on(EventTypes.disconnect, () {
      try {
        handler.onSocketEvent('onclose', {});
      } catch (e) {
        // throw 'SessionManager on:disconnect exception';
      }
    });

    listener.on(EventTypes.message, (message) {
      handler.onSocketEvent('onmessage', message);
      handleRequest(message);
    });

    listener.on(EventTypes.error, (error) {
      try {
        handler.onSocketEvent('onerror', error);
      } catch (e) {
        // throw 'SessionManager on:disconnect exception';
      }
    });

    return listener;
  }

  String handleRequest(encoded) {
    var abi = Client.getTypesFromAbi(
      Client.createInitialTypes(),
      Client.Abi.fromJson(
        json.decode(AbiString),
      ),
    );

    var type = abi['sealed_message'];
    List<int> msg =
        ((encoded is String ? json.decode(encoded) : encoded) as List<dynamic>)
            .cast<int>();
    Uint8List list = Uint8List.fromList(msg);
    var buffer = Client.SerialBuffer(list);
    var message = type!.deserialize!(type, buffer);

    String unsealed = unsealMessage(
      message['ciphertext'],
      // AMAXPrivateKey.fromString(storage.requestKey),
      // "PVT_K1_qRGCEjgvrf5GA55L5r6ajXj4GeHrpuSSmQMYhMTM2XGqMNTqT",
      storage.requestKey,
      message['from'],
      message['nonce'],
    );

    if (!storage.has(message['from'])) {
      throw 'Unknown session using ${message['from']}';
    }

    updateLastUsed(message['from']);
    handler.onIncomingRequest(unsealed);
    return unsealed;
  }

  bool get ready {
    return listener.isConnected;
  }
}
