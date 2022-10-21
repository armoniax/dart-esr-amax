// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:dart_esr_amax/dart_esr_amax.dart';
import 'package:dart_esr_amax/src/signing_request_json.dart';

import 'package:dart_esr_amax/src/utils/base64u.dart';

import 'package:dart_esr_amax/src/models/signing_request.dart';

import 'package:amaxdart/amaxdart.dart' as Client;

import 'models/resolved_callback.dart';

/**
 * The callback payload sent to background callbacks.
 */
// class CallbackPayload {
//   // /** The first signature. */
//   late String sig;
//   /** Transaction ID as HEX-encoded string. */
//   late String tx;
//   /** Block number hint (only present if transaction was broadcast). */
//   late String bn;
//   /** Signer authority, aka account name. */
//   late String sa;
//   /** Signer permission, e.g. "active". */
//   late String sp;
//   /** Reference block num used when resolving request. */
//   late String rbn;
//   /** Reference block id used when resolving request. */
//   late String rid;
//   /** The originating signing request packed as a uri string. */
//   late String req;
//   /** Expiration time used when resolving request. */
//   late String ex;
//   /** The resolved chain id.  */
//   late String cid;
//   /** All signatures 0-indexed as `sig0`, `sig1`, etc. */
//   List<String> sigX = [];
// }

/// Context used to resolve a callback.
/// Compatible with the JSON response from a `push_transaction` call.
// class ResolvedCallback {
//   /** The URL to hit. */
//   late String url;
//   /**
//      * Whether to run the request in the background. For a https url this
//      * means POST in the background instead of a GET redirect.
//      */
//   late bool background;
//   /**
//      * The callback payload as a object that should be encoded to JSON
//      * and POSTed to background callbacks.
//      */
//   late CallbackPayload payload;
// }

class EOSIOSigningrequest {
  late EOSSerializeUtils _Client;
  late Map<int, Map<String, Client.Type>> _signingRequestTypes;
  late SigningRequest _signingRequest;
  late Uint8List _request;
  late int _version;
  late String _esrURI;
  late Client.Transaction _resolveTransaction;

  EOSIOSigningrequest(
    String nodeUrl,
    String nodeVersion, {
    String? chainId,
    ChainName? chainName,
    int? flags = 1,
    String? callback = '',
    List? info,
    int? version = 2,
  }) {
    _signingRequest = SigningRequest();
    _Client = EOSSerializeUtils(nodeUrl, nodeVersion);

    _signingRequestTypes = {
      2: Client.getTypesFromAbi(
        Client.createInitialTypes(),
        Client.Abi.fromJson(
          json.decode(signingRequestJsonV2),
        ),
      ),
      3: Client.getTypesFromAbi(
        Client.createInitialTypes(),
        Client.Abi.fromJson(
          json.decode(signingRequestJsonV3),
        ),
      )
    };

    setChainId(chainName: chainName, chainId: chainId);
    setOtherFields(flags: flags, callback: callback, info: info ?? []);
    _version = version!;
  }

  void setNode(String nodeUrl, String nodeVersion) {
    _Client = EOSSerializeUtils(nodeUrl, nodeVersion);
  }

  void setChainId({ChainName? chainName, String? chainId}) {
    if (chainName != null) {
      _signingRequest.chainId = [
        'chain_alias',
        ESRConstants.getChainAlias(chainName)
      ];
      return;
    } else if (chainId != null) {
      _signingRequest.chainId = ['chain_id', chainId];
      return;
    } else {
      throw 'Either "ChainName" or "ChainId" must be set';
    }
  }

  String? getChainId() {
    List chainId = _signingRequest.chainId;
    if (chainId[0] == 'chain_alias') {
      return ESRConstants.ChainIdLookup[ChainName.values[chainId[1]]];
    } else if (chainId[0] == 'chain_id') {
      return chainId[1];
    }
    return '';
  }

