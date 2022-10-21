# dart-esr

dart-esr is used to generate an EOSIO signing request (ESR) for a transaction/action/actions[]/identity request to be send, sign and broadcast to a node by a wallet (Anchor)

ESR protocol documentation -> https://github.com/eosio-eps/EEPs/blob/master/EEPS/eep-7.md#ESR---The--EOSIO-Signing-Request--protocol

dart-esr is based on javascript library eosio-signing-request -> https://github.com/greymass/eosio-signing-request

Request format -> https://github.com/eosio-eps/EEPs/blob/master/EEPS/eep-7.md#payload

## Examples

https://github.com/EOS-Nation/dart-esr/tree/feature/eosio-signing-request/example

## Usage

####Import

```dart
import 'package:dart_esr_amax/dart_esr_amax.dart';
```

####Create Signing request object with a eos node url, version and ChainName

```dart

var esr = EOSIOSigningrequest('https://jungle2.cryptolions.io', 'v1',
    chainName: ChainName.EOS_JUNGLE2);
```

####Encode a transaction

```dart
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
```

####Encode an action

```dart
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
```

####Encode a list of actions

```dart
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
```

####Encode an identity request

```dart
  var permission = IdentityPermission()
    ..actor = 'testname1111'
    ..permission = 'active';

  var identity = Identity()..identityPermission = permission;
  String callback = "https://cNallback.com";

  var encoded = await esr.encodeIdentity(identity, callback);
```

## Installing

TODO when added to pub.dev

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/EOS-Nation/dart-esr/issues
