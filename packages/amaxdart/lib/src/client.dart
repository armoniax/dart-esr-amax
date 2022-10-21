import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:amaxdart_ecc/amaxdart_ecc.dart' as ecc;
import 'package:common_utils/common_utils.dart';
import 'package:http/http.dart' as http;

import '../amaxdart.dart';
import 'jsons.dart';
import 'serialize.dart' as ser;

/// AMAXClient calls APIs against given AMAX nodes
class AMAXClient {
  final String _nodeURL;
  final String _version;
  late int expirationInSec;

  // Map<String, ecc.AMAXPrivateKey> keys = Map();

  /// Converts abi files between binary and structured form (`abi.abi.json`) */
  late Map<String, Type> abiTypes;
  late Map<String, Type> transactionTypes;
  String? chainId;

  /// Construct the AMAX client from AMAX node URL
  AMAXClient(
    this._nodeURL,
    this._version, {
    this.expirationInSec = 180,
  }) {
    //_mapKeys(privateKeys);

    abiTypes = ser.getTypesFromAbi(
        ser.createInitialTypes(), Abi.fromJson(json.decode(abiJson)));
    transactionTypes = ser.getTypesFromAbi(
        ser.createInitialTypes(), Abi.fromJson(json.decode(transactionJson)));
  }

  String get nodeURL => _nodeURL;

  /// Sets private keys. Required to sign transactions.
  void _mapKeys(
      Map<String, ecc.AMAXPrivateKey> keys, List<String> privateKeys) {
    for (String privateKey in privateKeys) {
      ecc.AMAXPrivateKey pKey = ecc.AMAXPrivateKey.fromString(privateKey);
      String publicKey = pKey.toAMAXPublicKey().toString();
      keys[publicKey] = pKey;
    }
  }

  // set privateKeys(List<String> privateKeys) => _mapKeys(privateKeys);

  Future _post(String path, Object body, {int httpTimeout = 20}) async {
    Completer completer = Completer();
    Uri parse;
    if (!path.contains('https')) {
      parse = Uri.parse('${this._nodeURL}/${this._version}${path}');
    } else {
      parse = Uri.parse(path);
    }
    http
        .post(parse, body: json.encode(body))
        .timeout(Duration(seconds: httpTimeout))
        .then((http.Response response) {
      if (response.statusCode >= 300) {
        completer.completeError(response.body);
      } else {
        completer.complete(json.decode(response.body));
      }
    }).catchError((error, stackTrace) {
      completer.completeError(error.toString());
    });
    return completer.future;
  }

  // ignore: unused_element
  Future _get(String path, {int httpTimeout = 20}) async {
    Completer completer = Completer();
    Uri parse;
    if (!path.contains('https')) {
      parse = Uri.parse('${this._nodeURL}/${this._version}${path}');
    } else {
      parse = Uri.parse(path);
    }
    http
        .get(parse)
        .timeout(Duration(seconds: httpTimeout))
        .then((http.Response response) {
      if (response.statusCode >= 300) {
        completer.completeError(response.body);
      } else {
        completer.complete(json.decode(response.body));
      }
    }).catchError((error, stackTrace) {
      completer.completeError(error.toString());
    });
    return completer.future;
  }

  /// Get AMAX Node Info
  Future<NodeInfo> getInfo() async {
    return this._post('/chain/get_info', {}).then((nodeInfo) {
      NodeInfo info = NodeInfo.fromJson(nodeInfo);
      if (chainId == null) {
        chainId = info.chainId;
      }
      return info;
    });
  }

