import 'dart:typed_data';
import 'package:amaxdart/amaxdart.dart';
import 'package:json_annotation/json_annotation.dart';

part 'identity.g.dart';

@JsonSerializable(explicitToJson: true)
abstract class Identity {
  @JsonKey(name: 'permission')
  late IdentityPermission identityPermission;

  Map<String, dynamic> toJson();

  Uint8List toBinary(Type type) {
    var buffer = SerialBuffer(Uint8List(0));
    type.serialize!(type, buffer, this.toJson());
    return buffer.asUint8List();
  }
}

@JsonSerializable(explicitToJson: true)
class IdentityV2 extends Identity {
  IdentityV2();

  factory IdentityV2.fromJson(Map<String, dynamic> json) =>
      _$IdentityV2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IdentityV2ToJson(this);

  @override
  String toString() => this.toJson().toString();
}

@JsonSerializable(explicitToJson: true)
class IdentityV3 extends Identity {
  @JsonKey(name: 'scope')
  String scope;

  IdentityV3(this.scope);

  factory IdentityV3.fromJson(Map<String, dynamic> json) =>
      _$IdentityV3FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IdentityV3ToJson(this);

  @override
  String toString() => this.toJson().toString();
}

@JsonSerializable(explicitToJson: true)
class IdentityPermission {
  @JsonKey(name: 'actor')
  String actor;

  @JsonKey(name: 'permission')
  String permission;

  IdentityPermission(this.actor, this.permission);

  factory IdentityPermission.fromJson(Map<String, dynamic> json) =>
      _$IdentityPermissionFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityPermissionToJson(this);

  @override
  String toString() => this.toJson().toString();
}
