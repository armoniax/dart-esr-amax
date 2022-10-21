import 'package:dart_buoy/src/options.dart';

/// Example：
/// source: https://fwd.aplink.app/037776f7-e666-4ffe-b0e2-6f5bcb8be656
/// url: https://fwd.aplink.app
/// channel: 037776f7-e666-4ffe-b0e2-6f5bcb8be656
///
///
/// Example:
/// ```dart
/// String string = 'https://fwd.aplink.app/037776f7-e666-4ffe-b0e2-6f5bcb8be656';
/// Options result = getOptionsByUrl(string);
/// Options.url // https://fwd.aplink.app
/// ```
Options getOptionsByUrl(String uri) {
  Uri u = Uri.parse(uri);
  return Options("${u.scheme}://${u.host}", u.pathSegments[0]);
}
