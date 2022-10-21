import 'dart:convert';

import 'package:dart_esr_amax/src/models/signing_request.dart';
import 'package:dart_esr_amax/dart_esr_amax.dart';
import 'package:amaxdart/amaxdart.dart' as Client;
import 'package:dart_session_manager/src/abi.dart';

class AnchorLinkSessionManagerSession {
  String chainId;
  dynamic actor;
  dynamic permission;
  String publicKey;
  dynamic name;
  DateTime? created;
  DateTime? lastUsed;
  AnchorLinkSessionManagerSession(
    this.chainId,
    this.actor,
    this.permission,
    this.publicKey,
    this.name, {
    this.created,
    this.lastUsed,
  });
  updateLastUsed(DateTime time) {
    lastUsed = time;
  }

  String serialize() {
    return json.encode({
      "chainId": chainId,
      "permission": permission,
      "publicKey": publicKey,
      "name": name,
      "created": created?.toIso8601String(),
      "lastUsed": lastUsed?.toIso8601String(),
    });
  }

  AnchorLinkSessionManagerSession unserialize(String str) {
    var item = json.decode(str);
    return AnchorLinkSessionManagerSession(
      item['chainId'],
      item['actor'],
      item['permission'],
      item['publicKey'],
      item['name'],
      created: item['created'],
      lastUsed: item['lastUsed'],
    );
  }

  static AnchorLinkSessionManagerSession fromIdentityRequest(
    network,
    chainId,
    actor,
    permission,
    String payload,
  ) {
    EOSIOSigningrequest esr = EOSIOSigningrequest(
      network.toString(),
      'v1',
      chainId: chainId,
    );

    SigningRequest request = esr.deserialize(payload);

    if (!esr.isIdentity()) {
      throw 'supplied request is not an identity request';
    }

    var abi = Client.getTypesFromAbi(
      Client.createInitialTypes(),
      Client.Abi.fromJson(
        json.decode(AbiString),
      ),
    );

    var type = abi['link_create'];

    var linkInfo = esr.getInfoKey(
      'link',
      type: type,
    );

    if (linkInfo == null ||
        linkInfo['request_key'] == null ||
        linkInfo['session_name'] == null) {
      throw 'identity request does not contain link information';
    }

    return AnchorLinkSessionManagerSession(
      chainId,
      actor,
      permission,
      linkInfo['request_key'],
      linkInfo['session_name'],
    );
  }

  /// TODO:
  // static AnchorLinkSessionManagerSession fromLoginResult(result) {
  //   return return AnchorLinkSessionManagerSession(
  //     network,
  //     actor,
  //     permission,
  //     linkInfo['request_key'],
  //     linkInfo['session_name'],
  //   );
  // }
}
