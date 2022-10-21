import 'package:amaxdart/amaxdart.dart';

main() async {
  AMAXClient client = AMAXClient('http://127.0.0.1:8888', 'v1');

  // Get Tables
  client.getTableRows('amax', 'amax', 'abihash').then((rows) => print(rows));
  client.getTableRow('amax', 'amax', 'abihash').then((row) => print(row));
}
