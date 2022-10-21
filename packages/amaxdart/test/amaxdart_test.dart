import 'package:amaxdart/amaxdart.dart';
import 'package:test/test.dart';

void main() {
  group('AMAX Client', () {
    late AMAXClient client;

    setUp(() {
      client = AMAXClient('https://1127.0.0.1:8888', 'v1');
    });

    test('Get Info', () {
      client.getInfo().then((NodeInfo nodeInfo) {
        expect(nodeInfo.headBlockNum! > 0, isTrue);
      });
    });

    test('Get Abi', () {
      client.getAbi('amax.token').then((AbiResp abi) {
        expect(abi.accountName, equals('amax.token'));
      });
    });

    test('Get Raw Abi', () {
      client.getRawAbi('amax.token').then((AbiResp abi) {
        expect(abi.accountName, equals('amax.token'));
        expect(abi.codeHash,
            '86cab526bb39224b6e06a012a5d45e90cf4d3117203e66d5bd5668db45741c75');
        expect(abi.abiHash,
            '601365afd8a39d1d55caea0589ca3a14215918b7056690cda9d737f24810c685');
        expect(abi.abi, isNotNull);
      });
    });

    test('Get Raw code and Abi', () {
      client.getRawCodeAndAbi('amax.token').then((AbiResp abi) {
        expect(abi.accountName, equals('amax.token'));
        expect(abi.wasm!.length > 0, isTrue);
        expect(abi.abi, isNotNull);
      });
    });

    test('Get Block', () {
      client.getBlock('43743575').then((Block block) {
        expect(block.blockNum! > 0, isTrue);
        expect(block.producer, 'zbeosbp11111');
        expect(block.confirmed, 0);
        expect(block.transactionMRoot,
            '8fb685526d58dfabd05989b45b8576197acc1be59d753bb396386d5d718f9fa9');
        expect(block.transactions!.length > 10, isTrue);
      });
    });

    test('Get Account', () {
      client.getAccount('amax.stake').then((Account account) {
        expect(account.accountName, equals('amax.stake'));
        expect(account.coreLiquidBalance!.amount! > 0, isTrue);
      });
    });

    test('Get currency balance', () {
      client
          .getCurrencyBalance('parslseed123', 'newdexpocket', 'SEED')
          .then((List<Holding> tokens) {
        expect(tokens.length > 0, isTrue);
        expect(tokens[0].amount! > 0, isTrue);
        expect(tokens[0].currency, 'SEED');
      });
    });

    test('Get Transaction', () {
      client
          .getTransaction(
              '8ca0fea82370a2dbbf2c4bd1026bf9fd98a57685bee3672c4ddbbc9be21de984')
          .then((TransactionBlock transaction) {
        expect(transaction.blockNum, 43743575);
        expect(transaction.trx!.receipt!.cpuUsageUs, 132);
        expect(transaction.trx!.receipt!.netUsageWords, 0);
        expect(transaction.traces!.length, 2);
        expect(transaction.traces![0].receipt!.receiver, 'trustdicelog');
        expect(transaction.traces![0].inlineTraces!.length, 1);
        expect(transaction.traces![0].inlineTraces![0].receipt!.receiver,
            'ge4tcnrxgyge');
      });
    });
  });
}
