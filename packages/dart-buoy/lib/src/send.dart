import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dart_buoy/src/options.dart';

Future<http.Response> fetch(
  String url, {
  Object? body,
  Map<String, String>? headers,
}) async {
  var uri = Uri.parse(url);

  var response = await http.post(
    uri,
    body: body is Map ? json.encode(body) : body,
    headers: headers,
  );

  if ((response.statusCode / 100).floor() != 2) {
    if (response.statusCode == 408) {
      throw 'Unable to deliver message';
    } else if (response.statusCode == 410) {
      throw 'Request cancelled';
    } else {
      throw "Unexpected status code ${response.statusCode}";
    }
  }
  return response;
}

// getTypeName(dynamic obj) {
//   return reflect(obj).type.reflectedType.toString();
// }

Future<dynamic> send(
  dynamic message,
  SendOptions options,
) async {
  String baseUrl = options.service.replaceFirst('ws', 'http');

  String url = "$baseUrl/${options.channel}";

  Map<String, String> headers = {};

  if (options.requireDelivery == true) {
    if (options.timeout != null) {
      throw 'requireDelivery can only be used with timeout';
    }
    headers['X-Buoy-Wait'] = "${(options.timeout! / 1000).ceil()}";
  } else if (options.timeout != null) {
    headers['X-Buoy-Soft-Wait'] = "${(options.timeout! / 1000).ceil()}";
  }

  dynamic body;

  if (message is String || message is List<int>) {
    body = message;
  } else {
    body = json.decode(json.encode(message));
  }

  http.Response response = await fetch(
    url,
    body: body,
    headers: headers,
  );

  return response.headers['x-buoy-delivery'];
}
