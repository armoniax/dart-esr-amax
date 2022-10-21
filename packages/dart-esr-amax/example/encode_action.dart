import 'package:dart_esr_amax/dart_esr_amax.dart';

void main(List<String> arguments) => actionExample();

Future<void> actionExample() async {
  print('Action');
  var esr = EOSIOSigningrequest('https://jungle3.cryptolions.io', 'v1',
      chainName: ChainName.EOS_JUNGLE3);

  var auth = <Authorization>[
    Authorization.fromJson(ESRConstants.PlaceholderAuth)
  ];

  var data = <String, String>{'name': 'data'};

  var action = Action()
    ..account = 'eosnpingpong'
    ..name = 'ping'
    ..authorization = auth
    ..data = data;

  var encoded = await esr.encodeAction(action);
  var decoded = esr.deserialize(encoded);

  print('encoded : ' + encoded);
  print('decoded : ' + decoded.toString());
}
