import 'package:rpa/multi_runner.dart';

String parseExecutableAlias(String exe) {
  if (config.alias.containsKey(exe.toLowerCase())) {
    var alias = config.alias[exe.toLowerCase()].toString().trim();
    if (alias.isNotEmpty) {
      return alias;
    }
  }
  return exe;
}
