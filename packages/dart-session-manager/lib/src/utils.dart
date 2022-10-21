// import {Bytes, Checksum512, PrivateKey, PublicKey, Serializer, UInt64} from '@greymass/eosio'

// import {AES_CBC} from 'asmcrypto.js'

// /**
//  * Encrypt a message using AES and shared secret derived from given keys.
//  * @internal
//  */
// export function unsealMessage(
//     message = Bytes,
//     privateKey = PrivateKey,
//     publicKey = PublicKey,
//     nonce = UInt64
// ): string {
//     const secret = privateKey.sharedSecret(publicKey)
//     const key = Checksum512.hash(Serializer.encode({object: nonce}).appending(secret.array))
//     const cbc = AES_CBC(key.array.slice(0, 32), key.array.slice(32, 48))
//     const ciphertext = Bytes.from(cbc.decrypt(message.array))
//     return ciphertext.toString('utf8')
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:amaxdart_ecc/amaxdart_ecc.dart';
import 'package:dart_session_manager/src/abi.dart';
import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:amaxdart/amaxdart.dart' as Client;
import 'package:encrypt/encrypt.dart';
import 'package:hash/hash.dart';

Map<String, dynamic> curves = {};

Curve getCurve(type) {
  var rv = curves[type];
  if (type == 'K1') {
    rv = curves[type] = getSecp256k1();
  } else if (type == 'R1') {
    rv = curves[type] = getP256();
  } else {
    throw 'Unknown curve type: $type';
  }
  return rv;
}

Uint8List sha512(List<int> msg) {
  return SHA512().update(msg).digest();
}

Uint8List sharedSecret(privateKey, publicKey) {
  const type = 'K1';
  Curve curve = getCurve(type);
  var ak = AMAXPublicKey.fromString(publicKey);
  var bk = AMAXPrivateKey.fromString(privateKey);
  PrivateKey b = PrivateKey.fromBytes(curve, bk.d as List<int>);
  PublicKey p = PublicKey.fromHex(curve, Client.arrayToHex(ak.toBuffer()));
  return sha512(Uint8List.fromList(computeSecret(b, p)));
}

Uint8List getKey(Map msg, Uint8List secret) {
  var abi = Client.getTypesFromAbi(
    Client.createInitialTypes(),
    Client.Abi.fromJson(
      json.decode(AbiString),
    ),
  );

  var type = abi['encoded'];
  var buffer = Client.SerialBuffer(Uint8List(0));
  type!.serialize!(type, buffer, msg);
  buffer.pushArray(secret);
  return sha512(buffer.asUint8List());
}

String unsealMessage(
  dynamic message,
  String privateKey,
  String PublicKey,
  String nonce,
) {
  Uint8List secret = sharedSecret(privateKey, PublicKey);
  Uint8List key = getKey({'object': nonce}, secret);
  Uint8List k = Uint8List.fromList(key.getRange(0, 32).toList());
  Uint8List v = Uint8List.fromList(key.getRange(32, 48).toList());
  Encrypter encrypter = Encrypter(AES(
    Key(k),
    mode: AESMode.cbc,
  ));

  String unsealed = encrypter.decrypt(
    Encrypted(Client.hexToUint8List(message)),
    iv: IV(v),
  );

  return unsealed;
}
