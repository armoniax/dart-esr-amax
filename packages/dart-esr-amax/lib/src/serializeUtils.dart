import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:amaxdart/amaxdart.dart' as client;
import 'package:amaxdart_ecc/amaxdart_ecc.dart' as ecc;

import 'signing_request_json.dart';

class EOSSerializeUtils {
  late EOSNode eosNode;
  int expirationInSec;

  EOSSerializeUtils(
    String nodeURL,
    String nodeVersion, {
    this.expirationInSec = 180,
  }) {
    eosNode = EOSNode(nodeURL, nodeVersion);
  }

  //Fill the transaction with the reference block data
  Future<client.Transaction> fullFillTransaction(
    client.Transaction transaction, {
    int blocksBehind = 3,
  }) async {
    var info = await eosNode.getInfo();

    var refBlock =
        await eosNode.getBlock((info.headBlockNum! - blocksBehind).toString());

    await this._fullFill(transaction, refBlock);
    await this.serializeActions(transaction.actions ?? []);
    return transaction;
  }

  /// serialize actions in a transaction
  Future<void> serializeActions(List<client.Action> actions) async {
    for (client.Action action in actions) {
      if (action.data is String) {
        continue;
      }
      String account = action.account!;
      if (!account.isEmpty) {
        var contract = await this._getContract(account);
        action.data = this._serializeActionData(
          contract,
          account,
          action.name!,
          action.data!,
        );
      }
    }
  }

  /// Get data needed to serialize actions in a contract */
  Future<client.Contract> _getContract(String accountName) async {
    var abi = await eosNode.getRawAbi(accountName);
    var types = client.getTypesFromAbi(
      client.createInitialTypes(),
      abi.abi!,
    );
    var actions = new Map<String, client.Type>();
    for (var act in abi.abi!.actions!) {
      actions[act.name] = client.getType(types, act.type);
    }
    return client.Contract(types, actions);
  }

  /// Fill the transaction withe reference block data
  Future<void> _fullFill(
    client.Transaction transaction,
    client.Block refBlock,
  ) async {
    transaction.expiration =
        refBlock.timestamp?.add(Duration(seconds: expirationInSec));
    transaction.refBlockNum = refBlock.blockNum! & 0xffff;
    transaction.refBlockPrefix = refBlock.refBlockPrefix;
  }

  /// Convert action data to serialized form (hex) */
  String _serializeActionData(
    client.Contract contract,
    String account,
    String name,
    Object data,
  ) {
    var action = contract.actions[name];
    if (action == null) {
      throw "Unknown action $name in contract $account";
    }
    var buffer = new client.SerialBuffer(Uint8List(0));
    action.serialize!(action, buffer, data);
    return client.arrayToHex(buffer.asUint8List());
  }
}

class EOSNode {
  String _nodeURL;
  String get url => this._nodeURL;
  set url(String url) => this._nodeURL = url;

  String _nodeVersion;
  String get version => this._nodeVersion;
  set version(String url) => this._nodeVersion = version;

  EOSNode(this._nodeURL, this._nodeVersion);

  Future<dynamic> _post(String path, Object body) async {
    var uri = Uri.parse('${this.url}/${this.version}${path}');

    var response = await http.post(uri, body: json.encode(body));
    if (response.statusCode >= 300) {
      throw response.body;
    } else {
      return json.decode(response.body);
    }
  }

  /// Get EOS Node Info
  Future<client.NodeInfo> getInfo() async {
    var nodeInfo = await this._post('/chain/get_info', {});
    return client.NodeInfo.fromJson(nodeInfo);
  }

  /// Get EOS Block Info
  Future<client.Block> getBlock(String blockNumOrId) async {
    var block =
        await this._post('/chain/get_block', {'block_num_or_id': blockNumOrId});
    return client.Block.fromJson(block);
  }

  /// Get EOS raw abi from account name
  Future<client.AbiResp> getRawAbi(String accountName) async {
    return this
        ._post('/chain/get_abi', {'account_name': accountName}).then((abi) {
      return client.AbiResp.fromJson(abi);
    });
  }
}

client.PushTransactionArgs pushTransactionArgs(
  String chainId,
  client.Transaction transaction,
  bool sign,
  List<String>? privateKeys,
) {
  Map<String, client.Type> transactionTypes = client.getTypesFromAbi(
    client.createInitialTypes(),
    client.Abi.fromJson(json.decode(transactionJson)),
  );
  ;
  List<String> signatures = [];
  Map<String, ecc.AMAXPrivateKey> keys = Map();

  void _mapKeys(
    Map<String, ecc.AMAXPrivateKey> keys,
    List<String> privateKeys,
  ) {
    for (String privateKey in privateKeys) {
      ecc.AMAXPrivateKey pKey = ecc.AMAXPrivateKey.fromString(privateKey);
      String publicKey = pKey.toAMAXPublicKey().toString();
      keys[publicKey] = pKey;
    }
  }

  if (sign) {
    if (privateKeys == null) {
      throw "privateKeys can not be null";
    }
    _mapKeys(keys, privateKeys);
  }

  Uint8List serializedTrx =
      transaction.toBinary(transactionTypes['transaction']!);

  if (sign) {
    Uint8List signBuf =
        Uint8List.fromList(List.from(client.stringToHex(chainId))
          ..addAll(serializedTrx)
          ..addAll(Uint8List(32)));

    for (ecc.AMAXPrivateKey pKey in keys.values) {
      signatures.add(pKey.sign(signBuf).toString());
    }

    // for (String publicKey in requiredKeys.requiredKeys!) {
    //   ecc.AMAXPrivateKey pKey = keys[publicKey]!;
    //   signatures.add(pKey.sign(signBuf).toString());
    // }
  }

  return client.PushTransactionArgs(signatures, serializedTrx);
}
