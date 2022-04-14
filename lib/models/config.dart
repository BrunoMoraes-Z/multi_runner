import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:rpa/models/action.dart';

class Config {
  final String startDate, endDate;
  final List<Action> actions;
  final Map<String, dynamic> alias;

  Config({
    required this.startDate,
    required this.endDate,
    required this.actions,
    required this.alias,
  });

  static Future<Config> _of(File file) async {
    var raw = await file.readAsString();
    var content = json.decode(raw);

    var now = DateFormat('yyy-MM-dd').format(DateTime.now());

    return Config(
      startDate: Platform.environment["start_date"] ?? now,
      endDate: Platform.environment["end_date"] ?? now,
      actions: (content['actions'] as List)
          .map(
            (e) => Action.fromJson(e),
          )
          .toList(),
      alias: (content['alias'] as Map<String, dynamic>),
    );
  }

  static Future<Config> fromFile() async {
    return Config._of(File('$_parent/config.json'));
  }

  static Future<bool> exists() async {
    return await File('$_parent/config.json').exists();
  }

  static String get _parent => Directory.fromUri(Platform.script).parent.path;
}
