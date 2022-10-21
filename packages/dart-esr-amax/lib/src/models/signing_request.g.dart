part of 'signing_request.dart';

SigningRequest _$SigningRequestFromJson(Map<String, dynamic> json) {
  return SigningRequest()
    ..chainId = (json['chain_id'] as List)
    ..req = (json['req'] as List)
    ..flags = json['flags'] as int
    ..callback = json['callback'] as String
    ..info = (json['info'] as List);
}

Map<String, dynamic> _$SigningRequestToJson(SigningRequest instance) =>
    <String, dynamic>{
      'chain_id': instance.chainId,
      'req': instance.req,
      'flags': instance.flags,
      'callback': instance.callback,
      'info': instance.info
    };