  void setOtherFields({int? flags, String? callback, List? info}) {
    _signingRequest.flags = flags!;
    _signingRequest.callback = callback!;
    _signingRequest.info = info!;
  }

  Future<String> encodeTransaction(Client.Transaction transaction) async {
    await _Client.fullFillTransaction(transaction);
    if (_signingRequest.req[0] == 'identity') {
      transaction.refBlockNum = 0;
      transaction.refBlockPrefix = 0;
    }
    _signingRequest.req = ['transaction', transaction.toJson()];
    return _encode();
  }

  bool isIdentity() {
    return _signingRequest.req[0] == 'identity';
  }

  Future<String> encodeAction(Client.Action action) async {
    _Client.serializeActions([action]);
    _signingRequest.req = ['action', action.toJson()];
    return _encode();
  }

  Future<String> encodeActions(List<Client.Action> actions) async {
    _Client.serializeActions(actions);
    var jsonAction = [];
    for (var action in actions) {
      jsonAction.add(action.toJson());
    }
    _signingRequest.req = ['action[]', jsonAction];
    return _encode();
  }

  Future<String> encodeIdentity(Identity identity) async {
    if (identity is IdentityV3) {
      _version = 3;
    }
    _signingRequest.req = ['identity', identity.toJson()];
    _signingRequest.flags = 0;
    return _encode();
  }

  Future<String> _encode() async {
    _request = _signingRequest
        .toBinary(_signingRequestTypes[_version]!['signing_request']!);

    _compressRequest();
    _addVersionHeaderToRequest();

    return _requestToBase64();
  }

  void decode(String encodedRequest) {
    var request = '';
    if (encodedRequest.startsWith('esr://')) {
      request = encodedRequest.substring(6);
    } else if (encodedRequest.startsWith('esr:')) {
      request = encodedRequest.substring(4);
    } else {
      throw 'Invalid encoded EOSIO signing request';
    }

    var decoded = Base64u().decode(request);
    var header = decoded[0];
    _version = header & ~(1 << 7);
    var list = Uint8List(decoded.length - 1);

    list = decoded.sublist(1);
    var decompressed = ZLibCodec(raw: true).decode(list);

    _signingRequest = SigningRequest.fromBinary(
      _signingRequestTypes[_version]!['signing_request']!,
      decompressed as Uint8List,
    );
  }

  SigningRequest deserialize(String encodedRequest) {
    _esrURI = encodedRequest;
    decode(encodedRequest);
    return _signingRequest;
  }

  getRawInfoKey(String key) {
    List<dynamic> info = _signingRequest.info;
    dynamic infoPair = info.firstWhere(
      (element) => element['key'] == key,
      orElse: () => null,
    );
    if (infoPair == null) {
      throw '$key does not exist';
    }
    return infoPair['value'];
  }

  getInfoKey(
    String key, {
    Type? type,
  }) {
    String data = getRawInfoKey(key);
    Uint8List list = hexToUint8List(data);
    if (type != null) {
      var buffer = Client.SerialBuffer(list);
      var message = type.deserialize!(type, buffer);
      return message;
    } else {
      return utf8.decode(
        list,
        allowMalformed: true,
      );
    }
  }

  List<Client.Action> getRawActions({Client.Authorization? authorization}) {
    var req = _signingRequest.req;
    List<Client.Action> actions = [];
    switch (req[0]) {
      case 'action':
        {}
        break;
      case 'action[]':
        {}
        break;
      case 'identity':
        {
          dynamic permission = req[1]['permission'];
          if (permission == null ||
              permission['actor'] == ESRConstants.PlaceholderName ||
              permission['permission'] == ESRConstants.PlaceholderPermission) {
            permission = authorization!.toJson();
          }

          var auth = toMap(permission);

          var identityPermission = IdentityPermission.fromJson(auth);

          Identity? identity;
          if (_version == 2) {
            identity = IdentityV2()..identityPermission = identityPermission;
          } else if (_version == 3) {
            identity = IdentityV3(req[1]['scope'])
              ..identityPermission = identityPermission;
          }
          var data =
              identity!.toBinary(_signingRequestTypes[_version]!['identity']!);

          actions = [
            Client.Action()
              ..account = ''
              ..name = 'identity'
              ..authorization = [Client.Authorization.fromJson(auth)]
              // ..authorization = [authorization]
              ..data = data
          ];
        }
        break;
      default:
        throw 'Invalid signing request data';
    }
    return actions;
  }

