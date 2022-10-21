import 'package:dart_esr_amax/dart_esr_amax.dart';

void main(List<String> arguments) => actionsExample();

Future<void> actionsExample() async {
  print('Actions');
  var esr = EOSIOSigningrequest('https://jungle3.cryptolions.io', 'v1',
      chainName: ChainName.EOS_JUNGLE3);

  var auth = <Authorization>[
    Authorization.fromJson(ESRConstants.PlaceholderAuth)
  ];

  var data1 = <String, String>{'name': 'data1'};

  var action1 = Action()
    ..account = 'eosnpingpong'
    ..name = 'ping'
    ..authorization = auth
    ..data = data1;

  var data2 = <String, String>{'name': 'data2'};

  var action2 = Action()
    ..account = 'eosnpingpong'
    ..name = 'ping'
    ..authorization = auth
    ..data = data2;

  var actions = <Action>[action1, action2];

  var encoded = await esr.encodeActions(actions);
  var decoded = esr.deserialize(encoded);

  print('encoded : ' + encoded);
  print('decoded : ' + decoded.toString());
}
