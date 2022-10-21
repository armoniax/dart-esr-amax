import 'package:dart_esr_amax/dart_esr_amax.dart';

void main(List<String> arguments) => transactionExample();

Future<void> transactionExample() async {
  print('Transaction');
  var esr = EOSIOSigningrequest('https://jungle3.cryptolions.io', 'v1',
      chainName: ChainName.EOS_JUNGLE3);

  var auth = <Authorization>[
    Authorization()
      ..actor = 'testName1111'
      ..permission = 'active'
  ];

  var data = <String, String>{'name': 'data'};

  var actions = <Action>[
    Action()
      ..account = 'eosnpingpong'
      ..name = 'ping'
      ..authorization = auth
      ..data = data,
  ];

  var transaction = Transaction()..actions = actions;

  var encoded = await esr.encodeTransaction(transaction);
  var decoded = esr.deserialize(encoded);

  print('encoded : ' + encoded);
  print('decoded : ' + decoded.toString());
}