  toMap(e) {
    return json.decode(json.encode(e));
  }

  Client.Transaction getRawTransaction({
    Client.Authorization? authorization,
  }) {
    List req = _signingRequest.req;
    switch (req[0]) {
      case 'transaction':
        return Client.Transaction.fromJson(toMap(req[1]));
      case 'action':
        return Client.Transaction()
          ..actions = [Client.Action.fromJson(toMap(req[1]))];
      case 'action[]':
        return Client.Transaction()
          ..actions = (req[1] as List).map<Action>((e) {
            return Client.Action.fromJson(toMap(e));
          }).toList();
      case 'identity':
        return Client.Transaction()
          ..actions = getRawActions(authorization: authorization);
      default:
        throw 'Invalid signing request data';
    }
  }

  List<Client.Action> resolveActions() {
    checkSigningRequest();
    Client.Transaction transaction = resolve();
    List<Client.Action> actions = transaction.actions ?? [];
    return actions;
  }

  Client.Authorization resolveAuthorization() {
    checkSigningRequest();
    Client.Transaction transaction = resolve();
    List<Client.Action> actions = transaction.actions ?? [];
    return actions[0].authorization![0];
  }

  Client.Transaction resolveTransaction({Client.Authorization? authorization}) {
    var transaction = getRawTransaction(authorization: authorization);
    // var actions = resolveAction(type, authorization, transaction.actions);
    // return transaction..actions = actions;
    return transaction;
  }

  void checkSigningRequest() {
    if (_signingRequest == null)
      throw 'Must decode signing request before resolve it!';
  }

  Client.Transaction resolve({Client.Authorization? authorization}) {
    checkSigningRequest();
    return resolveTransaction(authorization: authorization);
    // var resolveTransaction = getRawTransaction(_signingRequest, authorization);
  }

  ResolvedCallback getCallback(
    String tx,
    String req, {
    String? sig,
  }) {
    checkSigningRequest();
    Client.Transaction transaction = resolve();
    Client.Authorization authorization = resolveAuthorization();
    return ResolvedCallback(
      url: _signingRequest.callback,
      background: _signingRequest.background,
      payload: Payload(
        sig: sig ?? transaction.signatures.toString(),
        tx: tx,
        rbn: transaction.refBlockNum.toString(),
        rid: transaction.refBlockPrefix.toString(),
        ex: transaction.expiration!.toLocal().toIso8601String(),
        req: req,
        sa: authorization.actor ?? '',
        sp: authorization.permission ?? '',
        cid: getChainId() ?? '',
        linkCh: "",
        linkKey: "",
        linkName: "",
        linkMeta: LinkMeta(launchUrl: ''),
        // sigX: [],
      ),
    );
  }

  void _compressRequest() {
    var encoded = ZLibCodec(raw: true).encode(_request);
    _request = Uint8List.fromList(encoded);
  }

  void _addVersionHeaderToRequest() {
    var list = Uint8List(_request.length + 1);
    list[0] = _version | 1 << 7;
    for (int i = 1; i < list.length; i++) {
      list[i] = _request[i - 1];
    }
    _request = list;
  }

  String _requestToBase64() {
    var encoded = Base64u().encode(Uint8List.fromList(_request));
    return '${ESRConstants.Scheme}//$encoded';
  }
}
