import 'package:dart_esr_amax/dart_esr_amax.dart';

void main(List<String> arguments) => decodeESRExample();

Future<void> decodeESRExample() async {
  print('Decode ESR');
  var esr = EOSIOSigningrequest('https://jungle2.cryptolions.io', 'v1',
      chainName: ChainName.EOS_JUNGLE2);

  var encodedRequest =
      'esr://gmNgZur_-TdO7KrRD9ePDEDAeEBtbc4uK8NQEIfhwLLVjAJOHF5SEzaeAvFXvDUy4mQESyVs8mQAsgA';
  var decoded = esr.deserialize(encodedRequest);

  print(decoded.toString());
}