  /// Get table rows (AMAX get table ...)
  Future<List<Map<String, dynamic>>> getTableRows(
    String code,
    String scope,
    String table, {
    bool json = true,
    String tableKey = '',
    String lower = '',
    String upper = '',
    int indexPosition = 1,
    String keyType = '',
    int limit = 10,
    bool reverse = false,
  }) async {
    dynamic result = await this._post('/chain/get_table_rows', {
      'json': json,
      'code': code,
      'scope': scope,
      'table': table,
      'table_key': tableKey,
      'lower_bound': lower,
      'upper_bound': upper,
      'index_position': indexPosition,
      'key_type': keyType,
      'limit': limit,
      'reverse': reverse,
    });
    if (result is Map) {
      return result['rows'].cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getTableRows1(
    String code,
    String scope,
    String table, {
    bool json = true,
    String tableKey = '',
    String lower = '',
    String upper = '',
    int indexPosition = 1,
    String keyType = '',
    int limit = 10,
    bool reverse = false,
  }) async {
    dynamic result = await this._post('/chain/get_table_rows', {
      'json': json,
      'code': code,
      'scope': scope,
      'table': table,
      'table_key': tableKey,
      'lower_bound': lower,
      'upper_bound': upper,
      'index_position': indexPosition,
      'key_type': keyType,
      'limit': limit,
      'reverse': reverse,
    });
    if (result is Map) {
      //  print('lower' + lower.toString());
      List<Map<String, dynamic>> cast =
          result['rows'].cast<Map<String, dynamic>>();
      cast.insert(0, {'next_key': result['next_key']});
      //   print('lower' + cast.length.toString());
      return cast;
    }
    return [];
  }

  /// Get table row (AMAX get table ...)
  Future<Map<String, dynamic>?> getTableRow(
    String code,
    String scope,
    String table, {
    bool json = true,
    String tableKey = '',
    String lower = '',
    String upper = '',
    int indexPosition = 1,
    String keyType = '',
    bool reverse = false,
  }) async {
    var rows = await getTableRows(
      code,
      scope,
      table,
      json: json,
      tableKey: tableKey,
      lower: lower,
      upper: upper,
      indexPosition: indexPosition,
      keyType: keyType,
      limit: 1,
      reverse: reverse,
    );

    return rows.length > 0 ? rows[0] : null;
  }

  /// Get AMAX Block Info
  Future<Block> getBlock(String blockNumOrId) async {
    return this._post(
        '/chain/get_block', {'block_num_or_id': blockNumOrId}).then((block) {
      return Block.fromJson(block);
    });
  }

  /// Get AMAX Block Header State
  Future<BlockHeaderState> getBlockHeaderState(String blockNumOrId) async {
    return this._post('/chain/get_block_header_state',
        {'block_num_or_id': blockNumOrId}).then((block) {
      return BlockHeaderState.fromJson(block);
    });
  }

  /// Get AMAX abi from account name
  Future<AbiResp> getAbi(String accountName) async {
    return this
        ._post('/chain/get_abi', {'account_name': accountName}).then((abi) {
      return AbiResp.fromJson(abi);
    });
  }

  /// Get AMAX raw abi from account name
  Future<AbiResp> getRawAbi(String accountName) async {
    return this
        ._post('/chain/get_raw_abi', {'account_name': accountName}).then((abi) {
      return AbiResp.fromJson(abi);
    });
  }

  /// Get AMAX raw code and abi from account name
  Future<AbiResp> getRawCodeAndAbi(String accountName) async {
    return this._post('/chain/get_raw_code_and_abi',
        {'account_name': accountName}).then((abi) {
      return AbiResp.fromJson(abi);
    });
  }

  /// Get AMAX account info form the given account name
  Future<Account> getAccount(String accountName) async {
    return this._post('/chain/get_account', {'account_name': accountName}).then(
        (account) {
      return Account.fromJson(account);
    });
  }

  /// Get AMAX account info form the given account name
  Future<List<Holding>> getCurrencyBalance(
      String code, String account, String symbol,
      {int decimal = 0}) async {
    return this._post('/chain/get_currency_balance',
        {'code': code, 'account': account, 'symbol': symbol}).then((balance) {
      var list = balance as List;
      if (list.isEmpty && decimal != 0) {
        list.add('${NumUtil.getNumByValueDouble(0.0, decimal)} $symbol');
      }
      return (list).map((e) => new Holding.fromJson(e)).toList();
    });
  }

  /// Get required key by transaction from AMAX blockchain
  Future<RequiredKeys> getRequiredKeys(
      Transaction transaction, List<String> availableKeys) async {
    transaction = await _serializeActions(transaction);

    // raw abi to json
//      AbiResp abiResp = await getRawAbi(account);
//    print(abiResp.abi);
    return this._post('/chain/get_required_keys', {
      'transaction': transaction,
      'available_keys': availableKeys
    }).then((requiredKeys) {
      return RequiredKeys.fromJson(requiredKeys);
    });
  }

  /// Get AMAX account actions
  Future<Actions> getActions(String accountName,
      {int pos = -1, int offset = -1}) async {
    return this._post('/history/get_actions', {
      'account_name': accountName,
      'pot': pos,
      'offset': offset
    }).then((actions) {
      return Actions.fromJson(actions);
    });
  }

  /// Get AMAX transaction
  Future<TransactionBlock> getTransaction(String id,
      {int? blockNumHint}) async {
    return this._post('/history/get_transaction',
        {'id': id, 'block_num_hint': blockNumHint}).then((transaction) {
      return TransactionBlock.fromJson(transaction);
    });
  }

  /// Get Key Accounts
  Future<AccountNames> getKeyAccounts1(String pubKey) async {
    return this._post('/chain/get_accounts_by_authorizers', {
      'keys': [pubKey]
    }).then((accountsData) {
      List list = accountsData['accounts'] as List;
      AccountNames accountNames = AccountNames();
      accountNames.accountNames = [];
      if (list.isNotEmpty) {
        accountNames.accountNames = [];
        list.forEach((accountData) {
          if (!accountNames.accountNames!
              .contains(accountData['account_name'])) {
            accountNames.accountNames!.add(accountData['account_name']);
          }
        });
      }
      return accountNames;
    });
  }

  /// Get Key Accounts
  Future<AccountNames> getKeyAccounts2(String pubKey) async {
    return this._post('/history/get_key_accounts', {'public_key': pubKey}).then(
        (accountNames) {
      return AccountNames.fromJson(accountNames);
    });
  }

  /// Get Key Accounts
  Future<AccountNames> getKeyAccounts(String pubKey) async {
    return getKeyAccounts1(pubKey);
  }

  /// Push transaction to AMAX chain
  Future<dynamic> pushTransaction(Transaction transaction,
      {bool broadcast = true,
      bool sign = true,
      int blocksBehind = 3,
      int expireSecond = 180,
      bool autoFill = true,
      List<String>? privateKeys,
      int httpTimeout = 40}) async {
    List<String> step = [];
    try {
      step.insert(0, 'getInfo');
      NodeInfo info = await this.getInfo();
      step.insert(0, 'autoFill');
      if (autoFill) {
        Block refBlock =
            await getBlock((info.headBlockNum! - blocksBehind).toString());
        transaction = await _fullFill(transaction, refBlock);
      }
      step.insert(0, '_pushTransactionArgs');
      PushTransactionArgs pushTransactionArgs = await _pushTransactionArgs(
        info.chainId!,
        transactionTypes['transaction']!,
        transaction,
        sign,
        privateKeys,
        step,
      );
      step.insert(0, 'broadcast');
      if (broadcast) {
        return this
            ._post(
                '/chain/push_transaction',
                {
                  'signatures': pushTransactionArgs.signatures,
                  'compression': 0,
                  'packed_context_free_data': '',
                  'packed_trx':
                      ser.arrayToHex(pushTransactionArgs.serializedTransaction),
                },
                httpTimeout: httpTimeout)
            .then((processedTrx) {
          transaction.signatures = pushTransactionArgs.signatures;
          return processedTrx;
        });
      }
    } catch (e) {
      throw step.toString() + "  " + e.toString();
    }

    return null;
  }

  /// Get data needed to serialize actions in a contract */
  Future<Contract> _getContract(String accountName) async {
    var abi = await getRawAbi(accountName);
    var types = ser.getTypesFromAbi(ser.createInitialTypes(), abi.abi!);
    var actions = new Map<String, Type>();
    for (var act in abi.abi!.actions!) {
      actions[act.name] = ser.getType(types, act.type);
    }
    var result = Contract(types, actions);
    return result;
  }

  /// Fill the transaction withe reference block data
  Future<Transaction> _fullFill(Transaction transaction, Block refBlock) async {
    transaction.expiration =
        refBlock.timestamp!.add(Duration(seconds: expirationInSec));
    transaction.refBlockNum = refBlock.blockNum! & 0xffff;
    transaction.refBlockPrefix = refBlock.refBlockPrefix;

    return transaction;
  }

  /// serialize actions in a transaction
  Future<Transaction> _serializeActions(Transaction transaction) async {
    for (Action action in transaction.actions!) {
      if (action.data is Map) {
        String account = action.account!;
        Contract contract = await _getContract(account);
        action.data =
            _serializeActionData(contract, account, action.name!, action.data!);
      }
    }
    return transaction;
  }

  /// Convert action data to serialized form (hex) */
  String _serializeActionData(
      Contract contract, String account, String name, Object data) {
    var action = contract.actions[name];
    if (action == null) {
      throw "Unknown action $name in contract $account";
    }
    var buffer = new ser.SerialBuffer(Uint8List(0));
    action.serialize?.call(action, buffer, data);
    return ser.arrayToHex(buffer.asUint8List());
  }

//  Future<List<AbiResp>> _getTransactionAbis(Transaction transaction) async {
//    Set<String> accounts = Set();
//    List<AbiResp> result = [];
//
//    for (Action action in transaction.actions) {
//      accounts.add(action.account);
//    }
//
//    for (String accountName in accounts) {
//      result.add(await this.getRawAbi(accountName));
//    }
//  }

  Future<PushTransactionArgs> _pushTransactionArgs(
      String chainId,
      Type transactionType,
      Transaction transaction,
      bool sign,
      List<String>? privateKeys,
      List<String> step) async {
    List<String> signatures = [];
    Map<String, ecc.AMAXPrivateKey> keys = Map();
    step.insert(0, '_mapKeys');
    if (sign) {
      if (privateKeys == null) {
        throw "privateKeys can not be null";
      }
      _mapKeys(keys, privateKeys);
    }
    step.insert(0, 'requiredKeys');

    RequiredKeys requiredKeys =
        await getRequiredKeys(transaction, keys.keys.toList());

    Uint8List serializedTrx = transaction.toBinary(transactionType);
    step.insert(0, 'sign');
    if (sign) {
      Uint8List signBuf = Uint8List.fromList(List.from(ser.stringToHex(chainId))
        ..addAll(serializedTrx)
        ..addAll(Uint8List(32)));
      for (String publicKey in requiredKeys.requiredKeys!) {
        ecc.AMAXPrivateKey pKey = keys[publicKey]!;
        signatures.add(pKey.sign(signBuf).toString());
      }
    }
    step.insert(0, 'PushTransactionArgs');
    return PushTransactionArgs(signatures, serializedTrx);
  }
}

class PushTransactionArgs {
  List<String> signatures;
  Uint8List serializedTransaction;

  PushTransactionArgs(this.signatures, this.serializedTransaction);
}

nameToNumeric(String accountName) {
  var buffer = SerialBuffer(Uint8List(0));

  buffer.pushName(accountName);

  return binaryToDecimal(buffer.getUint8List(8));
}
